import 'dart:io';
import 'dart:convert';

import '../gen/config.dart';
import '../gen/default.dart';
import '../utils/codebuffer.dart';
import '../utils/lookup.dart';
import '../utils/io/ioext.dart';

/// Utility class for generating static non-lazy classes for datax and envx types
class StaticGenerator {
  /// Generates non-lazy static classes for datax and envx types
  static void generateNonLazyClasses(
    CodeBuffer buffer,
    List<AssetLookupFile> files,
    AssetXConfig config,
    String packageName,
    bool usePackagePrefix,
  ) {
    // Find files that should be generated as non-lazy
    final nonLazyFiles = <AssetLookupFile>[];

    for (final file in files) {
      final typeName = _getTypeName(file, config);

      if (config.mapRegistry != null &&
          config.mapRegistry!.containsKey(typeName)) {
        final mapConfig = config.mapRegistry![typeName]!;

        if (mapConfig.builtin != null &&
            !mapConfig.lazy &&
            ["datax", "envx"].contains(mapConfig.builtin)) {
          nonLazyFiles.add(file);
        }
      }
    }

    if (nonLazyFiles.isEmpty) return;

    buffer.addCode('// Generated non-lazy static classes');
    buffer.addCode('');

    int classCounter = 0;

    for (final file in nonLazyFiles) {
      _generateStaticClass(buffer, file, classCounter, config);
      classCounter++;
    }
  }

  /// Generates a single static class for a file
  static void _generateStaticClass(
    CodeBuffer buffer,
    AssetLookupFile file,
    int classCounter,
    AssetXConfig config,
  ) {
    final className = '\$m${classCounter.toString().padLeft(4, '0')}';

    buffer.addCode('class $className {');

    // For data files (JSON, YAML, ENV, TOML), parse and generate static getters
    final extension = file.extension.toLowerCase();
    final supportedExtensions = ['.json', '.yaml', '.yml', '.env', '.toml'];

    if (supportedExtensions.contains(extension)) {
      try {
        if (File(file.path).existsSync()) {
          final content = File(file.path).readAsStringSync();
          final data = IoExt.auto(
            file.path,
            content,
            // load the map
            (path) => IoExt.loadAuto(path, File(path).readAsStringSync()),
          );
          if (data.isNotEmpty) {
            _generateGetters(buffer, data, className, classCounter);

            return; // _generateGetters handles the closing brace
          }
        }
      } catch (e) {
        // If we can't parse the file, generate a simple path getter
        buffer.addCode('  // Could not parse file at compile time: $e');
        buffer.addCode('  static const String path = "${file.path}";');
      }
    } else {
      // For other file types, just provide the path
      buffer.addCode('  static const String path = "${file.path}";');
    }

    // Close the class if we haven't already done so in _generateStaticGetters
    buffer.addCode('}');
    buffer.addCode('');
  }

  /// Generates static getters for JSON properties
  static void _generateGetters(
    CodeBuffer buffer,
    Map<String, dynamic> jsonData,
    String className,
    int classCounter,
  ) {
    final nestedClasses = <String, Map<String, dynamic>>{};

    for (final entry in jsonData.entries) {
      final key = entry.key;
      final value = entry.value;

      // Generate getter based on value type
      if (value is String) {
        buffer.addCode('  String get $key => "$value";');
      } else if (value is int) {
        buffer.addCode('  int get $key => $value;');
      } else if (value is double) {
        buffer.addCode('  double get $key => $value;');
      } else if (value is bool) {
        buffer.addCode('  bool get $key => $value;');
      } else if (value is Map<String, dynamic>) {
        // For nested objects, reference a nested class
        final nestedClassName = '${className}_$key';
        buffer.addCode('  get $key => ${nestedClassName}Instance;');
        nestedClasses[nestedClassName] = value;
      } else if (value is List) {
        // For arrays, create a list
        buffer.addCode('  List get $key => ${jsonEncode(value)};');
      } else {
        // For other types, use the raw value
        buffer.addCode('  dynamic get $key => $value;');
      }
    }

    buffer.addCode('}');
    buffer.addCode('');
    buffer.addCode('final ${className}Instance = $className();');
    buffer.addCode('');

    // Generate nested classes
    for (final entry in nestedClasses.entries) {
      final nestedClassName = entry.key;
      final nestedData = entry.value;

      buffer.addCode('class $nestedClassName {');
      _generateGetters(buffer, nestedData, nestedClassName, classCounter);

      buffer.addCode('');
      // Note: The closing brace and empty line are added by the recursive call
    }
  }

  /// Finds files that should be generated as non-lazy static classes
  static List<AssetLookupFile> findNonLazyFiles(
    List<AssetLookupFile> files,
    AssetXConfig config,
  ) {
    final nonLazyFiles = <AssetLookupFile>[];

    for (final file in files) {
      final typeName = _getTypeName(file, config);

      if (config.mapRegistry != null &&
          config.mapRegistry!.containsKey(typeName)) {
        final mapConfig = config.mapRegistry![typeName]!;

        if (mapConfig.builtin != null &&
            !mapConfig.lazy &&
            ["datax", "envx"].contains(mapConfig.builtin)) {
          nonLazyFiles.add(file);
        }
      }
    }

    return nonLazyFiles;
  }

  /// Gets the type name for a file based on config
  static String _getTypeName(AssetLookupFile file, AssetXConfig config) {
    final ext = file.extension;

    // Check config type registry first
    if (config.typeRegistry != null) {
      for (final entry in config.typeRegistry!.entries) {
        final typeName = entry.key;
        final typeConfig = entry.value;

        // Check file extensions
        if (typeConfig.fileExtensions != null &&
            typeConfig.fileExtensions!.contains(ext)) {
          return typeName;
        }

        // Check patterns
        if (typeConfig.pattern != null) {
          for (final pattern in typeConfig.pattern!) {
            if (_matchesPattern(file.normalizedPath, pattern)) {
              return typeName;
            }
          }
        }
      }
    }

    // Fall back to defaults using the same logic as TemplateProcessor
    return _getDefaultTypeName(ext);
  }

  /// Gets default type name based on file extension
  static String _getDefaultTypeName(String extension) {
    // Use the same logic as TemplateProcessor
    for (final entry in typeRegistry.entries) {
      if (entry.value.fileExtensions?.contains(extension) ?? false) {
        return entry.key;
      }
    }
    return 'base';
  }

  /// Checks if a path matches a glob-like pattern
  static bool _matchesPattern(String path, String pattern) {
    // Normalize pattern separators to forward slashes for consistent matching
    final normalizedPattern = pattern.replaceAll('\\', '/');

    // Convert glob pattern to RegExp
    final regexPattern = normalizedPattern
        .replaceAll('*', '.*')
        .replaceAll('?', '.')
        .replaceAll(RegExp(r'\[!([^\]]*)\]'), r'[^$1]')
        .replaceAll(RegExp(r'\[([^\]]*)\]'), r'[$1]');

    try {
      return RegExp('^$regexPattern\$', caseSensitive: false).hasMatch(path);
    } catch (e) {
      // If pattern is invalid, fall back to simple string matching
      return path.contains(normalizedPattern.replaceAll('*', ''));
    }
  }
}
