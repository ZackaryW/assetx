import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/lock.dart';
import '../generators/builtin.dart';
import '../generators/base.dart';

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

    // Group files by their actual folder paths
    final folderGroups = <String, List<FileConfig>>{};
    for (final fileConfig in lock.files) {
      final folderPath = path.dirname(fileConfig.fullPath);
      final folderName = path.basename(folderPath);
      folderGroups.putIfAbsent(folderName, () => []).add(fileConfig);
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
      final folderName = entry.key;
      final filesInFolder = entry.value;
      final folderClassName = _createValidIdentifier(
        folderName,
        isClassName: true,
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
        '  ${folderClassName}_filepaths get FILEPATHS => const ${folderClassName}_filepaths();',
      );
      buffer.writeln(
        '  ${folderClassName}_files get FILES => const ${folderClassName}_files();',
      );
      buffer.writeln('}');
      buffer.writeln();
    }

    // Generate package-named class that contains all folder instances
    final folderNames = folderGroups.keys.toList();
    if (folderNames.isNotEmpty) {
      final packageClassName = _createValidIdentifier(
        packageName,
        isClassName: true,
      );

      buffer.writeln('class $packageClassName {');
      buffer.writeln('  const $packageClassName();');
      buffer.writeln();

      // Generate getters for each folder using actual folder names
      final processedFolders = <String>{};
      for (final folderName in folderNames) {
        final folderClassName = _createValidIdentifier(
          folderName,
          isClassName: true,
        );
        final getterName = _createValidIdentifier(folderName);

        if (!processedFolders.contains(folderName)) {
          buffer.writeln(
            '  $folderClassName get $getterName => const $folderClassName();',
          );
          processedFolders.add(folderName);
        }
      }
      buffer.writeln('}');
      buffer.writeln();

      // Generate extension on AssetX with package-named class instance
      buffer.writeln('extension AssetXGenerated on AssetX {');
      final packageGetterName = _createValidIdentifier(packageName);
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

  /// Create a valid Dart identifier from a string
  static String _createValidIdentifier(
    String input, {
    bool isClassName = false,
  }) {
    // Remove special characters and replace with underscores
    String result = input.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it doesn't start with a number
    if (RegExp(r'^[0-9]').hasMatch(result)) {
      result = '_$result';
    }

    // Convert to appropriate case
    if (isClassName) {
      // PascalCase for class names
      return result
          .split('_')
          .map(
            (part) => part.isEmpty
                ? ''
                : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
          )
          .join();
    } else {
      // camelCase for other identifiers
      final parts = result.split('_');
      if (parts.isEmpty) return 'assets';

      return parts.first.toLowerCase() +
          parts
              .skip(1)
              .map(
                (part) => part.isEmpty
                    ? ''
                    : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
              )
              .join();
    }
  }
}
