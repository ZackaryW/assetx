import 'dart:io';
import 'package:yaml/yaml.dart';
import 'builtin.dart';

class ConfigEntry {
  final String path;
  final String type;
  final List<String> exclusions;
  final bool recursive;

  ConfigEntry({
    required this.path,
    required this.type,
    this.exclusions = const [],
    this.recursive = false,
  }) {
    // Validate that type is a builtin type
    if (!BUILTIN_TYPES.contains(type)) {
      throw ArgumentError(
        'Invalid asset type "$type". Must be one of: ${BUILTIN_TYPES.join(', ')}',
      );
    }
  }

  factory ConfigEntry.fromYaml(Map<String, dynamic> yaml) {
    final type = yaml['type'] as String;

    return ConfigEntry(
      path: yaml['path'] as String,
      type: type,
      exclusions:
          (yaml['exclusions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recursive: yaml['recursive'] as bool? ?? false,
    );
  }

  /// Check if this entry is for hardcode (embedded) assets
  bool get isHardcode => type.endsWith('_hard');

  /// Check if this entry is for soft (asset loading) assets
  bool get isSoft => type.endsWith('_soft');

  /// Get the base asset category (image, kv, etc.)
  String get baseType {
    if (type.endsWith('_hard')) {
      return type.substring(0, type.length - 5); // Remove '_hard'
    } else if (type.endsWith('_soft')) {
      return type.substring(0, type.length - 5); // Remove '_soft'
    }
    return type; // Fallback for custom types
  }

  Map<String, dynamic> toYaml() {
    return {
      'path': path,
      'type': type,
      'exclusions': exclusions,
      'recursive': recursive,
    };
  }
}

class Config {
  final String generationTarget;

  final List<ConfigEntry> entries;

  Config(this.entries, {this.generationTarget = 'lib/asset.dart'});

  static Future<Config> load([String? configPath]) async {
    // Default to assetx.yaml in current directory
    configPath ??= 'assetx.yaml';

    final file = File(configPath);
    if (!await file.exists()) {
      throw FileSystemException('Configuration file not found: $configPath');
    }

    final content = await file.readAsString();
    final yamlDoc = loadYaml(content);

    if (yamlDoc == null) {
      return Config([]);
    }

    // Handle both direct list format and entries key format
    List<dynamic> entriesData;
    if (yamlDoc is List) {
      entriesData = yamlDoc;
    } else if (yamlDoc is Map && yamlDoc['entries'] != null) {
      entriesData = yamlDoc['entries'];
    } else {
      throw FormatException('Invalid configuration format');
    }

    final entries = entriesData
        .map((entry) => ConfigEntry.fromYaml(Map<String, dynamic>.from(entry)))
        .toList();

    return Config(entries);
  }

  Future<void> save(String configPath) async {
    final file = File(configPath);

    // Convert to YAML format manually for better control
    final buffer = StringBuffer();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.writeln('- path: "${entry.path}"');
      buffer.writeln('  type: "${entry.type}"');
      if (entry.exclusions.isNotEmpty) {
        buffer.writeln('  exclusions:');
        for (final exclusion in entry.exclusions) {
          buffer.writeln('    - "$exclusion"');
        }
      }
      if (entry.recursive) {
        buffer.writeln('  recursive: true');
      }
      if (i < entries.length - 1) {
        buffer.writeln();
      }
    }

    await file.writeAsString(buffer.toString());
  }

  /// Get all entries with hardcode types
  List<ConfigEntry> get hardcodeEntries =>
      entries.where((entry) => entry.isHardcode).toList();

  /// Get all entries with soft types
  List<ConfigEntry> get softEntries =>
      entries.where((entry) => entry.isSoft).toList();

  /// Get entries by base type (e.g., 'image', 'kv')
  List<ConfigEntry> getEntriesByBaseType(String baseType) =>
      entries.where((entry) => entry.baseType == baseType).toList();

  /// Validate configuration for common issues
  void validate() {
    final invalidTypes = entries
        .where((entry) => !BUILTIN_TYPES.contains(entry.type))
        .toList();

    if (invalidTypes.isNotEmpty) {
      throw FormatException(
        'Invalid types found: ${invalidTypes.map((e) => e.type).join(', ')}',
      );
    }

    // Check for duplicate paths with different types
    final pathTypeMap = <String, Set<String>>{};
    for (final entry in entries) {
      pathTypeMap.putIfAbsent(entry.path, () => <String>{}).add(entry.type);
    }

    final conflicts = pathTypeMap.entries
        .where((entry) => entry.value.length > 1)
        .toList();

    if (conflicts.isNotEmpty) {
      throw FormatException(
        'Path conflicts found: ${conflicts.map((e) => '${e.key}: ${e.value.join(', ')}').join('; ')}',
      );
    }
  }
}
