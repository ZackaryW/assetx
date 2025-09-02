import 'package:flutter_test/flutter_test.dart';
import 'package:assetx/utils/io/yaml.dart';

void main() {
  group('YamlUtils Tests', () {
    test('converts simple YAML to JSON correctly', () {
      const yamlContent = '''
name: AssetX
version: 1.0
enabled: true
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result['name'], equals('AssetX'));
      expect(result['version'], equals(1.0));
      expect(result['enabled'], isTrue);
    });

    test('converts nested YAML maps correctly', () {
      const yamlContent = '''
database:
  host: localhost
  port: 5432
  credentials:
    username: admin
    password: secret
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result['database'], isA<Map<String, dynamic>>());
      expect(result['database']['host'], equals('localhost'));
      expect(result['database']['port'], equals(5432));
      expect(result['database']['credentials'], isA<Map<String, dynamic>>());
      expect(result['database']['credentials']['username'], equals('admin'));
      expect(result['database']['credentials']['password'], equals('secret'));
    });

    test('converts YAML lists correctly', () {
      const yamlContent = '''
fruits:
  - apple
  - banana
  - orange
numbers:
  - 1
  - 2
  - 3
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result['fruits'], isA<List<dynamic>>());
      expect(result['fruits'], hasLength(3));
      expect(result['fruits'], contains('apple'));
      expect(result['fruits'], contains('banana'));
      expect(result['fruits'], contains('orange'));

      expect(result['numbers'], isA<List<dynamic>>());
      expect(result['numbers'], hasLength(3));
      expect(result['numbers'], contains(1));
      expect(result['numbers'], contains(2));
      expect(result['numbers'], contains(3));
    });

    test('converts complex nested structures correctly', () {
      const yamlContent = '''
sources_include:
  - path: assets/
    recursive: true
    ignore:
      - "*.tmp"
      - "*.log"
  - path: data/
    recursive: false
type_registry:
  image:
    file_extensions:
      - png
      - jpg
  data:
    file_extensions:
      - json
      - yaml
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result['sources_include'], isA<List<dynamic>>());
      expect(result['sources_include'], hasLength(2));

      final firstSource = result['sources_include'][0] as Map<String, dynamic>;
      expect(firstSource['path'], equals('assets/'));
      expect(firstSource['recursive'], isTrue);
      expect(firstSource['ignore'], isA<List<dynamic>>());
      expect(firstSource['ignore'], contains('*.tmp'));

      expect(result['type_registry'], isA<Map<String, dynamic>>());
      expect(result['type_registry']['image'], isA<Map<String, dynamic>>());
      expect(
        result['type_registry']['image']['file_extensions'],
        contains('png'),
      );
    });

    test('handles null and empty values correctly', () {
      const yamlContent = '''
nullable_field: null
empty_string: ""
empty_list: []
empty_map: {}
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result['nullable_field'], isNull);
      expect(result['empty_string'], equals(''));
      expect(result['empty_list'], isA<List<dynamic>>());
      expect(result['empty_list'], isEmpty);
      expect(result['empty_map'], isA<Map<String, dynamic>>());
      expect(result['empty_map'], isEmpty);
    });

    test('handles mixed data types correctly', () {
      const yamlContent = '''
mixed_list:
  - string_value
  - 42
  - true
  - null
  - nested_object:
      key: value
  - nested_array:
      - item1
      - item2
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      final mixedList = result['mixed_list'] as List<dynamic>;
      expect(mixedList[0], equals('string_value'));
      expect(mixedList[1], equals(42));
      expect(mixedList[2], isTrue);
      expect(mixedList[3], isNull);
      expect(mixedList[4], isA<Map<String, dynamic>>());
      expect(mixedList[5], isA<Map<String, dynamic>>());
    });

    test('preserves key types as strings', () {
      const yamlContent = '''
123: numeric_key
"456": string_key
boolean_key: true
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      expect(result.keys, everyElement(isA<String>()));
      expect(result['123'], equals('numeric_key'));
      expect(result['456'], equals('string_key'));
      expect(result['boolean_key'], isTrue);
    });

    test('handles AssetX configuration format correctly', () {
      const yamlContent = '''
destination: lib/generated_assets.dart
cache:
  memory: true
  src: lib/cache.dart
sources_include:
  - path: assets/
    recursive: true
    ignore:
      - "*.tmp"
patterns_include:
  - "*.png"
  - "*.jpg"
patterns_exclude:
  - "*.log"
type_registry:
  image:
    file_extensions:
      - png
      - jpg
map_registry:
  image:
    builtin: imagex
''';

      final result = YamlUtils.parseYamlToJson(yamlContent);

      // Verify the structure is correct for AssetXConfig
      expect(result, isA<Map<String, dynamic>>());
      expect(result['destination'], isA<String>());
      expect(result['cache'], isA<Map<String, dynamic>>());
      expect(result['sources_include'], isA<List<dynamic>>());
      expect(result['patterns_include'], isA<List<dynamic>>());
      expect(result['patterns_exclude'], isA<List<dynamic>>());
      expect(result['type_registry'], isA<Map<String, dynamic>>());
      expect(result['map_registry'], isA<Map<String, dynamic>>());
    });
  });
}
