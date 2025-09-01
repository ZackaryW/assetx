# AssetX - Type-Safe Asset Mapping for Flutter

Generate nested, type-safe asset access for Flutter. No more hardcoded paths.

## Usage

```dart
// Instead of this:
Image.asset('assets/images/profile/user_avatar.png')

// Use this:
AssetMap.assets.images.profile.user_avatar.asset
```

## Setup

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  assetx: ^1.0.0
```

2. Create `assetx.yaml`:
```yaml
destination: lib/generated_assets.dart
sources_include:
  - path: assets/
    recursive: true
type_registry:
  image:
    file_extensions: [png, jpg, gif]
  data:
    file_extensions: [json, yaml]
map_registry:
  image:
    builtin: imagex
  data:
    builtin: datax
```

3. Run: `dart run assetx`

## Features

- **Type-safe**: `AssetMap.folder.subfolder.file.asset`
- **Unified asset tree**: Single organized structure for all your assets
- **Auto pubspec updates**: Automatically adds assets to `pubspec.yaml`
- **Less fragmented code**: One import, access everything
- **Dual mode**: Production (`packages/...`) and local (`assets/...`) paths
- **Custom types**: Define your own asset handlers
- **Pattern matching**: Include/exclude by file patterns

## Configuration Options

```yaml
# Basic
destination: lib/generated_assets.dart
sources_include:
  - path: assets/
    recursive: true

# Exclude paths/patterns  
sources_exclude:
  - path: assets/temp/
patterns_exclude: ["*.tmp"]

# Custom types
type_registry:
  custom:
    pattern: ["*/config.json"]
map_registry:
  custom:
    src: "lib/models.dart::Config"
```

## Summary

AssetX creates a unified asset tree with automatic pubspec management. One configuration, one import, access all your assets through a clean nested structure.
