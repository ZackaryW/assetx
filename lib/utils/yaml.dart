// ignore_for_file: unintended_html_in_doc_comment

import 'package:yaml/yaml.dart';

/// YAML/JSON Conversion Utilities for AssetX Configuration Processing.
///
/// Provides comprehensive utilities for converting YAML data structures to
/// JSON-compatible Map and List objects that can be used with json_serializable
/// generated classes. Essential for processing AssetX configuration files.
///
/// **Key Features:**
/// - Deep conversion of nested YAML structures
/// - Recursive handling of Maps and Lists
/// - Preservation of data types and structure
/// - Integration with json_serializable workflow
///
/// **Primary Use Case:**
/// Converting parsed YAML configuration files into formats suitable for
/// AssetXContext and related configuration classes that use json_serializable.
///
/// final yamlMap = loadYaml(yamlContent) as Map<dynamic, dynamic>;
/// final jsonMap = YamlUtils.convertYamlToJson(yamlMap);
/// final context = AssetXContext.fromJson(jsonMap);
/// ```
class YamlUtils {
  /// Converts a YAML Map to a JSON-compatible Map structure.
  ///
  /// Recursively processes a YAML Map (with dynamic keys and values) and
  /// converts it to a Map<String, dynamic> structure suitable for use with
  /// json_serializable generated classes. Handles nested Maps and Lists.
  ///
  /// **Parameters:**
  /// - [yamlMap]: The YAML Map to convert (typically from loadYaml())
  ///
  /// **Returns:** A JSON-compatible Map<String, dynamic>
  ///
  /// **Conversion Process:**
  /// 1. Converts all keys to strings
  /// 2. Recursively processes nested Maps
  /// 3. Recursively processes nested Lists
  /// 4. Preserves primitive values as-is
  ///
  /// **Example:**
  /// ```dart
  /// final yamlMap = loadYaml('name: AssetX\nversion: 1.0') as Map<dynamic, dynamic>;
  /// final jsonMap = YamlUtils.convertYamlToJson(yamlMap);
  /// // Result: {'name': 'AssetX', 'version': 1.0}
  /// ```
  static Map<String, dynamic> convertYamlToJson(Map<dynamic, dynamic> yamlMap) {
    final Map<String, dynamic> result = {};

    for (final entry in yamlMap.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value is Map) {
        result[key] = convertYamlToJson(value);
      } else if (value is List) {
        result[key] = _convertYamlListToJson(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Converts a YAML List to a JSON-compatible List structure.
  ///
  /// Recursively processes a YAML List and converts all nested structures
  /// to JSON-compatible formats. Handles Lists containing Maps, other Lists,
  /// or primitive values.
  ///
  /// **Parameters:**
  /// - [yamlList]: The YAML List to convert
  ///
  /// **Returns:** A JSON-compatible List<dynamic>
  ///
  /// **Conversion Process:**
  /// 1. Maps nested Maps using [convertYamlToJson]
  /// 2. Recursively processes nested Lists
  /// 3. Preserves primitive values as-is
  ///
  /// **Example:**
  /// ```dart
  /// final yamlList = [{'name': 'item1'}, 'string', 42];
  /// final jsonList = YamlUtils._convertYamlListToJson(yamlList);
  /// // Result: [{'name': 'item1'}, 'string', 42]
  /// ```
  static List<dynamic> _convertYamlListToJson(List<dynamic> yamlList) {
    return yamlList.map((item) {
      if (item is Map) {
        return convertYamlToJson(item);
      } else if (item is List) {
        return _convertYamlListToJson(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Parses YAML content from a string and converts to JSON-compatible format.
  ///
  /// Combines YAML parsing and JSON conversion in a single convenient method.
  /// This is the most commonly used method for processing AssetX configuration
  /// files from string content.
  ///
  /// **Parameters:**
  /// - [yamlContent]: The raw YAML content as a string
  ///
  /// **Returns:** A JSON-compatible Map<String, dynamic>
  ///
  /// **Process:**
  /// 1. Parses the YAML string using the yaml package
  /// 2. Converts the result to JSON-compatible format
  /// 3. Returns the processed Map ready for json_serializable
  ///
  /// **Example:**
  /// ```dart
  /// final yamlContent = '''
  /// sources:
  ///   include:
  ///     - path: assets/
  ///       recursive: true
  /// destination: generated
  /// ''';
  ///
  /// final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
  /// final context = AssetXContext.fromJson(jsonMap);
  /// ```
  ///
  /// **Throws:**
  /// - [YamlException]: If the YAML content is malformed
  /// - [TypeError]: If the root YAML structure is not a Map
  static Map<String, dynamic> parseYamlToJson(String yamlContent) {
    final yamlMap = loadYaml(yamlContent) as Map<dynamic, dynamic>;
    return convertYamlToJson(yamlMap);
  }
}
