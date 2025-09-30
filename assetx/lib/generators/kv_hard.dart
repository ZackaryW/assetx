import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'base.dart';
import '../model/lock.dart';
import '../utils/file/config.dart';
import '../utils/file/package_path.dart';

/// Generator for hardcode key-value assets (embedded as parsed data)
class KvHardGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => ['.json', '.yaml', '.yml', '.env'];

  const KvHardGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final file = File(fileConfig.fullPath);
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);

      // Parse content based on file type
      final content = file.readAsStringSync();
      dynamic parsedContent;

      // Always generate path constant for file path accessors
      final relativePath = path.relative(
        fileConfig.fullPath,
        from: Directory.current.path,
      );
      final normalizedPath = relativePath.replaceAll('\\', '/');
      final packagePath = PackagePathUtils.getPackageAssetPath(normalizedPath);
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln('const String $pathConstName = \'$packagePath\';');

      if (extension == '.json') {
        parsedContent = jsonDecode(content);
        final dataConstName = '\$${fileConfig.uid}_data';
        buffer.writeln(
          'const Map<String, dynamic> $dataConstName = ${_formatMapConstant(parsedContent)};',
        );
        varReferrers.add(
          'Map<String, dynamic> get ${IdentifierUtils.createValidIdentifier(fileName)} => $dataConstName;',
        );
      } else {
        // For other formats, embed as string
        final dataConstName = '\$${fileConfig.uid}_content';
        buffer.writeln(
          'const String $dataConstName = \'${content.replaceAll('\'', '\\\'')}\'',
        );
        varReferrers.add(
          'String get ${IdentifierUtils.createValidIdentifier(fileName)} => $dataConstName;',
        );
      }
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }

  String _formatMapConstant(Map<String, dynamic> map) {
    // Simple map formatting for constants - in production would need more robust handling
    final entries = map.entries
        .map((e) => '\'${e.key}\': ${_formatValue(e.value)}')
        .join(', ');
    return '{$entries}';
  }

  String _formatValue(dynamic value) {
    if (value is String) return '\'${value.replaceAll('\'', '\\\'')}\'';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is Map) {
      return _formatMapConstant(Map<String, dynamic>.from(value));
    }
    if (value is List) return '[${value.map(_formatValue).join(', ')}]';
    return 'null';
  }
}
