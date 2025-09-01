import 'package:assetx/objectx/basex.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FolderX extends BaseX {
  const FolderX(super.path);

  bool hasFile(String fileName) {
    final filePath = '$path/$fileName';
    final cacheKey = 'fileExistCheck:$filePath';

    final hasCache = BaseX.getCacheMethod<bool>(cacheKey);
    if (hasCache != null) return hasCache;

    // Check if file exists in asset bundle
    bool exists = false;
    dynamic targetValue;
    try {
      // if is image format
      if (filePath.endsWith('.png') ||
          filePath.endsWith('.jpg') ||
          filePath.endsWith('.jpeg')) {
        targetValue = Image.asset(filePath);
      } else {
        targetValue = rootBundle.load(filePath);
      }
      exists = targetValue != null;
    } catch (e) {
      exists = false;
    }

    // Cache the result
    BaseX.setCacheMethod(cacheKey, exists);
    if (targetValue != null) {
      BaseX.setCacheMethod(filePath, targetValue);
    }

    return exists;
  }

  String assetPath(String fileName) {
    return '$path/$fileName';
  }

  T asset<T>(String fileName) {
    // get exists
    final exists = hasFile(fileName);
    if (!exists) {
      throw Exception('Asset not found: $fileName');
    }
    return BaseX.getCacheMethod<T>(assetPath(fileName))!;
  }
}
