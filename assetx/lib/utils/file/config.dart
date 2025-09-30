import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

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

  /// Creates a PascalCase class name from a given name
  static String createValidClassName(String name) {
    // Replace invalid characters with underscores
    String cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it doesn't start with a number
    if (cleaned.isNotEmpty && RegExp(r'^[0-9]').hasMatch(cleaned)) {
      cleaned = '_$cleaned';
    }

    // Convert to PascalCase
    final parts = cleaned.split('_').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '_Unnamed';

    return parts
        .map(
          (part) => part.isEmpty
              ? ''
              : part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join();
  }

  /// Generate a unique hash-based class name for folder paths to prevent naming conflicts
  /// 
  /// Uses the folder basename for readability and appends a hash of the full path
  /// for uniqueness. Example: "Images1_a1b2c3d4" for assets/images_1
  static String createUniqueClassName(String folderPath) {
    final folderName = path.basename(folderPath);
    final baseName = createValidClassName(folderName);
    
    // Generate 8-character hash suffix from full path
    final bytes = utf8.encode(folderPath);
    final digest = sha256.convert(bytes);
    final hashSuffix = digest.toString().substring(0, 8);
    
    return '${baseName}_$hashSuffix';
  }

  /// Generate a unique key for grouping files by folder path
  static String createFolderKey(String folderPath) {
    final bytes = utf8.encode(folderPath);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // 16 chars for better uniqueness
  }
}
