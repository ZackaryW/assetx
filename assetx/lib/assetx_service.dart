import 'model/lock.dart';
import 'core/lock_file_service.dart';
import 'core/code_generation.dart';

/// Main AssetX service that orchestrates asset operations
/// This class provides a unified API while delegating to specialized core services
class AssetXService {
  static const String defaultConfigFile = 'assetx.yaml';
  static const String defaultLockFile = 'assetx.lock';

  /// Generate lock file from configuration
  static Future<void> generateLock({
    String? configPath,
    String? lockPath,
    String? workingDirectory,
  }) async {
    return LockFileService.generateLock(
      configPath: configPath,
      lockPath: lockPath,
      workingDirectory: workingDirectory,
    );
  }

  /// Get files from existing lock file
  static Future<List<FileConfig>> getLockedFiles([String? lockPath]) async {
    return LockFileService.getLockedFiles(lockPath);
  }

  /// Check if lock file exists and is up to date
  static Future<bool> isLockUpToDate({
    String? configPath,
    String? lockPath,
  }) async {
    return LockFileService.isLockUpToDate(
      configPath: configPath,
      lockPath: lockPath,
    );
  }

  /// Generate Dart code from lock file
  static Future<String> generateDartCode({
    String? lockPath,
    String? configPath,
    String? workingDirectory,
  }) async {
    return CodeGenerationService.generateDartCode(
      lockPath: lockPath,
      configPath: configPath,
      workingDirectory: workingDirectory,
    );
  }
}
