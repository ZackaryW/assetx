// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;
import '../gen/config.dart';
import '../gen/default.dart';

class AssetLookup {
  late final String path;

  AssetLookup(this.path);

  /// Returns the path with normalized separators (forward slashes)
  String get normalizedPath => path.replaceAll('\\', '/');
}

class AssetLookupFolder extends AssetLookup {
  final AssetLookupFolder? parent;
  bool fullyIndexed;
  final List<AssetLookup> children;
  AssetLookupFolder(String path, this.parent, this.fullyIndexed)
    : children = [],
      super(Directory(path).path);

  /// Prints a pretty tree structure of this folder and its children
  ///
  /// **Parameters:**
  /// - [indent]: Starting indentation (defaults to empty string for root)
  /// - [isLast]: Whether this is the last item at its level (for proper tree drawing)
  /// - [showFiles]: Whether to include files in the tree (defaults to true)
  /// - [maxDepth]: Maximum depth to traverse (null for unlimited)
  /// - [currentDepth]: Current depth level (used internally)
  /// - [validFiles]: List of valid files to show (if null, shows all children)
  ///
  /// **Example:**
  /// ```dart
  /// folder.printTree();
  ///  Output:
  ///  assets/
  ///  ├── images/
  ///  │   ├── logo.png
  ///  │   └── icon.jpg
  ///  └── data/
  ///      └── config.json
  /// ```
  void printTree({
    String indent = '',
    bool isLast = true,
    bool showFiles = true,
    int? maxDepth,
    int currentDepth = 0,
    List<AssetLookupFile>? validFiles,
  }) {
    // Check depth limit
    if (maxDepth != null && currentDepth >= maxDepth) {
      return;
    }

    // Print current folder
    final folderName = p.basename(path);
    final prefix = indent + (isLast ? '└── ' : '├── ');
    print('$prefix$folderName/');

    // Prepare next level indent
    final nextIndent = indent + (isLast ? '    ' : '│   ');

    // Get children - filter files by validFiles if provided
    final folders = children.whereType<AssetLookupFolder>().toList();
    final files = showFiles
        ? children.whereType<AssetLookupFile>().where((file) {
            return validFiles == null || validFiles.contains(file);
          }).toList()
        : <AssetLookupFile>[];

    // Filter folders that have no valid descendants
    final validFolders = folders.where((folder) {
      return folder._hasValidDescendants(validFiles);
    }).toList();

    // Sort folders and files alphabetically
    validFolders.sort(
      (a, b) => p.basename(a.path).compareTo(p.basename(b.path)),
    );
    files.sort((a, b) => a.basename.compareTo(b.basename));

    final allItems = [...validFolders, ...files];

    // Print children
    for (int i = 0; i < allItems.length; i++) {
      final child = allItems[i];
      final isLastChild = i == allItems.length - 1;

      if (child is AssetLookupFolder) {
        child.printTree(
          indent: nextIndent,
          isLast: isLastChild,
          showFiles: showFiles,
          maxDepth: maxDepth,
          currentDepth: currentDepth + 1,
          validFiles: validFiles,
        );
      } else if (child is AssetLookupFile) {
        final filePrefix = nextIndent + (isLastChild ? '└── ' : '├── ');
        print('$filePrefix${child.basename}');
      }
    }
  }

  /// Checks if this folder has any valid descendants (files or folders with valid files)
  bool _hasValidDescendants(List<AssetLookupFile>? validFiles) {
    if (validFiles == null) return true;

    // Check if any direct file children are valid
    final directFiles = children.whereType<AssetLookupFile>();
    if (directFiles.any((file) => validFiles.contains(file))) {
      return true;
    }

    // Check if any subfolder has valid descendants
    final subfolders = children.whereType<AssetLookupFolder>();
    return subfolders.any((folder) => folder._hasValidDescendants(validFiles));
  }

