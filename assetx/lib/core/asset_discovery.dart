import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/config.dart';
import '../model/lock.dart';
import '../generators/builtin.dart';

/// Service responsible for discovering asset files based on configuration
class AssetDiscoveryService {
  /// Discover files based on a configuration entry
  static Future<List<FileConfig>> discoverFiles(
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
        if (shouldExcludeFile(fileName, filePath, entry.exclusions)) {
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
  static bool shouldExcludeFile(
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
}
