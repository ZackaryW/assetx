import 'dart:convert';

import 'package:assetx/utils/io/env.dart';
import 'package:assetx/utils/io/json.dart';
import 'package:assetx/utils/io/yaml.dart';
import 'package:assetx/utils/io/toml.dart';
import 'package:path/path.dart' as p;

class IoExt {
  static Map<String, dynamic> loadAuto(String path, String content) {
    final extension = path.split('.').last;
    switch (extension) {
      case 'json':
        if (content.contains("//")) {
          return jsonDecodeWithComments(content);
        } else {
          return jsonDecode(content);
        }
      case 'yaml':
      case 'yml':
        return YamlUtils.parseYamlToJson(content);
      case 'env':
        return EnvLoader.loadEnv(content);
      case 'toml':
        return TomlLoader.fromString(content);
      default:
        throw UnsupportedError('Unsupported file type: $extension');
    }
  }

  static Map<String, dynamic> auto(
    String path,
    String content,
    dynamic Function(String) f,
  ) {
    final data = loadAuto(path, content);
    return _processMap(data, path, f);
  }

  /// Rules of the ioext
  ///
  /// ((path)) relative to the current file, merge
  ///
  /// {{key}} first resolved from environ, then from the current file address
  static void _inplaceEdit(
    Map<String, dynamic> data,
    String key,
    String value,
    String path,
    dynamic Function(String) f,
  ) {
    // get parent folder path
    final folderPath = p.dirname(path);

    if (value.startsWith("((") && value.endsWith("))")) {
      final innerKey = value.substring(2, value.length - 2).trim();

      data[key] = f(p.join(folderPath, innerKey));
    } else if (value.contains("{{") && value.contains("}}")) {
      final regex = RegExp(r'\{\{(.*?)\}\}');
      var newValue = value;
      for (final match in regex.allMatches(value)) {
        final innerKey = match.group(1)?.trim();
        if (innerKey != null) {
          // first try env
          final envValue = String.fromEnvironment(innerKey);
          if (envValue.isNotEmpty) {
            newValue = newValue.replaceAll("{{$innerKey}}", envValue);
          } else {
            // then try current file
            final currentFileValue = data[innerKey];
            if (currentFileValue != null) {
              newValue = newValue.replaceAll("{{$innerKey}}", currentFileValue);
            }
          }
        }
      }
      data[key] = newValue;
    }
  }

  static Map<String, dynamic> _processMap(
    Map<String, dynamic> data,
    String path,
    dynamic Function(String) f,
  ) {
    for (final key in data.keys) {
      var value = data[key];
      if (value is String && (value.startsWith("((") || value.contains("{{"))) {
        _inplaceEdit(data, key, value, path, f);
      }
      value = data[key];
      if (value is Map<String, dynamic>) {
        data[key] = _processMap(value, path, f);
      }
    }
    return data;
  }
}