  /// Iterates through all AssetLookup objects in this folder and its subfolders
  ///
  /// **Parameters:**
  /// - [folders]: Whether to include folders in the iteration (defaults to true)
  /// - [files]: Whether to include files in the iteration (defaults to true)
  /// - [patterns]: List of glob patterns to filter results (empty list means no filtering)
  ///
  /// **Returns:** An iterable of AssetLookup objects that match the criteria
  ///
  /// **Example:**
  ///
  /// Get all files with .json extension
  /// ```dart
  /// for (final asset in folder.iterSub(folders: false, patterns: ['*.json'])) {
  ///   if (asset is AssetLookupFile) {
  ///     print('Found JSON: ${asset.basename}');
  ///   }
  /// }
  /// ```
  ///
  /// Get all folders containing 'data' in the name
  /// ```dart
  /// for (final asset in folder.iterSub(files: false, patterns: ['*data*'])) {
  ///   print('Found folder: ${asset.path}');
  /// }
  /// ```
  Iterable<AssetLookup> iterSub({
    bool folders = true,
    bool files = true,
    List<String> patterns = const [],
  }) sync* {
    // Process current folder's children
    for (final child in children) {
      bool shouldYield = false;

      if (child is AssetLookupFolder && folders) {
        shouldYield = true;
      } else if (child is AssetLookupFile && files) {
        shouldYield = true;
      }

      // Apply pattern filtering if patterns are provided
      if (shouldYield && patterns.isNotEmpty) {
        shouldYield = patterns.any(
          (pattern) => _matchesPattern(child.normalizedPath, pattern),
        );
      }

      if (shouldYield) {
        yield child;
      }

      // Recursively process subfolders
      if (child is AssetLookupFolder) {
        yield* child.iterSub(
          folders: folders,
          files: files,
          patterns: patterns,
        );
      }
    }
  }

  /// Generates a list of pubspec asset paths based on folder indexing rules
  ///
  /// **Rules:**
  /// - If folder has subfolders: perform same operation and extend the list
  /// - If folder does not index all: return individual file paths
  /// - If folder indexes all: return the folder path
  ///
  /// **Returns:** List of asset paths for pubspec.yaml
  ///
  /// **Example:**
  /// ```dart
  /// final assetPaths = folder.getPubspecAssetPaths();
  /// Returns: ['assets/images/', 'assets/data/config.json', ...]
  /// ```
  List<String> getPubspecAssetPaths() {
    final paths = <String>[];

    // Get subfolders
    final subfolders = children.whereType<AssetLookupFolder>().toList();

    if (subfolders.isNotEmpty) {
      // Has subfolders - recursively get paths from each
      for (final subfolder in subfolders) {
        paths.addAll(subfolder.getPubspecAssetPaths());
      }
    } else {
      // No subfolders - check indexing rule
      if (fullyIndexed) {
        // Folder indexes all - return folder path with trailing slash
        paths.add('$normalizedPath/');
      } else {
        // Folder does not index all - return individual file paths
        final files = children.whereType<AssetLookupFile>();
        for (final file in files) {
          paths.add(file.normalizedPath);
        }
      }
    }

    return paths;
  }

  /// Returns a string representation of the tree structure
  ///
  /// Same as [printTree] but returns the result as a string instead of printing
  ///
  /// **Example:**
  /// ```dart
  /// final treeString = folder.getTreeString();
  /// print(treeString);
  /// ```
  String getTreeString({
    String indent = '',
    bool isLast = true,
    bool showFiles = true,
    int? maxDepth,
    int currentDepth = 0,
  }) {
    final buffer = StringBuffer();

    // Check depth limit
    if (maxDepth != null && currentDepth >= maxDepth) {
      return buffer.toString();
    }

    // Add current folder
    final folderName = p.basename(path);
    final prefix = indent + (isLast ? '└── ' : '├── ');
    buffer.writeln('$prefix$folderName/');

    // Prepare next level indent
    final nextIndent = indent + (isLast ? '    ' : '│   ');

    // Sort children: folders first, then files
    final folders = children.whereType<AssetLookupFolder>().toList();
    final files = showFiles
        ? children.whereType<AssetLookupFile>().toList()
        : <AssetLookupFile>[];

    // Sort folders and files alphabetically
    folders.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    files.sort((a, b) => a.basename.compareTo(b.basename));

    final allItems = [...folders, ...files];

    // Add children
    for (int i = 0; i < allItems.length; i++) {
      final child = allItems[i];
      final isLastChild = i == allItems.length - 1;

      if (child is AssetLookupFolder) {
        buffer.write(
          child.getTreeString(
            indent: nextIndent,
            isLast: isLastChild,
            showFiles: showFiles,
            maxDepth: maxDepth,
            currentDepth: currentDepth + 1,
          ),
        );
      } else if (child is AssetLookupFile) {
        final filePrefix = nextIndent + (isLastChild ? '└── ' : '├── ');
        buffer.writeln('$filePrefix${child.basename}');
      }
    }

    return buffer.toString();
  }
}

