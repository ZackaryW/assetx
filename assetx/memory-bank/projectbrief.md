# AssetX Project Brief

## Core Vision
AssetX is a Flutter/Dart code generation tool inspired by Flutter Slang, but focused on **asset mapping and code generation** rather than translations. The tool supports predefined asset types with hard/soft variants:

**Built-in Types**: `["image_hard", "image_soft", "kv_hard", "kv_soft"]`
- **_hard suffix**: Embeds assets as base64-encoded bytes directly in source code
- **_soft suffix**: Generates type-safe path constants for standard Flutter asset loading

## Key Objectives
1. **Byte Embedding**: Read asset files and embed them as base64-encoded ByteData in generated code
2. **Runtime Optimization**: Skip Flutter asset loading entirely - assets are available at compile time
3. **UID-based Naming**: Generate unique identifiers for each asset to avoid naming conflicts
4. **Tree Shaking**: Enable maximum dead code elimination through direct embedding
5. **Type Safety**: Provide compile-time guarantees with strongly-typed asset accessors

## Similar Tools
- **Flutter Slang**: Generates translation classes from JSON/YAML files
  - Works without build_runner (standalone CLI)
  - Future: Optional build_runner integration
- **AssetX**: Generates asset accessor classes from file system scanning
  - Following Slang's approach: CLI-first, build_runner later

## Expected Workflow
1. Developer configures `assetx.yaml` with asset paths and types
2. AssetX scans the configured directories 
3. Generates `asset.x.dart` (or similar) with strongly-typed asset classes
4. Developer imports and uses generated classes for type-safe asset access

## Target Output Example

**Hardcode Mode** (embedded bytes):
```dart
// Embeds file content as base64
Image.memory(Assets.folder123.$files.logo_png.buffer.asUint8List())
```

**Regular Mode** (asset paths):
```dart
// Uses Flutter's standard asset loading
Image.asset(Assets.folder123.$paths.logo_png_path)
```

Both modes provide:
- UID-based naming to avoid conflicts
- Type-safe accessors with IDE support
- Separate `$files` and `$paths` classes

## Not Goals
- Runtime asset discovery
- Simple file listing/tracking
- Generic configuration management