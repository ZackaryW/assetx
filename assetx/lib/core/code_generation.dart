import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/lock.dart';
import '../generators/builtin.dart';
import '../generators/base.dart';
import '../utils/file/config.dart';

/// Service responsible for generating Dart code from discovered assets
class CodeGenerationService {
  /// Generate Dart code from lock file
  static Future<String> generateDartCode({
    String? lockPath,
    String? configPath,
    String? workingDirectory,
  }) async {
    const defaultLockFile = 'assetx.lock';
    final lockFile = lockPath ?? defaultLockFile;
    final lock = await LockFile.load(lockFile);

    // Get current package name from pubspec.yaml
    final workDir = workingDirectory ?? Directory.current.path;
    final packageName = await _getPackageName(workDir);

    // Group files by type for generator processing
    final filesByType = <String, List<FileConfig>>{};
    for (final fileConfig in lock.files) {
      filesByType.putIfAbsent(fileConfig.type, () => []).add(fileConfig);
    }

    final buffer = StringBuffer();

    // Add required imports
    buffer.writeln(
      '// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types',
    );
    buffer.writeln();
    buffer.writeln('import \'dart:convert\';');
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('import \'package:flutter/services.dart\';');
    buffer.writeln('import \'package:assetxf/assetxf.dart\';');
    buffer.writeln();

    // Group files by their actual folder paths (use hash-based keys to avoid name collisions)
    final folderGroups = <String, List<FileConfig>>{};
    final folderKeyToPath = <String, String>{};

    for (final fileConfig in lock.files) {
      final folderPath = path.dirname(fileConfig.fullPath);
      final relativeFolderPath = path.relative(folderPath, from: workDir);

      // Generate unique key for folder grouping
      final folderKey = IdentifierUtils.createFolderKey(relativeFolderPath);
      folderKeyToPath[folderKey] = relativeFolderPath;

      folderGroups.putIfAbsent(folderKey, () => []).add(fileConfig);
    }

    // Generate constants for all assets first - delegate to generators
    for (final entry in filesByType.entries) {
      final type = entry.key;
      final files = entry.value;

      final generator = GeneratorRegistry.getGenerator(type);
      if (generator != null) {
        final result = generator.generateCode(files);
        buffer.writeln(result.partFileContent);
      }
    }

    // Generate folder-based classes
    for (final entry in folderGroups.entries) {
      final folderKey = entry.key;
      final filesInFolder = entry.value;
      // Get original path and generate unique class name
      final originalPath = folderKeyToPath[folderKey]!;
      final folderClassName = IdentifierUtils.createUniqueClassName(
        originalPath,
      );

      // Get all accessors from generators once
      final allAccessors = <FileAccessor>[];
      final filesByTypeInFolder = <String, List<FileConfig>>{};
      for (final file in filesInFolder) {
        filesByTypeInFolder.putIfAbsent(file.type, () => []).add(file);
      }

      for (final typeEntry in filesByTypeInFolder.entries) {
        final type = typeEntry.key;
        final files = typeEntry.value;

        final generator = GeneratorRegistry.getGenerator(type);
        if (generator != null) {
          final accessors = generator.generateAccessors(files);
          allAccessors.addAll(accessors);
        }
      }

      // Generate _files class using generator-provided accessors
      buffer.writeln('class ${folderClassName}_files {');
      buffer.writeln('  const ${folderClassName}_files();');
      buffer.writeln();

      for (final accessor in allAccessors) {
        buffer.writeln('  ${accessor.accessorCode}');
      }
      buffer.writeln('}');
      buffer.writeln();

      // Generate _filepaths class using generator-provided file path accessors
      buffer.writeln('class ${folderClassName}_filepaths {');
      buffer.writeln('  const ${folderClassName}_filepaths();');
      buffer.writeln();

      for (final accessor in allAccessors) {
        buffer.writeln('  ${accessor.filePathAccessor}');
      }
      buffer.writeln('}');
      buffer.writeln();

      // Generate main folder class
      buffer.writeln('class $folderClassName {');
      buffer.writeln('  const $folderClassName();');
      buffer.writeln();
      buffer.writeln(
        '  ${folderClassName}_filepaths get \$paths => const ${folderClassName}_filepaths();',
      );
      buffer.writeln(
        '  ${folderClassName}_files get \$files => const ${folderClassName}_files();',
      );
      buffer.writeln('}');
      buffer.writeln();
    }

    // Generate package-named class that contains all folder instances
    if (folderKeyToPath.isNotEmpty) {
      final packageClassName = IdentifierUtils.createValidClassName(
        packageName,
      );

      buffer.writeln('class $packageClassName {');
      buffer.writeln('  const $packageClassName();');
      buffer.writeln();

      // Generate getters using readable folder names but pointing to hash-based classes
      final processedFolderNames = <String>{};
      for (final entry in folderKeyToPath.entries) {
        final folderPath = entry.value;
        final folderName = path.basename(folderPath);

        // Use readable folder name for getter
        final getterName = IdentifierUtils.createValidIdentifier(folderName);
        // Use hash-based class name for type
        final folderClassName = IdentifierUtils.createUniqueClassName(
          folderPath,
        );

        // Handle duplicate folder names by numbering them
        var finalGetterName = getterName;
        var counter = 1;
        while (processedFolderNames.contains(finalGetterName)) {
          finalGetterName = '${getterName}$counter';
          counter++;
        }

        buffer.writeln(
          '  $folderClassName get $finalGetterName => const $folderClassName();',
        );
        processedFolderNames.add(finalGetterName);
      }
      buffer.writeln('}');
      buffer.writeln();

      // Generate extension on AssetX with package-named class instance
      buffer.writeln('extension AssetXGenerated on AssetX {');
      final packageGetterName = IdentifierUtils.createValidIdentifier(
        packageName,
      );
      buffer.writeln(
        '  $packageClassName get $packageGetterName => const $packageClassName();',
      );
      buffer.writeln('}');
    }

    return buffer.toString();
  }

  /// Get package name from pubspec.yaml
  static Future<String> _getPackageName(String workingDirectory) async {
    final pubspecFile = File(path.join(workingDirectory, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      return 'assets'; // Default package name if no pubspec.yaml found
    }

    try {
      final content = await pubspecFile.readAsString();
      final lines = content.split('\n');

      for (final line in lines) {
        if (line.trim().startsWith('name:')) {
          final name = line.split(':')[1].trim();
          return name
              .replaceAll('"', '')
              .replaceAll("'", ''); // Remove quotes if present
        }
      }
    } catch (e) {
      // If parsing fails, return default
    }

    return 'assets'; // Default fallback
  }
}