class AssetLookupFile extends AssetLookup {
  final AssetLookupFolder? parent;

  AssetLookupFile(String path, this.parent) : super(File(path).path);

  String get basename => p.basename(path);
  String get extension =>
      basename.contains('.') ? '.${basename.split('.').last}' : '';
}

/// Result of asset discovery containing all found files and folders
class AssetDiscoveryResult {
  final List<AssetLookupFile> files;
  final List<AssetLookupFolder> folders;
  final bool wasFiltered; // Track if any filtering actually occurred

  const AssetDiscoveryResult(this.files, this.folders, this.wasFiltered);
}

/// Discovers all assets based on AssetXConfig rules
///
/// Recursively scans directories according to the configuration and
/// returns all files and folders that match the inclusion/exclusion rules.
///
/// **Parameters:**
/// - [config]: The AssetX configuration containing source paths and patterns
/// - [baseDir]: Optional base directory for resolving relative paths (defaults to current directory)
///
/// **Returns:** [AssetDiscoveryResult] containing lists of discovered files and folders
///
/// **Process:**
/// 1. Processes all sources_include paths
/// 2. Applies recursive scanning if enabled
/// 3. Filters by patterns_include (if specified)
/// 4. Removes files matching patterns_exclude
/// 5. Removes files from sources_exclude paths
/// 6. Respects ignore patterns within each source
///
/// **Example:**
/// ```dart
/// final config = AssetXConfig.fromJson(configMap);
/// final result = await discoverAssets(config);
///
/// for (final file in result.files) {
///   print('Found file: ${file.path}');
/// }
/// ```
Future<AssetDiscoveryResult> discoverAssets(
  AssetXConfig config, {
  String? baseDir,
}) async {
  final workingDir = baseDir ?? Directory.current.path;
  final allFiles = <AssetLookupFile>[];
  final allFolders = <AssetLookupFolder>[];
  int filesSkipped = 0; // Track actually skipped files

  // Process included sources (initially assume fully indexed)
  if (config.sourcesInclude != null) {
    for (final source in config.sourcesInclude!) {
      final sourcePath = p.isAbsolute(source.path)
          ? source.path
          : p.join(workingDir, source.path);

      final sourceDir = Directory(sourcePath);
      if (!await sourceDir.exists()) {
        continue; // Skip non-existent paths
      }

      final result = await _scanDirectory(
        sourcePath,
        source.recursive ?? false,
        source.ignore ?? [],
        null, // parent folder
        true, // Initially assume fully indexed
      );

      allFiles.addAll(result.files);
      allFolders.addAll(result.folders);
      filesSkipped += result.wasFiltered
          ? 1
          : 0; // Track if scanning had filtering
    }
  }

  final originalFileCount = allFiles.length;
  var filteredFiles = allFiles;

  // Filter by include patterns
  if (config.patternsInclude != null && config.patternsInclude!.isNotEmpty) {
    filteredFiles = allFiles.where((file) {
      return config.patternsInclude!.any(
        (pattern) => _matchesPattern(file.normalizedPath, pattern),
      );
    }).toList();
    filesSkipped += originalFileCount - filteredFiles.length;
  }

  // Remove files matching exclude patterns
  if (config.patternsExclude != null) {
    final beforeExclude = filteredFiles.length;
    filteredFiles = filteredFiles.where((file) {
      return !config.patternsExclude!.any(
        (pattern) => _matchesPattern(file.normalizedPath, pattern),
      );
    }).toList();
    filesSkipped += beforeExclude - filteredFiles.length;
  }

  // Remove files from excluded sources
  if (config.sourcesExclude != null) {
    final beforeSourceExclude = filteredFiles.length;
    for (final excludeSource in config.sourcesExclude!) {
      final excludePath = p.isAbsolute(excludeSource.path)
          ? excludeSource.path
          : p.join(workingDir, excludeSource.path);

      filteredFiles = filteredFiles.where((file) {
        if (excludeSource.recursive ?? false) {
          return !file.path.startsWith(excludePath);
        } else {
          return p.dirname(file.path) != excludePath;
        }
      }).toList();
    }
    filesSkipped += beforeSourceExclude - filteredFiles.length;
  }

  final wasFiltered = filesSkipped > 0;

  // Update folder children to only contain filtered files
  _updateFolderChildren(allFolders, filteredFiles);

  // Update fullyIndexed status based on whether each folder lost any files
  _updateFolderIndexingStatus(allFolders);

  return AssetDiscoveryResult(filteredFiles, allFolders, wasFiltered);
}

