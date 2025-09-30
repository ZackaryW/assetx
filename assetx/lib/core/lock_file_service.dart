import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/config.dart';
import '../model/lock.dart';
import 'asset_discovery.dart';

/// Service responsible for lock file operations
class LockFileService {
  static const String defaultConfigFile = 'assetx.yaml';
  static const String defaultLockFile = 'assetx.lock';

  /// Generate lock file from configuration
  static Future<void> generateLock({
    String? configPath,
    String? lockPath,
    String? workingDirectory,
  }) async {
    final workDir = workingDirectory ?? Directory.current.path;
    final configFile = configPath ?? path.join(workDir, defaultConfigFile);
    final lockFile = lockPath ?? path.join(workDir, defaultLockFile);

    // Load configuration
    final config = await Config.load(configFile);

    // Validate that all configuration entries have valid generators
    AssetDiscoveryService.validateGenerators(config);

    // Discover files based on configuration entries
    final discoveredFiles = <FileConfig>[];

    for (final entry in config.entries) {
      final files = await AssetDiscoveryService.discoverFiles(entry, workDir);
      discoveredFiles.addAll(files);
    }

    // Create and save lock file
    final lock = LockFile(discoveredFiles);
    await lock.save(lockFile);
  }

  /// Get files from existing lock file
  static Future<List<FileConfig>> getLockedFiles([String? lockPath]) async {
    final lockFile = lockPath ?? defaultLockFile;
    final lock = await LockFile.load(lockFile);
    return lock.files;
  }

  /// Check if lock file exists and is up to date
  static Future<bool> isLockUpToDate({
    String? configPath,
    String? lockPath,
  }) async {
    final configFile = File(configPath ?? defaultConfigFile);
    final lockFile = File(lockPath ?? defaultLockFile);

    if (!await lockFile.exists()) {
      return false;
    }

    if (!await configFile.exists()) {
      return true; // No config file, so lock file is technically up to date
    }

    final configModified = await configFile.lastModified();
    final lockModified = await lockFile.lastModified();

    return lockModified.isAfter(configModified);
  }
}
