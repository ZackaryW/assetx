#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:assetx/assetx.dart';

void main(List<String> arguments) async {
  try {
    if (arguments.isEmpty) {
      _showUsage();
      return;
    }

    final command = arguments[0].toLowerCase();
    final args = arguments.skip(1).toList();

    switch (command) {
      case 'add':
        await _handleAdd(args);
        break;
      case 'remove':
        await _handleRemove(args);
        break;
      case 'sync':
        await _handleSync(args);
        break;
      case 'gen':
        await _handleGen(args);
        break;
      case 'help':
      case '--help':
      case '-h':
        _showUsage();
        break;
      default:
        print('Unknown command: $command');
        _showUsage();
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _showUsage() {
  print('AssetX - Flutter Asset Code Generator');
  print('');
  print('Usage: assetx <command> [arguments]');
  print('');
  print('Available commands:');
  print('  add <type> <path>     Add new asset configuration');
  print('  remove <path>         Remove asset configuration');
  print('  sync                  Update lock file and ignore files');
  print('  gen                   Generate Dart code to target file');
  print('');
  print('Asset types:');
  print('  image_hard            Embed images as base64 bytes');
  print('  image_soft            Use Flutter Image.asset() loading');
  print('  kv_hard               Embed JSON/YAML as parsed objects');
  print('  kv_soft               Use rootBundle runtime loading');
  print('');
  print('Examples:');
  print('  assetx add image_hard assets/icons');
  print('  assetx add kv_soft assets/config');
  print('  assetx remove assets/icons');
  print('  assetx sync');
  print('  assetx gen');
}

Future<void> _handleAdd(List<String> args) async {
  if (args.length != 2) {
    print('Error: add command requires exactly 2 arguments: <type> <path>');
    print('Usage: assetx add <type> <path>');
    exit(1);
  }

  final type = args[0];
  final assetPath = args[1];

  // Validate type
  if (!BUILTIN_TYPES.contains(type)) {
    print('Error: Invalid asset type "$type"');
    print('Valid types: ${BUILTIN_TYPES.join(', ')}');
    exit(1);
  }

  // Check if path exists
  final dir = Directory(assetPath);
  if (!await dir.exists()) {
    print('Error: Path "$assetPath" does not exist');
    exit(1);
  }

  try {
    // Load existing config or create new one
    Config config;
    try {
      config = await Config.load();
      print(
        'Loaded existing configuration with ${config.entries.length} entries',
      );
    } catch (e) {
      config = Config([]);
      print('Creating new configuration file');
    }

    // Check for path conflicts
    _validatePathConflicts(config, assetPath);

    // Add new entry
    final newEntry = ConfigEntry(
      path: assetPath,
      type: type,
      recursive: false, // Default to non-recursive, could be made configurable
    );

    final updatedEntries = [...config.entries, newEntry];
    final updatedConfig = Config(updatedEntries);

    // Validate the updated configuration
    updatedConfig.validate();

    // Save updated config
    await updatedConfig.save('assetx.yaml');

    print('✅ Added $type configuration for "$assetPath"');
    print('Run "assetx sync" to update the lock file');
  } catch (e) {
    print('Error adding configuration: $e');
    exit(1);
  }
}

void _validatePathConflicts(Config config, String newPath) {
  final normalizedNewPath = path.normalize(newPath);

  for (final entry in config.entries) {
    final normalizedExistingPath = path.normalize(entry.path);

    // Check for exact match
    if (normalizedExistingPath == normalizedNewPath) {
      throw ArgumentError('Path "$newPath" already exists in configuration');
    }

    // Check if new path is a subfolder of existing path
    if (path.isWithin(normalizedExistingPath, normalizedNewPath)) {
      throw ArgumentError(
        'Path "$newPath" is within already configured path "${entry.path}" (${entry.type})',
      );
    }

    // Check if existing path is a subfolder of new path
    if (path.isWithin(normalizedNewPath, normalizedExistingPath)) {
      throw ArgumentError(
        'Path "$newPath" would contain already configured path "${entry.path}" (${entry.type})',
      );
    }
  }
}

Future<void> _handleRemove(List<String> args) async {
  if (args.length != 1) {
    print('Error: remove command requires exactly 1 argument: <path>');
    print('Usage: assetx remove <path>');
    exit(1);
  }

  final targetPath = args[0];

  try {
    // Load existing config
    final config = await Config.load();

    // Find matching entries
    final matchingEntries = config.entries
        .where(
          (entry) => path.normalize(entry.path) == path.normalize(targetPath),
        )
        .toList();

    if (matchingEntries.isEmpty) {
      print('Error: No configuration found for path "$targetPath"');
      print('Current configurations:');
      for (final entry in config.entries) {
        print('  ${entry.type}: ${entry.path}');
      }
      exit(1);
    }

    // Remove matching entries
    final remainingEntries = config.entries
        .where(
          (entry) => path.normalize(entry.path) != path.normalize(targetPath),
        )
        .toList();

    final updatedConfig = Config(remainingEntries);

    // Save updated config
    await updatedConfig.save('assetx.yaml');

    print(
      '✅ Removed ${matchingEntries.length} configuration(s) for "$targetPath"',
    );
    for (final removed in matchingEntries) {
      print('  - ${removed.type}: ${removed.path}');
    }
    print('Run "assetx sync" to update the lock file');
  } catch (e) {
    print('Error removing configuration: $e');
    exit(1);
  }
}

Future<void> _handleSync(List<String> args) async {
  print('🔄 Syncing asset configuration...');

  try {
    // Generate lock file from current configuration
    await AssetXService.generateLock();
    print('✅ Updated lock file');

    // Run update_ignore.dart if it exists
    final updateIgnoreFile = File('lib/utils/file/update_ignore.dart');
    if (await updateIgnoreFile.exists()) {
      print('🔄 Updating ignore files...');
      final result = await Process.run('dart', [
        'run',
        'lib/utils/file/update_ignore.dart',
      ], workingDirectory: Directory.current.path);

      if (result.exitCode == 0) {
        print('✅ Updated ignore files');
      } else {
        print(
          '⚠️  Warning: update_ignore.dart exited with code ${result.exitCode}',
        );
        if (result.stderr.toString().isNotEmpty) {
          print('stderr: ${result.stderr}');
        }
      }
    } else {
      print('ℹ️  update_ignore.dart not found, skipping ignore file updates');
    }

    // Show lock file stats
    final lock = await LockFile.load('assetx.lock');
    final filesByType = <String, int>{};
    for (final file in lock.files) {
      filesByType[file.type] = (filesByType[file.type] ?? 0) + 1;
    }

    print('');
    print('📊 Lock file summary:');
    print('  Total files: ${lock.files.length}');
    for (final entry in filesByType.entries) {
      print('  ${entry.key}: ${entry.value} files');
    }
  } catch (e) {
    print('Error during sync: $e');
    exit(1);
  }
}

Future<void> _handleGen(List<String> args) async {
  print('🔄 Generating Dart code...');

  try {
    // Load configuration to get target file
    Config config;
    try {
      config = await Config.load();
    } catch (e) {
      print('Error: No configuration file found. Run "assetx add" first.');
      exit(1);
    }

    final targetFile = config.generationTarget;
    print('Target: $targetFile');

    // Generate Dart code
    final dartCode = await AssetXService.generateDartCode();

    // Write to target file (the .x.dart part file)
    final partFilePath = targetFile.replaceAll('.dart', '.x.dart');
    final partFile = File(partFilePath);

    // Ensure directory exists
    await partFile.parent.create(recursive: true);

    // Write generated code
    await partFile.writeAsString(dartCode);

    print('✅ Generated code written to $partFilePath');

    // Show generation stats
    final lock = await LockFile.load('assetx.lock');
    final lines = dartCode.split('\n').length;

    print('');
    print('📊 Generation summary:');
    print('  Source files: ${lock.files.length}');
    print('  Generated lines: $lines');
    print('  Target file: $partFilePath');
  } catch (e) {
    print('Error during code generation: $e');
    exit(1);
  }
}