/// Recursively scans a directory and returns all files and folders
Future<AssetDiscoveryResult> _scanDirectory(
  String dirPath,
  bool recursive,
  List<String> ignorePatterns,
  AssetLookupFolder? parent,
  bool fullyIndexed,
) async {
  final files = <AssetLookupFile>[];
  final folders = <AssetLookupFolder>[];
  var itemsSkipped = 0;

  final dir = Directory(dirPath);
  final folderRelativePath = p.relative(dirPath, from: Directory.current.path);
  final currentFolder = AssetLookupFolder(
    folderRelativePath,
    parent,
    fullyIndexed,
  );
  folders.add(currentFolder);

  try {
    await for (final entity in dir.list()) {
      final relativePath = p.relative(
        entity.path,
        from: Directory.current.path,
      );

      // Check if this entity should be ignored
      if (ignorePatterns.any(
        (pattern) => _matchesPattern(
          p
              .relative(entity.path, from: Directory.current.path)
              .replaceAll('\\', '/'),
          pattern,
        ),
      )) {
        itemsSkipped++; // Track when we skip items due to ignore patterns
        continue;
      }

      if (entity is File) {
        final file = AssetLookupFile(relativePath, currentFolder);
        files.add(file);
        currentFolder.children.add(file); // Add file to parent's children
      } else if (entity is Directory && recursive) {
        final subResult = await _scanDirectory(
          entity.path,
          recursive,
          ignorePatterns,
          currentFolder,
          fullyIndexed,
        );
        files.addAll(subResult.files);
        folders.addAll(subResult.folders);

        // Track filtering from sub-directories
        if (subResult.wasFiltered) {
          itemsSkipped++;
        }

        // Find the immediate child folder (first folder in subResult that has currentFolder as parent)
        final childFolder = subResult.folders.firstWhere(
          (f) => f.parent == currentFolder,
          orElse: () => AssetLookupFolder(
            p.relative(entity.path, from: Directory.current.path),
            currentFolder,
            fullyIndexed,
          ),
        );
        currentFolder.children.add(childFolder);
      } else if (entity is Directory) {
        // Add folder even if not recursive
        final folder = AssetLookupFolder(
          relativePath,
          currentFolder,
          fullyIndexed,
        );
        folders.add(folder);
        currentFolder.children.add(folder); // Add folder to parent's children
      }
    }
  } catch (e) {
    // Handle permission errors or other I/O issues
    print('Warning: Could not scan directory $dirPath: $e');
  }

  return AssetDiscoveryResult(files, folders, itemsSkipped > 0);
}

/// Updates folder children to only contain filtered files
void _updateFolderChildren(
  List<AssetLookupFolder> folders,
  List<AssetLookupFile> validFiles,
) {
  for (final folder in folders) {
    // Remove files that are not in the validFiles list
    folder.children.removeWhere((child) {
      if (child is AssetLookupFile) {
        return !validFiles.contains(child);
      }
      return false; // Keep all folders
    });
  }
}

/// Updates fullyIndexed status for each folder based on whether it lost any files
void _updateFolderIndexingStatus(List<AssetLookupFolder> folders) {
  for (final folder in folders) {
    // A folder is fully indexed if it has at least one file and no files were filtered out
    // We can determine this by checking if the folder has any files after filtering
    final hasFiles = folder.children.whereType<AssetLookupFile>().isNotEmpty;
    folder.fullyIndexed = hasFiles;
  }
}

