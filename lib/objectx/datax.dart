import 'package:assetx/objectx/basex.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class DataX extends BaseX {
  DataX(super.path) {
    // if not json
    if (!path.endsWith('.json')) {
      throw Exception('DataX only supports json files.');
    }
  }

  Future<Map<String, dynamic>> get asset async {
    final cached = BaseX.getCacheMethod<Map<String, dynamic>>(path);
    if (cached != null) {
      return Map.unmodifiable(cached);
    }

    // If not cached, load the data
    final rawMap = await rootBundle.loadString(path);
    final map = json.decode(rawMap) as Map<String, dynamic>;
    BaseX.setCacheMethod(path, map);
    return Map.unmodifiable(map);
  }
}
