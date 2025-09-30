/// Utility functions for AssetXF
library assetxf_utils;

/// Converts a packages/{pkg}/path to internal path by removing the packages/{pkg}/ prefix
///
/// Examples:
/// - 'packages/example/assets/images/file.jpg' -> 'assets/images/file.jpg'
/// - 'assets/images/file.jpg' -> 'assets/images/file.jpg' (no change if no packages prefix)
String toInternalPath(String packagePath) {
  final packagesPrefix = RegExp(r'^packages/[^/]+/');
  return packagePath.replaceFirst(packagesPrefix, '');
}
