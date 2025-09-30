import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'generator.dart';
import 'lock.dart';

// ignore: constant_identifier_names
const BUILTIN_TYPES = ["image_hard", "image_soft", "kv_hard", "kv_soft"];

/// Generator for hardcode image assets (embedded as base64)
class ImageHardGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    '.ico',
  ];

  const ImageHardGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final file = File(fileConfig.fullPath);
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);

      // Generate base64 content
      final bytes = file.readAsBytesSync();
      final base64Content = base64Encode(bytes);

      // Generate constants
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      final base64ConstName = '\$${fileConfig.uid}_base64';
      final bytesConstName = '\$${fileConfig.uid}_bytes';

      // Normalize path for cross-platform compatibility
      final normalizedPath = fileConfig.fullPath.replaceAll('\\', '/');
      
      buffer.writeln(
        'const String $pathConstName = \'$normalizedPath\';',
      );
      buffer.writeln('const String $base64ConstName = \'$base64Content\';');
      buffer.writeln(
        'final ByteData $bytesConstName = ByteData.sublistView(base64Decode($base64ConstName));',
      );
      buffer.writeln();

      // Create valid Dart identifier
      final dartIdentifier = _createValidIdentifier(fileName + extension.replaceAll('.', '_'));
      varReferrers.add(
        'Image get $dartIdentifier => Image.memory($bytesConstName.buffer.asUint8List());',
      );
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }

  String _createValidIdentifier(String input) {
    // Replace invalid characters with underscores
    var result = input.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    
    // Ensure it doesn't start with a number
    if (RegExp(r'^[0-9]').hasMatch(result)) {
      result = '_$result';
    }
    
    // Convert to camelCase
    final parts = result.split('_').where((part) => part.isNotEmpty);
    if (parts.isEmpty) return 'asset';
    
    return parts.first.toLowerCase() + 
           parts.skip(1).map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase()).join();
  }
}

/// Generator for soft image assets (using Image.asset)
class ImageSoftGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    '.ico',
  ];

  const ImageSoftGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath).replaceAll('.', '');
      final normalizedPath = fileConfig.fullPath.replaceAll('\\', '/');

      // Generate path constant
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln(
        'const String $pathConstName = \'$normalizedPath\';',
      );

      varReferrers.add(
        'Image get ${_createValidIdentifier(fileName + extension)} => Image.asset($pathConstName);',
      );
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }

  String _createValidIdentifier(String name) {
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
           parts.skip(1).map((part) => 
             part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1).toLowerCase()
           ).join();
  }
}

/// Generator for hardcode key-value assets (embedded as parsed data)
class KvHardGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => ['.json', '.yaml', '.yml', '.env'];

  const KvHardGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final file = File(fileConfig.fullPath);
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);

      // Parse content based on file type
      final content = file.readAsStringSync();
      dynamic parsedContent;

      if (extension == '.json') {
        parsedContent = jsonDecode(content);
        final dataConstName = '\$${fileConfig.uid}_data';
        buffer.writeln(
          'const Map<String, dynamic> $dataConstName = ${_formatMapConstant(parsedContent)};',
        );
        varReferrers.add(
          'Map<String, dynamic> get ${_createValidIdentifier(fileName)} => $dataConstName;',
        );
      } else {
        // For other formats, embed as string
        final dataConstName = '\$${fileConfig.uid}_content';
        buffer.writeln(
          'const String $dataConstName = \'${content.replaceAll('\'', '\\\'')}\'',
        );
        varReferrers.add(
          'String get ${_createValidIdentifier(fileName)} => $dataConstName;',
        );
      }
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }

  String _formatMapConstant(Map<String, dynamic> map) {
    // Simple map formatting for constants - in production would need more robust handling
    final entries = map.entries
        .map((e) => '\'${e.key}\': ${_formatValue(e.value)}')
        .join(', ');
    return '{$entries}';
  }

  String _formatValue(dynamic value) {
    if (value is String) return '\'${value.replaceAll('\'', '\\\'')}\'';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is Map)
      return _formatMapConstant(Map<String, dynamic>.from(value));
    if (value is List) return '[${value.map(_formatValue).join(', ')}]';
    return 'null';
  }

  String _createValidIdentifier(String name) {
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
           parts.skip(1).map((part) => 
             part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1).toLowerCase()
           ).join();
  }
}

/// Generator for soft key-value assets (using rootBundle.loadString)
class KvSoftGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => ['.json', '.yaml', '.yml', '.env'];

  const KvSoftGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);
      final normalizedPath = fileConfig.fullPath.replaceAll('\\', '/');

      // Generate path constant
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln(
        'const String $pathConstName = \'$normalizedPath\';',
      );

      if (extension == '.json') {
        varReferrers.add(
          'Future<Map<String, dynamic>> get ${_createValidIdentifier(fileName)} => rootBundle.loadString($pathConstName).then(jsonDecode);',
        );
      } else {
        varReferrers.add(
          'Future<String> get ${_createValidIdentifier(fileName)} => rootBundle.loadString($pathConstName);',
        );
      }
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }

  String _createValidIdentifier(String name) {
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
           parts.skip(1).map((part) => 
             part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1).toLowerCase()
           ).join();
  }
}

/// Generator registry for managing builtin and custom generators
class GeneratorRegistry {
  static final Map<String, BaseGenerator> _generators = {
    'image_hard': const ImageHardGenerator(),
    'image_soft': const ImageSoftGenerator(),
    'kv_hard': const KvHardGenerator(),
    'kv_soft': const KvSoftGenerator(),
  };

  /// Get generator for a specific type
  static BaseGenerator? getGenerator(String type) {
    return _generators[type];
  }

  /// Register a new generator
  static void registerGenerator(String type, BaseGenerator generator) {
    _generators[type] = generator;
  }

  /// Check if a generator exists for the given type
  static bool hasGenerator(String type) {
    return _generators.containsKey(type);
  }

  /// Get all registered generator types
  static List<String> getRegisteredTypes() {
    return _generators.keys.toList();
  }

  /// Check if a generator can handle a specific file extension for the given type
  static bool canHandleFile(String type, String filePath) {
    final generator = _generators[type];
    if (generator == null) return false;

    final extension = path.extension(filePath);
    return generator.canHandle(extension);
  }
}
