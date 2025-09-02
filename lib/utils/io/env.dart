class EnvLoader {
  static Map<String, dynamic> loadEnv(String value) {
    final lines = value.split('\n');
    final Map<String, dynamic> envMap = {};

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue; // skip empty lines and comments
      }

      final equalsIndex = line.indexOf('=');
      if (equalsIndex != -1) {
        final key = line.substring(0, equalsIndex).trim();
        final rawValue = line.substring(equalsIndex + 1).trim();
        final value = _parseValue(rawValue);
        envMap[key] = value;
      }
    }
    return envMap;
  }

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
