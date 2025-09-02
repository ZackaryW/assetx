# Product Context

## Problems Solved
- Eliminates hardcoded asset paths that break silently
- Removes runtime JSON/YAML parsing for configuration files
- Provides type-safe access to both assets and parsed data

## User Workflow
1. Configure `assetx.yaml` with asset folders and data parsing rules
2. Run `dart run assetx` to generate mappings
3. Access assets: `AssetMap.assets.images.profile.path`
4. Access parsed data: `AssetMap.assets.config.app.title`
5. Use in Flutter: `Image.asset(AssetMap.assets.image.x.path)`

## Before vs After
**Before**: 
```dart
final config = jsonDecode(await rootBundle.loadString('assets/config.json'));
final title = config['app']['title']; // nullable, runtime parsing
```

**After**: 
```dart
final title = AssetMap.assets.config.app.title; // direct property access
```

## Key Benefits
- Type safety for asset paths
- IDE autocomplete for all assets and data properties
- No runtime JSON parsing overhead
- Multi-format support (JSON/YAML/ENV/TOML)
