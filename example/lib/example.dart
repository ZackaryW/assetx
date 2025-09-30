import 'dart:io';
import 'package:assetx/assetx.dart';

void main() async {
  try {
    print('AssetX Example - Generating lock file from assetx.yaml');

    // Generate lock file from configuration
    await AssetXService.generateLock(
      configPath: 'assetx.yaml',
      lockPath: 'assetx.lock',
      workingDirectory: Directory.current.path,
    );

    print('✅ Lock file generated successfully!');

    // Load and display the generated files
    final lockedFiles = await AssetXService.getLockedFiles('assetx.lock');

    print('\n📁 Discovered files:');
    for (final file in lockedFiles) {
      print('  ${file.type}: ${file.fullPath}');
    }

    // Check if lock file is up to date
    final isUpToDate = await AssetXService.isLockUpToDate(
      configPath: 'assetx.yaml',
      lockPath: 'assetx.lock',
    );

    print('\n🔄 Lock file up to date: $isUpToDate');
  } catch (e) {
    print('❌ Error: $e');
  }
}
