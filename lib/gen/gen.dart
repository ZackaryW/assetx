import 'package:assetx/gen/default.dart';

import '../gen/config.dart';
import '../utils/codebuffer.dart';
import '../utils/lookup.dart';

/// Utility methods for code generation using AssetLookup objects
class TemplateProcessor {
  /// Generates the complete file content from AssetLookup objects
  static String generateFile(
    List<AssetLookupFile> files,
    List<AssetLookupFolder> folders,
    AssetXConfig config,
    String packageName, {
    bool usePackagePrefix = true,
  }) {
    final buffer = CodeBuffer();

    // Add necessary imports
    buffer.addImport('// ignore_for_file: non_constant_identifier_names');
    buffer.addImport('import \'package:assetx/objectx/objectx.dart\';');

    // Generate instance mapping with conflict resolution
    _generateInstanceMap(buffer, files, config, packageName, usePackagePrefix);

    // Generate folder structures
    _generateFolderStructures(buffer, folders, files, config);

    return buffer.generate();
  }

  /// Generates instance mapping with conflict resolution using CodeBuffer
  static void _generateInstanceMap(
    CodeBuffer buffer,
    List<AssetLookupFile> files,
    AssetXConfig config,
    String packageName,
    bool usePackagePrefix,
  ) {
    buffer.addCode('// Instance mapping');
    buffer.addCode('final Map<String, dynamic> instanceMap = {');

    // Resolve conflicts: files with same base dot path get extension suffix
    final conflictTracker = <String, List<AssetLookupFile>>{};

    // First pass: detect conflicts
    for (final file in files) {
      final baseDotPath = file.dotPath;
      conflictTracker.putIfAbsent(baseDotPath, () => []).add(file);
    }

    // Second pass: generate entries with resolved paths
    final entries = <String>[];
    final imports = <String>{};

    for (final file in files) {
      final baseDotPath = file.dotPath;
      final hasConflict = conflictTracker[baseDotPath]!.length > 1;

      final finalDotPath = hasConflict
          ? file.dotPathWithExtension
          : baseDotPath;

      final instantiationResult = _generateInstantiation(
        file,
        config,
        packageName,
        usePackagePrefix,
      );
      imports.addAll(instantiationResult.imports);

      entries.add('  "$finalDotPath": ${instantiationResult.code}');
    }

    // Add additional imports to buffer
    for (final import in imports) {
      buffer.addImport(import);
    }

    buffer.addCode(entries.join(',\n'));
    buffer.addCode('};');
    buffer.addCode('');
  }

  /// Generates folder structures using CodeBuffer
  static void _generateFolderStructures(
    CodeBuffer buffer,
    List<AssetLookupFolder> folders,
    List<AssetLookupFile> files,
    AssetXConfig config,
  ) {
    buffer.addCode('// Generated Folder Structure');

    // Separate root folders (those without parents) and non-root folders
    final rootFolders = folders.where((f) => f.parent == null).toList();
    final nonRootFolders = folders.where((f) => f.parent != null).toList();

    // Keep track of folders for AssetMap generation
    final assetMapEntries = <String, String>{};

    int folderCounter = 0;

    // Generate classes for non-root folders (subdirectories)
    for (final folder in nonRootFolders) {
      final className = folder.generateClassName(folderCounter);
      final instanceName = folder.generateInstanceName(className);

      // Generate folder class
      buffer.addCode('class $className extends FolderX {');
      buffer.addCode('  const $className() : super(\'${folder.folderName}\');');

      // Generate getters for file children
      for (final childFile in folder.childFiles) {
        final getterName = _generateGetterName(childFile, files, config);
        final dotPath = _resolveDotPath(childFile, files);
        buffer.addCode('  get $getterName => instanceMap["$dotPath"];');
      }

      // Generate getters for subfolder children
      for (final childFolder in folder.childFolders) {
        final subfolderIndex = nonRootFolders.indexOf(childFolder);
        if (subfolderIndex != -1) {
          final subfolderClassName = childFolder.generateClassName(
            subfolderIndex,
          );
          final subfolderInstanceName = childFolder.generateInstanceName(
            subfolderClassName,
          );
          buffer.addCode(
            '  get ${childFolder.folderName} => $subfolderInstanceName;',
          );
        }
      }

      buffer.addCode('}');
      buffer.addCode('final $instanceName = $className();');
      buffer.addCode('');

      folderCounter++;
    }

    // Generate classes for root folders and collect them for AssetMap
    for (final rootFolder in rootFolders) {
      final className = rootFolder.generateClassName(folderCounter);
      final instanceName = rootFolder.generateInstanceName(className);

      // Generate folder class
      buffer.addCode('class $className extends FolderX {');
      buffer.addCode(
        '  const $className() : super(\'${rootFolder.folderName}\');',
      );

      // Generate getters for file children
      for (final childFile in rootFolder.childFiles) {
        final getterName = _generateGetterName(childFile, files, config);
        final dotPath = _resolveDotPath(childFile, files);
        buffer.addCode('  get $getterName => instanceMap["$dotPath"];');
      }

      // Generate getters for subfolder children
      for (final childFolder in rootFolder.childFolders) {
        final subfolderIndex = nonRootFolders.indexOf(childFolder);
        if (subfolderIndex != -1) {
          final subfolderClassName = childFolder.generateClassName(
            subfolderIndex,
          );
          final subfolderInstanceName = childFolder.generateInstanceName(
            subfolderClassName,
          );
          buffer.addCode(
            '  get ${childFolder.folderName} => $subfolderInstanceName;',
          );
        }
      }

      buffer.addCode('}');
      buffer.addCode('final $instanceName = $className();');
      buffer.addCode('');

      // Add root folder to AssetMap
      assetMapEntries[rootFolder.folderName] = instanceName;

      folderCounter++;
    }

    // Generate AssetMap class
    _generateAssetMapClass(buffer, assetMapEntries);
  }

