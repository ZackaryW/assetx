# System Patterns

## Architecture Flow
Config → Discovery → Static Generation → Template Generation → Output

## Static Class Generation Pattern
When `lazy: false` is set for datax/envx types:
1. File detection via StaticGenerator.findNonLazyFiles()
2. Multi-format parsing with IoExt.loadAuto()
3. Class generation with direct property getters
4. Instance creation for AssetMap integration
5. Nested structure handling for deep objects

## Generated Class Structure
```dart
// From JSON: {"hello": "world", "nested": {"key": "value"}}
class $m0000 {
  String get hello => "world";
  get nested => $m0000_nestedInstance;
}
final $m0000Instance = $m0000();

class $m0000_nested {
  String get key => "value";
}
final $m0000_nestedInstance = $m0000_nested();
```

## Instance Integration Pattern
```dart
final Map<String, dynamic> instanceMap = {
  "assets.config.app": $m0000Instance,  // Static instance
  "assets.images.logo": ImageX("assets/images/logo.png"), // Asset instance
};
```

## File Organization
- **gen_static.dart**: StaticGenerator for non-lazy class generation
- **gen.dart**: TemplateProcessor for structure and instance mapping
- **ioext.dart**: Multi-format file loader (JSON/YAML/ENV/TOML)
- **toml.dart**: Custom TOML parser

## Access Patterns
```dart
// Direct instance access
String title = $m0000Instance.hello;

// AssetMap nested access
String title = AssetMap.assets.config.app.hello;

// Deep nested access
int value = AssetMap.assets.config.app.nested.key;
```
