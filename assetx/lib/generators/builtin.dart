
import 'package:assetx/generators/image_hard.dart';
import 'package:assetx/generators/image_soft.dart';
import 'package:assetx/generators/kv_hard.dart';
import 'package:assetx/generators/kv_soft.dart';
import 'package:path/path.dart' as path;
import 'base.dart';


// ignore: constant_identifier_names
const BUILTIN_TYPES = ["image_hard", "image_soft", "kv_hard", "kv_soft"];

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