/// Extensions for code generation support
extension AssetLookupFileCodeGen on AssetLookupFile {
  /// Converts file path to dot notation
  /// "assets/data/config.json" -> "assets.data.config" (without extension)
  String get dotPath =>
      _pathToDotNotation(normalizedPath, includeExtension: false);

  /// Converts file path to dot notation with extension for disambiguation
  /// "assets/data/config.json" -> "assets.data.config_json"
  String get dotPathWithExtension {
    final basePath = _pathToDotNotation(
      normalizedPath,
      includeExtension: false,
    );
    final ext = extension.replaceFirst('.', '').toLowerCase();
    return '${basePath}_$ext';
  }

  /// Determines asset type based on config
  String getAssetType(AssetXConfig config) {
    final ext = extension;

    // Check config type registry first
    if (config.typeRegistry != null) {
      for (final entry in config.typeRegistry!.entries) {
        final typeName = entry.key;
        final typeConfig = entry.value;

        // Check file extensions
        if (typeConfig.fileExtensions != null &&
            typeConfig.fileExtensions!.contains(ext)) {
          return _getImplementationForType(typeName, config);
        }

        // Check patterns
        if (typeConfig.pattern != null) {
          for (final pattern in typeConfig.pattern!) {
            if (_matchesPattern(normalizedPath, pattern)) {
              return _getImplementationForType(typeName, config);
            }
          }
        }
      }
    }

    // Fall back to defaults
    return _getImplementationForType(_getDefaultTypeName(ext), config);
  }

  /// Gets the implementation class/method for a type name
  String _getImplementationForType(String typeName, AssetXConfig config) {
    // Check config map registry first
    if (config.mapRegistry != null &&
        config.mapRegistry!.containsKey(typeName)) {
      final mapConfig = config.mapRegistry![typeName]!;

      if (mapConfig.builtin != null) {
        final builtin = mapConfig.builtin!;
        return builtinTypeMapping[builtin] ?? 'BaseX';
      }

      if (mapConfig.src != null) {
        return 'Custom'; // TODO: Parse src format like "lib/models.dart::Custom"
      }
    }

    // Fall back to defaults from default.dart
    if (mapRegistry.containsKey(typeName)) {
      final defaultMapConfig = mapRegistry[typeName]!;
      if (defaultMapConfig.builtin != null) {
        final builtin = defaultMapConfig.builtin!;
        return builtinTypeMapping[builtin] ?? 'BaseX';
      }
    }

    return 'BaseX';
  }

  /// Gets default type name based on file extension
  String _getDefaultTypeName(String extension) {
    for (final entry in typeRegistry.entries) {
      if (entry.value.fileExtensions?.contains(extension) ?? false) {
        return entry.key;
      }
    }
    return 'base';
  }
}

extension AssetLookupFolderCodeGen on AssetLookupFolder {
  /// Converts folder path to dot notation
  /// "assets/data" -> "assets.data"
  String get dotPath => _pathToDotNotation(normalizedPath);

  /// Generates unique class name for this folder
  String generateClassName(int counter) =>
      '\$c${counter.toString().padLeft(4, '0')}';

  /// Generates instance name from class name
  String generateInstanceName(String className) => '${className}Instance';

  /// Gets folder name for display
  String get folderName => p.basename(path);

  /// Gets child files as AssetLookupFile objects
  List<AssetLookupFile> get childFiles =>
      children.whereType<AssetLookupFile>().toList();

  /// Gets child folders as AssetLookupFolder objects
  List<AssetLookupFolder> get childFolders =>
      children.whereType<AssetLookupFolder>().toList();
}

/// Converts file path to dot notation
String _pathToDotNotation(String path, {bool includeExtension = false}) {
  String processedPath = path.replaceAll('\\', '/');
  processedPath = processedPath.replaceAll('/', '.');

  if (!includeExtension && processedPath.contains('.')) {
    final lastDot = processedPath.lastIndexOf('.');
    final beforeLastDot = processedPath.substring(0, lastDot).lastIndexOf('.');
    if (beforeLastDot != -1) {
      processedPath = processedPath.substring(0, lastDot);
    }
  }

  return processedPath;
}

/// Checks if a path matches a glob-like pattern
bool _matchesPattern(String path, String pattern) {
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
