import 'dart:io';

/// Utility functions for generating Flutter package asset paths
class PackagePathUtils {
  /// Converts a relative asset path to Flutter package path format
  /// Returns packages/{packageName}/{path} for cross-package loading
  static String getPackageAssetPath(String relativePath) {
    try {
      // Try to get package name from pubspec.yaml in current directory
      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final lines = content.split('\n');
        for (final line in lines) {
          if (line.trim().startsWith('name:')) {
            final packageName = line.split(':')[1].trim();
            // Remove any quotes from package name
            final cleanPackageName = packageName.replaceAll(
              RegExp(r'["' + "']"),
              '',
            );
            return 'packages/$cleanPackageName/$relativePath';
          }
        }
      }
    } catch (e) {
      // Fallback to just the relative path if we can't get package name
    }

    // Fallback to relative path
    return relativePath;
  }

  /// Gets the current package name from pubspec.yaml
  static String? getCurrentPackageName() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final lines = content.split('\n');
        for (final line in lines) {
          if (line.trim().startsWith('name:')) {
            final packageName = line.split(':')[1].trim();
            return packageName.replaceAll(RegExp(r'["' + "']"), '');
          }
        }
      }
    } catch (e) {
      // Return null if we can't determine package name
    }
    return null;
  }
}
