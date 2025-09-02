// ignore_for_file: avoid_print

import 'dart:io';
import 'package:assetx/gen/config.dart';
import 'package:assetx/gen/gen.dart';
import 'package:assetx/utils/lookup.dart';
import 'package:assetx/utils/pubspec_update.dart';
import 'package:assetx/utils/pubspec_resolve.dart';
import 'package:assetx/utils/io/yaml.dart';

void main() async {
  try {
    // Check assetx.yaml exists
    final configFile = File('assetx.yaml');
    if (!configFile.existsSync()) {
      print('Error: assetx.yaml not found');
      exit(1);
    }

    // Load configuration
    print('Loading assetx.yaml...');
    final yamlContent = await configFile.readAsString();
    final jsonMap = YamlUtils.parseYamlToJson(yamlContent);
    final config = AssetXConfig.fromJson(jsonMap);

    // Discover assets
    print('Discovering assets...');
    final result = await discoverAssets(config);

    print('Found ${result.files.length} files after filtering');
    // Debug: show files that contain 'tmp'
    final tmpFiles = result.files.where((f) => f.path.contains('tmp')).toList();
    if (tmpFiles.isNotEmpty) {
      print('WARNING: Found .tmp files that should be excluded:');
      for (final file in tmpFiles) {
        print('  - ${file.path}');
      }
    }

    // Get pubspec asset paths
    final allAssetPaths = <String>[];
    for (final folder in result.folders) {
      if (folder.parent == null) {
        // Root folders only
        allAssetPaths.addAll(folder.getPubspecAssetPaths());
      }
    }

    // Update pubspec
    print('Updating pubspec.yaml...');
    updatePubspecAssets(allAssetPaths);

    print('✓ Updated pubspec.yaml with ${allAssetPaths.length} asset paths');

    // Generate dart asset mapping code
    print('Generating dart asset mapping code...');

    // Get package name from pubspec.yaml
    String packageName;
    try {
      packageName = await getCurrentPackageName();
    } catch (e) {
      print('Warning: Could not read package name from pubspec.yaml: $e');
      packageName = 'unknown'; // Fallback
    }

    // Generate the complete dart code using AssetLookup objects directly
    final generatedCode = TemplateProcessor.generateFile(
      result.files,
      result.folders,
      config,
      packageName,
      usePackagePrefix: true,
    );

    // Write to destination file
    final outputFile = File(config.destination);
    await outputFile.writeAsString(generatedCode);

    print(
      '✓ Generated ${config.destination} with ${result.files.length} assets and ${result.folders.length} folders',
    );

    // Generate local version if localDestination is specified
    if (config.localDestination != null) {
      print('Generating local version for testing...');

      final localGeneratedCode = TemplateProcessor.generateFile(
        result.files,
        result.folders,
        config,
        packageName,
        usePackagePrefix: false,
      );

      final localOutputFile = File(config.localDestination!);
      await localOutputFile.writeAsString(localGeneratedCode);

      print(
        '✓ Generated local version ${config.localDestination} (without package prefixes)',
      );
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
