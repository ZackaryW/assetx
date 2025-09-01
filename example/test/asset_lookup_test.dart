import 'package:flutter_test/flutter_test.dart';
import 'package:assetx/utils/lookup.dart';

void main() {
  group('AssetLookup Tests', () {
    late AssetLookupFolder rootFolder;
    late AssetLookupFolder subFolder;
    late AssetLookupFile jsonFile;
    late AssetLookupFile imageFile;

    setUp(() {
      // Create test hierarchy
      rootFolder = AssetLookupFolder('assets', null, true);
      subFolder = AssetLookupFolder('assets/data', rootFolder, true);
      jsonFile = AssetLookupFile('assets/data/config.json', subFolder);
      imageFile = AssetLookupFile('assets/image.png', rootFolder);

      // Build relationships
      rootFolder.children.addAll([subFolder, imageFile]);
      subFolder.children.add(jsonFile);
    });

    test('AssetLookup normalizedPath works correctly', () {
      final windowsPath = AssetLookupFile('assets\\data\\file.txt', null);
      expect(windowsPath.normalizedPath, equals('assets/data/file.txt'));

      final unixPath = AssetLookupFile('assets/data/file.txt', null);
      expect(unixPath.normalizedPath, equals('assets/data/file.txt'));
    });

    test('AssetLookupFile basename and extension work correctly', () {
      expect(jsonFile.basename, equals('config.json'));
      expect(jsonFile.extension, equals('.json'));

      expect(imageFile.basename, equals('image.png'));
      expect(imageFile.extension, equals('.png'));

      final noExtFile = AssetLookupFile('README', null);
      expect(noExtFile.basename, equals('README'));
      expect(noExtFile.extension, equals(''));
    });

    test('iterSub filters files correctly', () {
      final jsonFiles = rootFolder
          .iterSub(folders: false, patterns: ['*.json'])
          .toList();

      expect(jsonFiles.length, equals(1));
      expect(
        (jsonFiles.first as AssetLookupFile).basename,
        equals('config.json'),
      );
    });

    test('iterSub filters folders correctly', () {
      final dataFolders = rootFolder
          .iterSub(files: false, patterns: ['*data*'])
          .toList();

      expect(dataFolders.length, equals(1));
      expect(dataFolders.first.path, contains('data'));
    });

    test('iterSub with no patterns returns all matching types', () {
      final allFiles = rootFolder.iterSub(folders: false).toList();
      expect(allFiles.length, equals(2)); // jsonFile and imageFile

      final allFolders = rootFolder.iterSub(files: false).toList();
      expect(allFolders.length, equals(1)); // subFolder
    });

    test('iterSub with multiple patterns works correctly', () {
      final multiPattern = rootFolder
          .iterSub(folders: false, patterns: ['*.json', '*.png'])
          .toList();

      expect(multiPattern.length, equals(2));
    });

    test('parent-child relationships work correctly', () {
      expect(subFolder.parent, equals(rootFolder));
      expect(jsonFile.parent, equals(subFolder));
      expect(imageFile.parent, equals(rootFolder));
      expect(rootFolder.parent, isNull);
    });

    test('children collections contain correct items', () {
      expect(rootFolder.children.length, equals(2));
      expect(rootFolder.children, contains(subFolder));
      expect(rootFolder.children, contains(imageFile));

      expect(subFolder.children.length, equals(1));
      expect(subFolder.children, contains(jsonFile));
    });

    test('fullyIndexed property works correctly', () {
      expect(rootFolder.fullyIndexed, isTrue);
      expect(subFolder.fullyIndexed, isTrue);

      final partialFolder = AssetLookupFolder('partial', null, false);
      expect(partialFolder.fullyIndexed, isFalse);
    });
  });
}
