import 'package:assetx/core/cache.dart';

class BaseX {
  static Function setCacheMethod = AssetXMemoryCache.set;
  static Function getCacheMethod = AssetXMemoryCache.get;
  final String path;
  final bool lazy;

  const BaseX(this.path, {this.lazy = true});
}
