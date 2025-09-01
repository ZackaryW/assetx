// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetXConfig _$AssetXConfigFromJson(Map<String, dynamic> json) => AssetXConfig(
  destination: json['destination'] as String,
  localDestination: json['local_destination'] as String?,
  cache: json['cache'] == null
      ? null
      : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>),
  sourcesInclude: (json['sources_include'] as List<dynamic>?)
      ?.map((e) => SourceConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  sourcesExclude: (json['sources_exclude'] as List<dynamic>?)
      ?.map((e) => SourceConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  patternsInclude: (json['patterns_include'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  patternsExclude: (json['patterns_exclude'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  typeRegistry: (json['type_registry'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, TypeConfig.fromJson(e as Map<String, dynamic>)),
  ),
  mapRegistry: (json['map_registry'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, MapConfig.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$AssetXConfigToJson(AssetXConfig instance) =>
    <String, dynamic>{
      'destination': instance.destination,
      'local_destination': instance.localDestination,
      'cache': instance.cache,
      'sources_include': instance.sourcesInclude,
      'sources_exclude': instance.sourcesExclude,
      'patterns_include': instance.patternsInclude,
      'patterns_exclude': instance.patternsExclude,
      'type_registry': instance.typeRegistry,
      'map_registry': instance.mapRegistry,
    };

CacheConfig _$CacheConfigFromJson(Map<String, dynamic> json) =>
    CacheConfig(memory: json['memory'] as bool?, src: json['src'] as String?);

Map<String, dynamic> _$CacheConfigToJson(CacheConfig instance) =>
    <String, dynamic>{'memory': instance.memory, 'src': instance.src};

SourceConfig _$SourceConfigFromJson(Map<String, dynamic> json) => SourceConfig(
  path: json['path'] as String,
  recursive: json['recursive'] as bool?,
  ignore: (json['ignore'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$SourceConfigToJson(SourceConfig instance) =>
    <String, dynamic>{
      'path': instance.path,
      'recursive': instance.recursive,
      'ignore': instance.ignore,
    };

TypeConfig _$TypeConfigFromJson(Map<String, dynamic> json) => TypeConfig(
  fileExtensions: (json['file_extensions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  pattern: (json['pattern'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TypeConfigToJson(TypeConfig instance) =>
    <String, dynamic>{
      'file_extensions': instance.fileExtensions,
      'pattern': instance.pattern,
    };

MapConfig _$MapConfigFromJson(Map<String, dynamic> json) => MapConfig(
  builtin: json['builtin'] as String?,
  src: json['src'] as String?,
  passIn: json['passIn'] as String?,
);

Map<String, dynamic> _$MapConfigToJson(MapConfig instance) => <String, dynamic>{
  'builtin': instance.builtin,
  'src': instance.src,
  'passIn': instance.passIn,
};