  /// Generates getter name for a file, handling conflicts
  static String _generateGetterName(
    AssetLookupFile file,
    List<AssetLookupFile> allFiles,
    AssetXConfig config,
  ) {
    // Check if there are conflicting files with the same base name in the same folder
    final sameFolderFiles = allFiles
        .where(
          (f) =>
              f.parent == file.parent &&
              f.basename.split('.').first == file.basename.split('.').first,
        )
        .toList();

    if (sameFolderFiles.length > 1) {
      // Has conflicts - use basename with extension
      final baseName = file.basename.split('.').first;
      final extension = file.extension.replaceFirst('.', '').toLowerCase();
      return '${baseName}_$extension';
    } else {
      // No conflicts - use just basename
      return file.basename.split('.').first;
    }
  }

  /// Resolves the dot path for a file, handling conflicts
  static String _resolveDotPath(
    AssetLookupFile file,
    List<AssetLookupFile> allFiles,
  ) {
    // Check for conflicts with same base dot path
    final baseDotPath = file.dotPath;
    final conflicting = allFiles
        .where((f) => f.dotPath == baseDotPath)
        .toList();

    if (conflicting.length > 1) {
      return file.dotPathWithExtension;
    } else {
      return baseDotPath;
    }
  }

  /// Generates the AssetMap class with static getters
  static void _generateAssetMapClass(
    CodeBuffer buffer,
    Map<String, String> assetMapEntries,
  ) {
    if (assetMapEntries.isEmpty) return;

    buffer.addCode('// AssetMap class for easy access to all root folders');
    buffer.addCode('class AssetMap {');
    buffer.addCode('  AssetMap._();');
    buffer.addCode('');

    // Generate static getters for each root folder
    for (final entry in assetMapEntries.entries) {
      final getterName = entry.key;
      final instanceName = entry.value;
      buffer.addCode('  static get $getterName => $instanceName;');
    }

    buffer.addCode('}');
  }

  /// Generates instantiation code for a file based on config
  static _InstantiationResult _generateInstantiation(
    AssetLookupFile file,
    AssetXConfig config,
    String packageName,
    bool usePackagePrefix,
  ) {
    final imports = <String>{};
    final typeName = _getTypeName(file, config);

    // Check if this is a custom type
    if (config.mapRegistry != null &&
        config.mapRegistry!.containsKey(typeName)) {
      final mapConfig = config.mapRegistry![typeName]!;

      if (mapConfig.src != null) {
        // Parse src: "lib/models.dart::Custom3.fromDict"
        final srcParts = mapConfig.src!.split('::');
        if (srcParts.length == 2) {
          final importPath = srcParts[0];
          final classMethod = srcParts[1];

          // Remove "lib/" prefix if present and add package prefix for custom imports
          final cleanImportPath = importPath.startsWith('lib/')
              ? importPath.substring(4)
              : importPath;

          // Add package import for custom types
          imports.add('import \'package:$packageName/$cleanImportPath\';');

          // Generate instantiation based on passIn
          final passIn = mapConfig.passIn?.toLowerCase();
          String code;

          // Create asset path with optional package prefix
          final assetPath = usePackagePrefix
              ? 'packages/$packageName/${file.normalizedPath}'
              : file.normalizedPath;

          if (passIn == 'json') {
            imports.add('import \'dart:convert\';');
            imports.add('import \'package:flutter/services.dart\';');
            code =
                '$classMethod(jsonDecode(await rootBundle.loadString("$assetPath")))';
          } else if (passIn == 'path') {
            code = '$classMethod("$assetPath")';
          } else {
            // Default: pass path as first parameter
            code = '$classMethod("$assetPath")';
          }

          return _InstantiationResult(code, imports);
        }
      }

      if (mapConfig.builtin != null) {
        final builtin = mapConfig.builtin!;
        final className = builtinTypeMapping[builtin] ?? 'BaseX';
        final assetPath = usePackagePrefix
            ? 'packages/$packageName/${file.normalizedPath}'
            : file.normalizedPath;
  
        // check and generate non lazy option
        final lazy = mapConfig.lazy;
        if (!lazy) {
          return _InstantiationResult('$className("$assetPath", lazy: false)', imports);
        }

        return _InstantiationResult('$className("$assetPath")', imports);
      }
    }

    // Fall back to defaults
    final className = file.getAssetType(config);
    final assetPath = usePackagePrefix
        ? 'packages/$packageName/${file.normalizedPath}'
        : file.normalizedPath;
    return _InstantiationResult('$className("$assetPath")', imports);
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

    // Fall back to defaults
    return _getDefaultTypeName(ext);
  }

  /// Gets default type name based on file extension
  static String _getDefaultTypeName(String extension) {
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

/// Result of instantiation code generation
class _InstantiationResult {
  final String code;
  final Set<String> imports;

  const _InstantiationResult(this.code, this.imports);
}
