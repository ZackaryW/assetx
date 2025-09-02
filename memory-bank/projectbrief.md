# AssetX Project Brief

## Purpose
Code generation tool that creates type-safe asset mappings for Flutter projects.

## Core Functions
- Scan asset folders and generate Dart access code
- Create nested folder access: `AssetMap.assets.folder.file`
- Parse data files (JSON/YAML/ENV/TOML) into static classes when `lazy: false`
- Generate both production and local versions

## Current Output
```dart
// Static classes from parsed data files
class $m0000 {
  String get title => "My App";
  get nested => $m0000_nestedInstance;
}
final $m0000Instance = $m0000();

// Asset mapping
final Map<String, dynamic> instanceMap = {
  "assets.config.app": $m0000Instance,
  "assets.images.logo": ImageX("assets/images/logo.png"),
};

// Nested access
class AssetMap {
  static get assets => $c0000Instance;
}
```

## Key Principle
Simple asset mapping with optional data parsing capabilities.
