
import 'package:path/path.dart' as path;
import 'base.dart';
import '../model/lock.dart';
import '../utils/file/config.dart';

/// Generator for soft key-value assets (using rootBundle.loadString)
class KvSoftGenerator extends BaseGenerator {
  @override
  List<String> get supportedExtensions => ['.json', '.yaml', '.yml', '.env'];

  const KvSoftGenerator();

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    final buffer = StringBuffer();
    final varReferrers = <String>[];

    for (final fileConfig in fileCfgs) {
      final fileName = path.basenameWithoutExtension(fileConfig.fullPath);
      final extension = path.extension(fileConfig.fullPath);
      final normalizedPath = fileConfig.fullPath.replaceAll('\\', '/');

      // Generate path constant
      final pathConstName = '\$${fileConfig.uid}_epkg_path';
      buffer.writeln('const String $pathConstName = \'$normalizedPath\';');

      if (extension == '.json') {
        varReferrers.add(
          'Future<Map<String, dynamic>> get ${IdentifierUtils.createValidIdentifier(fileName)} => rootBundle.loadString($pathConstName).then((s) => jsonDecode(s) as Map<String, dynamic>);',
        );
      } else {
        varReferrers.add(
          'Future<String> get ${IdentifierUtils.createValidIdentifier(fileName)} => rootBundle.loadString($pathConstName);',
        );
      }
    }

    return GenerationResult(varReferrers.join('\n  '), buffer.toString());
  }
}