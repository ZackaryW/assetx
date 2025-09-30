
import 'package:path/path.dart' as path;
import 'base.dart';
import '../model/lock.dart';
import '../utils/file/config.dart';
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
    '.ico',
  ];

  const ImageSoftGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath).replaceAll('.', '');
      final normalizedPath = fileConfig.fullPath.replaceAll('\\', '/');

      // Generate path constant
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln('const String $pathConstName = \'$normalizedPath\';');

      varReferrers.add(
        'Image get ${IdentifierUtils.createValidIdentifier(fileName + extension)} => Image.asset($pathConstName);',
      );
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }
}
