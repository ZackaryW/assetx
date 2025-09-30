import 'package:assetx/model/lock.dart';

/// Result of code generation containing both constants and accessor information
class GenerationResult {
  final String varReferrer;
  final String partFileContent;
  final List<FileAccessor> accessors;

  GenerationResult(this.varReferrer, this.partFileContent, [this.accessors = const []]);
}

/// Information about how to access a file in generated code
class FileAccessor {
  final String assetName;
  final String accessorCode;
  final String filePathAccessor;
  
  FileAccessor({
    required this.assetName,
    required this.accessorCode,
    required this.filePathAccessor,
  });
}

abstract class BaseGenerator {
  List<String> get supportedExtensions;

  const BaseGenerator();

  bool canHandle(String extension) {
    return supportedExtensions.contains(extension.toLowerCase());
  }

  GenerationResult generateCode(List<FileConfig> fileCfgs);
  
  /// Generate structured accessor information for files
  List<FileAccessor> generateAccessors(List<FileConfig> fileCfgs) {
    // Default implementation extracts from varReferrer - can be overridden
    final result = generateCode(fileCfgs);
    final accessors = <FileAccessor>[];
    
    if (result.accessors.isNotEmpty) {
      return result.accessors;
    }
    
    // Parse varReferrer as fallback (for backward compatibility)
    final lines = result.varReferrer.split('\n');
    for (int i = 0; i < lines.length && i < fileCfgs.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        final file = fileCfgs[i];
        final assetName = _extractAssetNameFromAccessor(line);
        accessors.add(FileAccessor(
          assetName: assetName,
          accessorCode: line,
          filePathAccessor: 'String get $assetName => \$${file.uid}_epkg_path;',
        ));
      }
    }
    
    return accessors;
  }
  
  String _extractAssetNameFromAccessor(String accessorLine) {
    // Extract asset name from "Type get assetName => ..."
    final regex = RegExp(r'get\s+(\w+)\s+=>');
    final match = regex.firstMatch(accessorLine);
    return match?.group(1) ?? 'unknown';
  }
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