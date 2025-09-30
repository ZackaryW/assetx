import 'dart:io';
import 'package:yaml/yaml.dart';

/// Utility class for parsing and resolving pubspec.yaml information
class PubspecResolver {
  final String _pubspecPath;
  YamlMap? _pubspecContent;

  PubspecResolver(this._pubspecPath);

  /// Creates a resolver for the pubspec.yaml in the given directory
  factory PubspecResolver.fromDirectory(String directoryPath) {
    final pubspecPath = '$directoryPath${Platform.pathSeparator}pubspec.yaml';
    return PubspecResolver(pubspecPath);
  }

  /// Creates a resolver for the current working directory
  factory PubspecResolver.current() {
    return PubspecResolver.fromDirectory(Directory.current.path);
  }

  /// Loads and parses the pubspec.yaml file
  Future<void> load() async {
    final file = File(_pubspecPath);
    if (!await file.exists()) {
      throw FileSystemException('pubspec.yaml not found at: $_pubspecPath');
    }

    final content = await file.readAsString();
    _pubspecContent = loadYaml(content) as YamlMap;
  }

  /// Gets the package name from pubspec.yaml
  /// Throws [StateError] if not loaded or package name not found
  String getPackageName() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final name = _pubspecContent!['name'];
    if (name == null || name is! String) {
      throw FormatException(
        'Package name not found or invalid in pubspec.yaml',
      );
    }

    return name;
  }

  /// Gets the package version from pubspec.yaml
  String? getVersion() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final version = _pubspecContent!['version'];
    return version?.toString();
  }

  /// Gets the package description from pubspec.yaml
  String? getDescription() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final description = _pubspecContent!['description'];
    return description?.toString();
  }

  /// Gets dependencies from pubspec.yaml
  Map<String, dynamic>? getDependencies() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final dependencies = _pubspecContent!['dependencies'];
    return dependencies is YamlMap
        ? Map<String, dynamic>.from(dependencies)
        : null;
  }

  /// Gets dev dependencies from pubspec.yaml
  Map<String, dynamic>? getDevDependencies() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final devDependencies = _pubspecContent!['dev_dependencies'];
    return devDependencies is YamlMap
        ? Map<String, dynamic>.from(devDependencies)
        : null;
  }

  /// Gets flutter assets configuration from pubspec.yaml
  List<String>? getFlutterAssets() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final flutter = _pubspecContent!['flutter'];
    if (flutter is! YamlMap) return null;

    final assets = flutter['assets'];
    if (assets is YamlList) {
      return assets.map((e) => e.toString()).toList();
    }

    return null;
  }

  /// Checks if the project is a Flutter project
  bool isFlutterProject() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    final dependencies = getDependencies();
    return dependencies?.containsKey('flutter') == true;
  }

  /// Gets the raw pubspec content as a map
  Map<String, dynamic>? getRawContent() {
    if (_pubspecContent == null) {
      throw StateError('Pubspec not loaded. Call load() first.');
    }

    return Map<String, dynamic>.from(_pubspecContent!);
  }
}

/// Convenience function to quickly get package name from a directory
Future<String> getPackageNameFromDirectory(String directoryPath) async {
  final resolver = PubspecResolver.fromDirectory(directoryPath);
  await resolver.load();
  return resolver.getPackageName();
}

/// Convenience function to quickly get package name from current directory
Future<String> getCurrentPackageName() async {
  final resolver = PubspecResolver.current();
  await resolver.load();
  return resolver.getPackageName();
}
