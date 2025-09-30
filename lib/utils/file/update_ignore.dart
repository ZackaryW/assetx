import 'dart:io';

/// Updates .gitignore and .pubignore files to include assetx.lock if not already present
Future<void> updateIgnoreFiles({String? directory}) async {
  final dir = directory ?? Directory.current.path;

  await _updateIgnoreFile(filePath: '$dir/.gitignore', fileName: '.gitignore');

  await _updateIgnoreFile(filePath: '$dir/.pubignore', fileName: '.pubignore');
}

/// Internal function to update a specific ignore file
Future<void> _updateIgnoreFile({
  required String filePath,
  required String fileName,
}) async {
  const lockFileName = 'assetx.lock';
  final file = File(filePath);

  try {
    List<String> lines = [];
    bool fileExists = await file.exists();

    if (fileExists) {
      final content = await file.readAsString();
      lines = content.split('\n');

      // Check if assetx.lock is already ignored
      final alreadyIgnored = lines.any((line) {
        final trimmed = line.trim();
        return trimmed == lockFileName ||
            trimmed == '/$lockFileName' ||
            trimmed == './$lockFileName';
      });

      if (alreadyIgnored) {
        print('$lockFileName is already present in $fileName');
        return;
      }
    }

    // Add assetx.lock to the ignore file
    if (fileExists && lines.isNotEmpty && lines.last.trim().isNotEmpty) {
      lines.add('');
    }

    lines.add('# AssetX lock file');
    lines.add(lockFileName);

    await file.writeAsString(lines.join('\n'));
    print('Added $lockFileName to $fileName');
  } catch (e) {
    print('Error updating $fileName: $e');
    rethrow;
  }
}
