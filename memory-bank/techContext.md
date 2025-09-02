# Technical Context

## Technology Stack
- **Language**: Dart
- **Dependencies**: `path`, `yaml`, `json_annotation`, `build_runner`
- **Testing**: Flutter Web validation
- **Parsing**: Custom IoExt system for multi-format support

## File Structure
```
lib/
├── gen/
│   ├── config.dart        # Configuration models  
│   ├── gen.dart           # Template processing
│   ├── gen_static.dart    # Static class generation
│   └── default.dart       # Default mappings
├── objectx/               # Asset type classes
├── utils/                 # Discovery and utilities
│   ├── lookup.dart
│   ├── codebuffer.dart
│   ├── pubspec_resolve.dart
│   └── io/
│       ├── ioext.dart     # Multi-format loader
│       └── toml.dart      # TOML parser
bin/
└── assetx.dart           # CLI interface
```

## Asset Types
- **DataX (lazy: false)**: JSON/YAML/ENV/TOML → Static classes
- **DataX (lazy: true)**: Traditional async loading
- **ImageX**: Image formats with Flutter integration
- **EnvX (lazy: false)**: Environment files → Static properties

## Multi-Format Parsing
- **JSON**: Native `dart:convert` 
- **YAML**: `yaml` package
- **ENV**: Custom key=value parser
- **TOML**: Custom TomlLoader

## Generation Pattern
```dart
// From data file to static class
class $m0000 {
  String get hello => "world";
  get nested => $m0000_nestedInstance;
}
final $m0000Instance = $m0000();
```

## Integration Architecture
Instance map uses generated instances:
```dart
final instanceMap = {
  "assets.config.app": $m0000Instance, // const instance
};
```

## CLI Features
- Multi-format file detection and processing
- Static class generation based on lazy configuration
- Error handling for unparseable files
- Dual output (production/local paths)
