import 'dart:io';
import 'package:path/path.dart' as path;
import 'base.dart';
import '../model/lock.dart';
import '../utils/file/config.dart';
import '../utils/file/package_path.dart';

/// Generator for soft image assets (using Image.asset)
class ImageSoftGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    // Note: .ico files are not supported by Flutter's Image.asset() either
  ];

  @override
  bool get requiresPubspecAsset => true;

  const ImageSoftGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath).replaceAll('.', '');

      // Convert to Flutter package asset path format: packages/{packageName}/{relativePath}
      final relativePath = path.relative(
        fileConfig.fullPath,
        from: Directory.current.path,
      );
      final normalizedPath = relativePath.replaceAll('\\', '/');
      final packagePath = PackagePathUtils.getPackageAssetPath(normalizedPath);

      // Generate path constant
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln('const String $pathConstName = \'$packagePath\';');

      varReferrers.add(
        'Image get ${IdentifierUtils.createValidIdentifier(fileName + extension)} => Image.asset($pathConstName);',
      );
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }
}
