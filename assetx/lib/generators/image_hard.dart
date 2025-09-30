import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'base.dart';
import '../model/lock.dart';
import '../utils/file/config.dart';
import '../utils/file/package_path.dart';

/// Generator for hardcode image assets (embedded as base64)
class ImageHardGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    // Note: .ico files are not supported by Flutter's Image.memory()
  ];

  const ImageHardGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final file = File(fileConfig.fullPath);
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);

      // Generate base64 content
      final bytes = file.readAsBytesSync();
      final base64Content = base64Encode(bytes);

      // Generate constants
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      final base64ConstName = '\$${fileConfig.uid}_base64';
      final bytesConstName = '\$${fileConfig.uid}_bytes';

      // Convert to Flutter package asset path format: packages/{packageName}/{relativePath}
      final relativePath = path.relative(
        fileConfig.fullPath,
        from: Directory.current.path,
      );
      final normalizedPath = relativePath.replaceAll('\\', '/');
      final packagePath = PackagePathUtils.getPackageAssetPath(normalizedPath);

      buffer.writeln('const String $pathConstName = \'$packagePath\';');
      buffer.writeln('const String $base64ConstName = \'$base64Content\';');
      buffer.writeln(
        'final Uint8List $bytesConstName = base64Decode($base64ConstName);',
      );
      buffer.writeln();

      // Create valid Dart identifier
      final dartIdentifier = IdentifierUtils.createValidIdentifier(
        fileName + extension.replaceAll('.', '_'),
      );
      varReferrers.add(
        'Image get $dartIdentifier => Image.memory($bytesConstName);',
      );
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }
}
