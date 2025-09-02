/// Simple TOML loader for parsing TOML content from strings
class TomlLoader {
  /// Parses TOML content from a string and returns a Map
  static Map<String, dynamic> fromString(String content) {
    final lines = content.split('\n');
    return _parse(lines);
  }

  /// Internal parsing logic based on the provided TOML parser
  static Map<String, dynamic> _parse(List<String> lines) {
    // Simple TOML parsing logic, ignores all nested structures exceeding 2 levels
    final Map<String, dynamic> tomlMap = {};
    var currentPath = <String>[];
    Map<String, dynamic> currentFocus = tomlMap;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue; // skip empty lines and comments
      }

      if (line.startsWith('[') && line.endsWith(']')) {
        // section header
        final section = line.substring(1, line.length - 1).trim();
        currentPath = section.split('.').map((s) => s.trim()).toList();
        currentFocus = tomlMap;

        for (var part in currentPath) {
          if (!currentFocus.containsKey(part)) {
            currentFocus[part] = <String, dynamic>{};
          }
          currentFocus = currentFocus[part] as Map<String, dynamic>;
        }
      } else {
        // key-value pair
        final equalsIndex = line.indexOf('=');
        if (equalsIndex != -1) {
          final key = line.substring(0, equalsIndex).trim();
          final rawValue = line.substring(equalsIndex + 1).trim();
          final value = _parseValue(rawValue);
          currentFocus[key] = value;
        }
      }
    }
    return tomlMap;
  }

  /// Parses a TOML value and returns the appropriate Dart type
  static dynamic _parseValue(String rawValue) {
    final value = rawValue.trim();

    // Handle quoted strings (double or single quotes)
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    // Handle boolean values
    if (value.toLowerCase() == 'true') {
      return true;
    }
    if (value.toLowerCase() == 'false') {
      return false;
    }

    // Handle integer values
    final intValue = int.tryParse(value);
    if (intValue != null) {
      return intValue;
    }

    // Handle float values
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      return doubleValue;
    }

    // Default to string for unquoted values
    return value;
  }
}
