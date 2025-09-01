import 'dart:io';

/// Updates pubspec.yaml with asset paths
void updatePubspecAssets(List<String> assetPaths, {String? pubspecPath}) {
  final path = pubspecPath ?? 'pubspec.yaml';
  final file = File(path);

  if (!file.existsSync()) {
    throw Exception('pubspec.yaml not found at: $path');
  }

  final content = file.readAsStringSync();
  final updatedContent = _updateFlutterAssetsSection(content, assetPaths);

  file.writeAsStringSync(updatedContent);
}

/// Updates the flutter assets section in pubspec content
String _updateFlutterAssetsSection(String content, List<String> assetPaths) {
  final lines = content.split('\n');
  final result = <String>[];

  bool inFlutterSection = false;
  bool assetsAdded = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (_isFlutterSectionStart(line)) {
      inFlutterSection = true;
      result.add(line);
      continue;
    }

    if (inFlutterSection && _isNextTopLevelSection(line)) {
      // Leaving flutter section - add assets if not already added
      if (!assetsAdded) {
        result.addAll(_generateAssetsLines(assetPaths));
        assetsAdded = true;
      }
      inFlutterSection = false;
    }

    if (inFlutterSection && _isAssetsSection(line)) {
      // Replace existing assets section
      if (!assetsAdded) {
        result.addAll(_generateAssetsLines(assetPaths));
        assetsAdded = true;
      }
      // Skip existing assets section
      i = _skipAssetsSection(lines, i);
      continue;
    }

    result.add(line);
  }

  // If we ended in flutter section without adding assets
  if (inFlutterSection && !assetsAdded) {
    result.addAll(_generateAssetsLines(assetPaths));
  }

  return result.join('\n');
}

/// Checks if line starts the flutter section
bool _isFlutterSectionStart(String line) {
  return line.trimRight() == 'flutter:';
}

/// Checks if line is the start of a new top-level section
bool _isNextTopLevelSection(String line) {
  final trimmed = line.trim();
  return trimmed.isNotEmpty && !line.startsWith('  ');
}

/// Checks if line starts the assets subsection
bool _isAssetsSection(String line) {
  return line.startsWith('  assets:');
}

/// Skips the existing assets section and returns the index after it
int _skipAssetsSection(List<String> lines, int startIndex) {
  int i = startIndex + 1;
  while (i < lines.length) {
    final line = lines[i];
    // Stop if we hit a non-asset line (not indented 4+ spaces or empty)
    if (line.trim().isNotEmpty && !line.startsWith('    ')) {
      return i - 1; // Return index of last asset line
    }
    i++;
  }
  return i - 1;
}

/// Generates the assets section lines
List<String> _generateAssetsLines(List<String> assetPaths) {
  if (assetPaths.isEmpty) return [];

  final lines = <String>['  assets:'];
  for (final assetPath in assetPaths) {
    lines.add('    - $assetPath');
  }
  return lines;
}
