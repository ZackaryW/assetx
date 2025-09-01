import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

/// Root configuration class for AssetX configuration files.
///
/// This class represents the complete structure of an AssetX configuration
/// file, typically parsed from YAML using YamlUtils.parseYamlToJson().
///
/// **Example usage:**
/// ```dart
/// final yamlContent = await File('assetx.yaml').readAsString();
/// final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
/// final config = AssetXConfig.fromJson(jsonMap);
/// ```
@JsonSerializable()
class AssetXConfig {
  /// Output file destination for generated code
  final String destination;

  /// Local output file destination for testing (without package prefixes)
  @JsonKey(name: 'local_destination')
  final String? localDestination;

  /// Cache configuration settings
  final CacheConfig? cache;

  /// Source paths to include for asset processing
  @JsonKey(name: 'sources_include')
  final List<SourceConfig>? sourcesInclude;

  /// Source paths to exclude from asset processing
  @JsonKey(name: 'sources_exclude')
  final List<SourceConfig>? sourcesExclude;

  /// File patterns to include (glob patterns)
  @JsonKey(name: 'patterns_include')
  final List<String>? patternsInclude;

  /// File patterns to exclude (glob patterns)
  @JsonKey(name: 'patterns_exclude')
  final List<String>? patternsExclude;

  /// Type registry for mapping file types to asset types
  @JsonKey(name: 'type_registry')
  final Map<String, TypeConfig>? typeRegistry;

  /// Map registry for mapping asset types to implementation classes
  @JsonKey(name: 'map_registry')
  final Map<String, MapConfig>? mapRegistry;

  const AssetXConfig({
    required this.destination,
    this.localDestination,
    this.cache,
    this.sourcesInclude,
    this.sourcesExclude,
    this.patternsInclude,
    this.patternsExclude,
    this.typeRegistry,
    this.mapRegistry,
  });

  factory AssetXConfig.fromJson(Map<String, dynamic> json) =>
      _$AssetXConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AssetXConfigToJson(this);
}

/// Cache configuration for AssetX processing
@JsonSerializable()
class CacheConfig {
  /// Whether to use memory caching
  final bool? memory;

  /// Source file for cache implementation
  final String? src;

  const CacheConfig({this.memory, this.src});

  factory CacheConfig.fromJson(Map<String, dynamic> json) =>
      _$CacheConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CacheConfigToJson(this);
}

/// Source path configuration for asset inclusion/exclusion
@JsonSerializable()
class SourceConfig {
  /// Path to the source directory or file
  final String path;

  /// Whether to process the path recursively
  final bool? recursive;

  /// Patterns to ignore within this source path
  final List<String>? ignore;

  const SourceConfig({required this.path, this.recursive, this.ignore});

  factory SourceConfig.fromJson(Map<String, dynamic> json) =>
      _$SourceConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SourceConfigToJson(this);
}

/// Type configuration for mapping file extensions or patterns to asset types
@JsonSerializable()
class TypeConfig {
  /// File extensions associated with this type
  @JsonKey(name: 'file_extensions')
  final List<String>? fileExtensions;

  /// Patterns for matching files to this type
  final List<String>? pattern;

  const TypeConfig({this.fileExtensions, this.pattern});

  factory TypeConfig.fromJson(Map<String, dynamic> json) =>
      _$TypeConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TypeConfigToJson(this);
}

/// Map configuration for mapping asset types to implementation classes
@JsonSerializable()
class MapConfig {
  /// Built-in type name (e.g., 'imagex', 'datax', 'envx')
  final String? builtin;

  /// Source file and class for custom implementations
  /// Format: "lib/file.dart::ClassName" or "lib/file.dart::ClassName.method"
  final String? src;

  /// Parameter passing mode for custom implementations
  /// Values: 'path', 'json', etc.
  @JsonKey(name: 'passIn')
  final String? passIn;

  const MapConfig({this.builtin, this.src, this.passIn});

  factory MapConfig.fromJson(Map<String, dynamic> json) =>
      _$MapConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MapConfigToJson(this);
}
