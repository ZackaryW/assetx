import 'package:assetx/model/lock.dart';

class GenerationResult {
  final String varReferrer;
  final String partFileContent;

  GenerationResult(this.varReferrer, this.partFileContent);
}

abstract class BaseGenerator {
  List<String> get supportedExtensions;

  const BaseGenerator();

  bool canHandle(String extension) {
    return supportedExtensions.contains(extension.toLowerCase());
  }

  GenerationResult generateCode(List<FileConfig> fileCfgs);
}

class CustomGenerator extends BaseGenerator {
  final List<String> extensions;
  final GenerationResult Function(List<FileConfig>) generatorFunc;
  const CustomGenerator(this.extensions, this.generatorFunc);

  @override
  List<String> get supportedExtensions => extensions;

  @override
  GenerationResult generateCode(List<FileConfig> fileCfgs) {
    return generatorFunc(fileCfgs);
  }
}