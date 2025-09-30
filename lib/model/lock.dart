import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class FileConfig {
  final String fullPath;
  final String type;
  final String uid;

  FileConfig(this.fullPath, this.type, this.uid);

  /// Create a FileConfig with auto-generated UID
  factory FileConfig.generate(String fullPath, String type) {
    final uid = _generateUID(fullPath, type);
    return FileConfig(fullPath, type, uid);
  }

  factory FileConfig.fromJson(Map<String, dynamic> json) {
    return FileConfig(
      json['fullPath'] as String,
      json['type'] as String,
      json['uid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullPath': fullPath, 'type': type, 'uid': uid};
  }

  /// Generate a deterministic UID from file path and type
  static String _generateUID(String filePath, String type) {
    final fileName = path.basename(filePath);
    final dirName = path.basename(path.dirname(filePath));

    // Create input string for hashing
    final input = '$dirName/$fileName:$type';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);

    // Take first 8 characters of hex for UID (similar to example format)
    return digest.toString().substring(0, 8).toUpperCase();
  }

  /// Check for UID collisions in a list of FileConfigs
  static bool hasCollisions(List<FileConfig> configs) {
    final uids = configs.map((c) => c.uid).toSet();
    return uids.length != configs.length;
  }

  /// Generate UIDs with collision resolution
  static List<FileConfig> generateWithCollisionHandling(
    List<({String path, String type})> inputs,
  ) {
    final configs = <FileConfig>[];
    final usedUIDs = <String>{};

    for (final input in inputs) {
      var uid = _generateUID(input.path, input.type);
      var counter = 1;

      // Handle collisions by appending counter
      while (usedUIDs.contains(uid)) {
        final baseUID = uid.substring(0, 6);
        uid = '${baseUID}${counter.toString().padLeft(2, '0')}';
        counter++;
      }

      usedUIDs.add(uid);
      configs.add(FileConfig(input.path, input.type, uid));
    }

    return configs;
  }
}

class LockFile {
  final List<FileConfig> files;

  LockFile(this.files) {
    // Validate no UID collisions on creation
    if (FileConfig.hasCollisions(files)) {
      throw StateError('UID collisions detected in LockFile');
    }
  }

  factory LockFile.fromJson(Map<String, dynamic> json) {
    final filesList =
        (json['files'] as List<dynamic>?)
            ?.map(
              (file) => FileConfig.fromJson(Map<String, dynamic>.from(file)),
            )
            .toList() ??
        [];

    return LockFile(filesList);
  }

  Map<String, dynamic> toJson() {
    return {
      'files': files.map((file) => file.toJson()).toList(),
      'metadata': {
        'generated': DateTime.now().toIso8601String(),
        'totalFiles': files.length,
        'uniqueUIDs': files.map((f) => f.uid).toSet().length,
      },
    };
  }

  static Future<LockFile> load(String lockPath) async {
    final file = File(lockPath);
    if (!await file.exists()) {
      return LockFile([]);
    }

    final content = await file.readAsString();
    final json = jsonDecode(content);
    return LockFile.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> save(String lockPath) async {
    final file = File(lockPath);
    final jsonString = const JsonEncoder.withIndent('  ').convert(toJson());
    await file.writeAsString(jsonString);
  }

  /// Get FileConfig by UID
  FileConfig? findByUID(String uid) {
    try {
      return files.firstWhere((f) => f.uid == uid);
    } catch (e) {
      return null;
    }
  }

  /// Check if this lock file has UID collisions
  bool get hasCollisions => FileConfig.hasCollisions(files);
}
