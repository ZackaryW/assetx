import 'package:assetx/objectx/basex.dart';
import 'package:assetx/utils/io/ioext.dart';
import 'package:flutter/services.dart';

class DataX extends BaseX {
  DataX(super.path);

  Future<Map<String, dynamic>> get asset async {
    final cached = BaseX.getCacheMethod<Map<String, dynamic>>(path);
    if (cached != null) {
      return Map.unmodifiable(cached);
    }

    // If not cached, load the data
    final rawString = await rootBundle.loadString(path);
    final map = IoExt.auto(path, rawString, (path) => DataX(path));
    BaseX.setCacheMethod(path, map);
    return Map.unmodifiable(map);
  }

  dynamic operator [](String key) async {
    final asset = await this.asset;
    if (key.contains(".")) {
      final keys = key.split(".");
      dynamic value = asset;
      for (final k in keys) {
        value = value[k];
      }
      return value;
    }

    return asset[key];
  }
}
