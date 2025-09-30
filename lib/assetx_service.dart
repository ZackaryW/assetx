import 'dart:io';
import 'package:path/path.dart' as path;
import 'model/config.dart';
import 'model/lock.dart';
import 'model/builtin.dart';

class AssetXService {
  static const String defaultConfigFile = 'assetx.yaml';
  static const String defaultLockFile = 'assetx.lock';

  /// Generate lock file from configuration
  static Future<void> generateLock({
    String? configPath,
    String? lockPath,
    String? workingDirectory,
  }) async {
    final workDir = workingDirectory ?? Directory.current.path;
    final configFile = configPath ?? path.join(workDir, defaultConfigFile);
    final lockFile = lockPath ?? path.join(workDir, defaultLockFile);

    // Load configuration
    final config = await Config.load(configFile);

    // Validate that all configuration entries have valid generators
    validateGenerators(config);

    // Discover files based on configuration entries
    final discoveredFiles = <FileConfig>[];

    for (final entry in config.entries) {
      final files = await _discoverFiles(entry, workDir);
      discoveredFiles.addAll(files);
    }

    // Create and save lock file
    final lock = LockFile(discoveredFiles);
    await lock.save(lockFile);
  }

  /// Discover files based on a configuration entry
  static Future<List<FileConfig>> _discoverFiles(
    ConfigEntry entry,
    String workingDirectory,
  ) async {
    final discoveredFiles = <FileConfig>[];
    final basePath = path.isAbsolute(entry.path)
        ? entry.path
        : path.join(workingDirectory, entry.path);

    final baseDir = Directory(basePath);

    if (!await baseDir.exists()) {
      // If path doesn't exist, skip silently or you could throw an error
      return discoveredFiles;
    }

    await for (final entity in baseDir.list(recursive: entry.recursive)) {
      if (entity is File) {
        final filePath = entity.path;
        final fileName = path.basename(filePath);

        // Check if file should be excluded
        if (_shouldExcludeFile(fileName, filePath, entry.exclusions)) {
          continue;
        }

        // Check if the generator can handle this file type
        if (GeneratorRegistry.canHandleFile(entry.type, filePath)) {
          discoveredFiles.add(FileConfig.generate(filePath, entry.type));
        }
      }
    }

    return discoveredFiles;
  }

  /// Check if a file should be excluded based on exclusion patterns
  static bool _shouldExcludeFile(
    String fileName,
    String filePath,
    List<String> exclusions,
  ) {
    for (final exclusion in exclusions) {
      // Support both simple patterns and glob-like patterns
      if (exclusion.contains('*')) {
        final regex = RegExp(
          exclusion
              .replaceAll('.', '\\.')
              .replaceAll('*', '.*')
              .replaceAll('?', '.'),
          caseSensitive: false,
        );
        if (regex.hasMatch(fileName) || regex.hasMatch(filePath)) {
          return true;
        }
      } else {
        // Simple string matching
        if (fileName.contains(exclusion) || filePath.contains(exclusion)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Validate that all configuration entries have valid generators
  static void validateGenerators(Config config) {
    for (final entry in config.entries) {
      if (!GeneratorRegistry.hasGenerator(entry.type)) {
        throw StateError(
          'No generator found for type "${entry.type}". '
          'Available types: ${GeneratorRegistry.getRegisteredTypes().join(', ')}',
        );
      }
    }
  }

  /// Get files from existing lock file
  static Future<List<FileConfig>> getLockedFiles([String? lockPath]) async {
    final lockFile = lockPath ?? defaultLockFile;
    final lock = await LockFile.load(lockFile);
    return lock.files;
  }

  /// Check if lock file exists and is up to date
  static Future<bool> isLockUpToDate({
    String? configPath,
    String? lockPath,
  }) async {
    final configFile = File(configPath ?? defaultConfigFile);
    final lockFile = File(lockPath ?? defaultLockFile);

    if (!await lockFile.exists()) {
      return false;
    }

    if (!await configFile.exists()) {
      return true; // No config file, so lock file is technically up to date
    }

    final configModified = await configFile.lastModified();
    final lockModified = await lockFile.lastModified();

    return lockModified.isAfter(configModified);
  }

  /// Generate Dart code from lock file
  static Future<String> generateDartCode({
    String? lockPath,
    String? configPath,
  }) async {
    final lockFile = lockPath ?? defaultLockFile;
    final lock = await LockFile.load(lockFile);

    // Group files by type for generator processing
    final filesByType = <String, List<FileConfig>>{};
    for (final fileConfig in lock.files) {
      filesByType.putIfAbsent(fileConfig.type, () => []).add(fileConfig);
    }

    final buffer = StringBuffer();
    final classAccessors = <String, List<String>>{};

    // Add required imports
    buffer.writeln(
      '// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types',
    );
    buffer.writeln();
    buffer.writeln('import \'dart:convert\';');
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('import \'package:flutter/services.dart\';');
    buffer.writeln();

    // Generate code for each type using its generator
    for (final entry in filesByType.entries) {
      final type = entry.key;
      final files = entry.value;

      final generator = GeneratorRegistry.getGenerator(type);
      if (generator != null) {
        final result = generator.generateCode(files);

        // Add the generated constants and variables
        buffer.writeln(result.partFileContent);

        // Group accessors by directory for class organization
        for (final file in files) {
          final classKey = '\$folder${file.uid}';
          classAccessors
              .putIfAbsent(classKey, () => [])
              .add(result.varReferrer);
        }
      }
    }

    // Generate directory-based classes
    for (final entry in classAccessors.entries) {
      final className = entry.key;
      final accessors = entry.value;

      buffer.writeln('class ${className}_files {');
      buffer.writeln('  const ${className}_files();');
      for (final accessor in accessors) {
        buffer.writeln('  $accessor');
      }
      buffer.writeln('}');
      buffer.writeln();

      buffer.writeln('class ${className}_filepaths {');
      buffer.writeln('  const ${className}_filepaths();');
      // Add filepath accessors here if needed
      buffer.writeln('}');
      buffer.writeln();

      buffer.writeln('class $className {');
      buffer.writeln('  const $className();');
      buffer.writeln(
        '  ${className}_filepaths get FILEPATHS => const ${className}_filepaths();',
      );
      buffer.writeln(
        '  ${className}_files get FILES => const ${className}_files();',
      );
      buffer.writeln('}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
