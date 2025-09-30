/// Utility functions for identifier generation and validation
class IdentifierUtils {
  /// Creates a valid Dart identifier from a given name
  ///
  /// Replaces invalid characters with underscores, ensures it doesn't start
  /// with a number, and converts to camelCase format.
  static String createValidIdentifier(String name) {
    // Replace invalid characters with underscores
    String cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it doesn't start with a number
    if (cleaned.isNotEmpty && RegExp(r'^[0-9]').hasMatch(cleaned)) {
      cleaned = '_$cleaned';
    }

    // Convert to camelCase
    final parts = cleaned.split('_').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '_unnamed';

    return parts.first.toLowerCase() +
        parts
            .skip(1)
            .map(
              (part) => part.isEmpty
                  ? ''
                  : part[0].toUpperCase() + part.substring(1).toLowerCase(),
            )
            .join();
  }
}
