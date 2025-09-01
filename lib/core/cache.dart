
class AssetXMemoryCache {
  static final Map<String, dynamic> _cache = {};

  static T? get<T>(String key) {
    return _cache[key] as T?;
  }

  static void set(String key, dynamic value) {
    _cache[key] = value;
  }

  static void clear() {
    _cache.clear();
  }
}