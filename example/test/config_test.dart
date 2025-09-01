import 'package:flutter_test/flutter_test.dart';
import 'package:assetx/gen/config.dart';
import 'package:assetx/utils/yaml.dart';

void main() {
  group('AssetXConfig Tests', () {
    test('parses simple YAML configuration correctly', () {
      const yamlContent = '''
destination: lib/generated_assets.dart
cache:
  memory: true
  src: lib/cache.dart
sources_include:
  - path: assets/
    recursive: true
patterns_include:
  - "*.png"
  - "*.json"
''';

      final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
      final config = AssetXConfig.fromJson(jsonMap);

      expect(config.destination, equals('lib/generated_assets.dart'));
      expect(config.cache?.memory, isTrue);
      expect(config.cache?.src, equals('lib/cache.dart'));
      expect(config.sourcesInclude?.length, equals(1));
      expect(config.sourcesInclude?.first.path, equals('assets/'));
      expect(config.sourcesInclude?.first.recursive, isTrue);
      expect(config.patternsInclude?.length, equals(2));
      expect(config.patternsInclude, contains('*.png'));
      expect(config.patternsInclude, contains('*.json'));
    });

    test('parses complex configuration with type and map registry', () {
      const yamlContent = '''
destination: output.dart
type_registry:
  image:
    file_extensions:
      - png
      - jpg
  custom:
    pattern:
      - "*/data.json"
map_registry:
  image:
    builtin: imagex
  custom:
    src: "lib/custom.dart::Custom"
    passIn: path
''';

      final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
      final config = AssetXConfig.fromJson(jsonMap);

      expect(config.destination, equals('output.dart'));
      expect(config.typeRegistry?.length, equals(2));
      expect(config.typeRegistry?['image']?.fileExtensions, contains('png'));
      expect(config.typeRegistry?['image']?.fileExtensions, contains('jpg'));
      expect(config.typeRegistry?['custom']?.pattern, contains('*/data.json'));

      expect(config.mapRegistry?.length, equals(2));
      expect(config.mapRegistry?['image']?.builtin, equals('imagex'));
      expect(
        config.mapRegistry?['custom']?.src,
        equals('lib/custom.dart::Custom'),
      );
      expect(config.mapRegistry?['custom']?.passIn, equals('path'));
    });

    test('handles optional fields correctly', () {
      const yamlContent = '''
destination: simple.dart
''';

      final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
      final config = AssetXConfig.fromJson(jsonMap);

      expect(config.destination, equals('simple.dart'));
      expect(config.cache, isNull);
      expect(config.sourcesInclude, isNull);
      expect(config.sourcesExclude, isNull);
      expect(config.patternsInclude, isNull);
      expect(config.patternsExclude, isNull);
      expect(config.typeRegistry, isNull);
      expect(config.mapRegistry, isNull);
    });

    test('SourceConfig with ignore patterns', () {
      const yamlContent = '''
destination: test.dart
sources_include:
  - path: assets/
    recursive: true
    ignore:
      - "*.tmp"
      - "*.log"
''';

      final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
      final config = AssetXConfig.fromJson(jsonMap);

      final source = config.sourcesInclude?.first;
      expect(source?.path, equals('assets/'));
      expect(source?.recursive, isTrue);
      expect(source?.ignore?.length, equals(2));
      expect(source?.ignore, contains('*.tmp'));
      expect(source?.ignore, contains('*.log'));
    });

    test('toJson creates valid JSON structure', () {
      const yamlContent = '''
destination: roundtrip.dart
sources_include:
  - path: test/
    recursive: false
patterns_exclude:
  - "*.temp"
''';

      final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
      final config = AssetXConfig.fromJson(jsonMap);

      // Convert to JSON
      final json = config.toJson();

      expect(json['destination'], equals('roundtrip.dart'));
      expect(json['sources_include'], isA<List>());
      expect(json['patterns_exclude'], isA<List>());
      expect(json['patterns_exclude'], contains('*.temp'));
    });
  });
}
