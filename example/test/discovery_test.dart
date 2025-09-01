import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:assetx/gen/config.dart';
import 'package:assetx/utils/lookup.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

void main() {
  group('Asset Discovery Tests', () {
    late Directory tempDir;
    late AssetXConfig config;

    setUp(() async {
      // Create temporary test directory structure
      tempDir = await Directory.systemTemp.createTemp('asset_test_');

      // Create test files and folders
      await Directory(
        p.join(tempDir.path, 'assets', 'images'),
      ).create(recursive: true);
      await Directory(
        p.join(tempDir.path, 'assets', 'data'),
      ).create(recursive: true);
      await Directory(p.join(tempDir.path, 'excluded')).create(recursive: true);

      await File(p.join(tempDir.path, 'assets', 'images', 'logo.png')).create();
      await File(p.join(tempDir.path, 'assets', 'images', 'icon.jpg')).create();
      await File(
        p.join(tempDir.path, 'assets', 'data', 'config.json'),
      ).create();
      await File(p.join(tempDir.path, 'assets', 'readme.txt')).create();
      await File(p.join(tempDir.path, 'excluded', 'secret.json')).create();

      // Create test configuration
      config = AssetXConfig(
        destination: 'output.dart',
        sourcesInclude: [
          SourceConfig(path: p.join(tempDir.path, 'assets'), recursive: true),
        ],
        patternsInclude: ['*.png', '*.jpg', '*.json'],
        sourcesExclude: [
          SourceConfig(path: p.join(tempDir.path, 'excluded'), recursive: true),
        ],
      );
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('discovers files with pattern filtering', () async {
      final result = await discoverAssets(config);

      expect(result.files.length, equals(3)); // logo.png, icon.jpg, config.json

      final fileNames = result.files.map((f) => p.basename(f.path)).toList();
      expect(fileNames, contains('logo.png'));
      expect(fileNames, contains('icon.jpg'));
      expect(fileNames, contains('config.json'));
      expect(
        fileNames,
        isNot(contains('readme.txt')),
      ); // filtered out by patterns
    });

    test('excludes files from excluded sources', () async {
      final result = await discoverAssets(config);

      final filePaths = result.files.map((f) => f.path).toList();
      expect(filePaths.any((path) => path.contains('excluded')), isFalse);
      expect(filePaths.any((path) => path.contains('secret.json')), isFalse);
    });

    test('builds correct folder hierarchy', () async {
      final result = await discoverAssets(config);

      expect(result.folders.isNotEmpty, isTrue);

      // Check that we have the expected folder structure
      final folderPaths = result.folders.map((f) => f.path).toList();
      expect(folderPaths.any((path) => path.contains('assets')), isTrue);
      expect(folderPaths.any((path) => path.contains('images')), isTrue);
      expect(folderPaths.any((path) => path.contains('data')), isTrue);
    });

    test('respects recursive setting', () async {
      // Test non-recursive configuration
      final nonRecursiveConfig = AssetXConfig(
        destination: 'output.dart',
        sourcesInclude: [
          SourceConfig(
            path: p.join(tempDir.path, 'assets'),
            recursive: false, // Non-recursive
          ),
        ],
        patternsInclude: ['*.png', '*.jpg', '*.json', '*.txt'],
      );

      final result = await discoverAssets(nonRecursiveConfig);

      // Should only find files directly in assets/ folder, not in subfolders
      final fileNames = result.files.map((f) => p.basename(f.path)).toList();
      expect(fileNames, contains('readme.txt')); // Direct child
      expect(fileNames, isNot(contains('logo.png'))); // In subfolder
      expect(fileNames, isNot(contains('config.json'))); // In subfolder
    });

    test('handles ignore patterns correctly', () async {
      // Add ignore patterns to source
      final configWithIgnore = AssetXConfig(
        destination: 'output.dart',
        sourcesInclude: [
          SourceConfig(
            path: p.join(tempDir.path, 'assets'),
            recursive: true,
            ignore: ['*.txt'], // Ignore txt files
          ),
        ],
        patternsInclude: ['*.png', '*.jpg', '*.json', '*.txt'],
      );

      final result = await discoverAssets(configWithIgnore);

      final fileNames = result.files.map((f) => p.basename(f.path)).toList();
      expect(fileNames, isNot(contains('readme.txt'))); // Should be ignored
      expect(fileNames, contains('logo.png')); // Should be included
    });

    test('handles exclude patterns correctly', () async {
      final configWithExclude = AssetXConfig(
        destination: 'output.dart',
        sourcesInclude: [
          SourceConfig(path: p.join(tempDir.path, 'assets'), recursive: true),
        ],
        patternsInclude: ['*.png', '*.jpg', '*.json'],
        patternsExclude: ['*.jpg'], // Exclude jpg files
      );

      final result = await discoverAssets(configWithExclude);

      final fileNames = result.files.map((f) => p.basename(f.path)).toList();
      expect(fileNames, contains('logo.png')); // png should be included
      expect(fileNames, isNot(contains('icon.jpg'))); // jpg should be excluded
      expect(fileNames, contains('config.json')); // json should be included
    });

    test('works with empty configuration', () async {
      final emptyConfig = AssetXConfig(destination: 'output.dart');

      final result = await discoverAssets(emptyConfig);

      expect(result.files, isEmpty);
      expect(result.folders, isEmpty);
    });
  });
}
