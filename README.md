# AssetX - Asset Manager for Flutter

**AssetX** simplifies asset management in Flutter projects. It scans your asset folders and generates type-safe Dart code with nested access patterns, supporting both production builds and local testing.

## What It Does

AssetX scans your asset folders and creates easy-to-use code with nested dot notation:

```dart
// Instead of this:
Image.asset('assets/images/profile/user_avatar.png')

// Use this:
AssetMap.assets.images.profile.user_avatar.asset
```

## Quick Start

### 1. Add to Your Project
Add AssetX to your `pubspec.yaml`:

```yaml
dev_dependencies:
  assetx: ^1.0.0
```

### 2. Create Config File
Create `assetx.yaml` in your project root:

```yaml
folders:
  - assets
  - images
```

### 3. Run AssetX
```bash
dart run assetx
```

AssetX will create `lib/generated_assets.dart` with all your assets ready to use.

## Local Testing Support

For local development and testing, you can generate a version without package prefixes:

```yaml
folders:
  - assets
  - images
destination: lib/generated_assets.dart
local_destination: lib/generated_assets_local.dart  # For local testing
```

This generates two versions:
- **Production**: `packages/myapp/assets/...` (for builds)
- **Local**: `assets/...` (for testing)

Both support the same nested access patterns.

## How It Works

**Before AssetX:**
```dart
// Hard to remember, prone to typos
Image.asset('assets/images/icons/home.png')
Text(rootBundle.loadString('assets/data/config.json'))
```

**After AssetX:**
```dart
// Type-safe, autocomplete supported
AssetMap.assets.images.icons.home.asset
AssetMap.assets.data.config.asset
```

## Example

Given this folder structure:
```
assets/
  images/
    profile/
      avatar.png
      background.jpg
    icons/
      home.png
      settings.gif
  data/
    config.json
    users.json
```

AssetX generates this access pattern:
```dart
// Images
AssetMap.assets.images.profile.avatar.asset
AssetMap.assets.images.profile.background.asset
AssetMap.assets.images.icons.home.asset
AssetMap.assets.images.icons.settings.asset

// Data files
AssetMap.assets.data.config.asset
AssetMap.assets.data.users.asset
```

## Configuration

Create `assetx.yaml` in your project:

```yaml
# Basic setup - specify asset folders
folders:
  - assets
  - images

# Production output
destination: lib/generated_assets.dart

# Optional: Local testing output (without package prefixes)
local_destination: lib/generated_assets_local.dart

# Advanced: customize types and handlers
type_registry:
  image:
    file_extensions: [png, jpg, gif, webp]
  data:
    file_extensions: [json, yaml, txt]

# Custom file types
map_registry:
  profile:
    src: "lib/models.dart"
    target: "ProfileModel"
    passIn: [path, json]
```

## Features

### Type-Safe Access
- Use dot notation: `AssetMap.folder.subfolder.file`
- No hardcoded asset paths
- Full autocomplete support in your IDE

### Smart Asset Types
- **Images**: Automatically creates `ImageX` objects
- **Data**: Automatically creates `DataX` objects for JSON/YAML
- **Custom**: Support for your own asset types

### Dual Generation Mode
- **Production**: Package-prefixed paths for Flutter builds
- **Local**: Direct paths for development and testing
- **Same API**: Both versions use identical access patterns

### Conflict Resolution
- Handles duplicate filenames automatically
- `image.png` and `image.jpg` become `image_png` and `image_jpg`

### Automatic Updates
- Updates your `pubspec.yaml` automatically
- Adds all asset folders for you

### Flutter Integration
- Works with Flutter projects
- Supports all image formats (PNG, JPG, GIF, WebP)
- Package-aware asset paths for production

## Asset Types

| File Type | AssetX Type | Usage |
|-----------|-------------|-------|
| Images (png, jpg, gif, webp) | `ImageX` | `.asset` returns `Image` widget |
| Data (json, yaml, txt) | `DataX` | `.asset` loads file content |  
| Other files | `BaseX` | `.asset` provides raw asset access |
| Custom types | User-defined | Define in configuration |

## Commands

```bash
# Generate assets
dart run assetx

# Generate with custom config
dart run assetx --config my_config.yaml
```

## Best Practices

1. **Organize assets**: Use folders to group related assets
2. **Clear naming**: Use descriptive filenames like `user_avatar.png`
3. **Regular updates**: Run AssetX when adding new assets
4. **Use local mode**: Test with `local_destination` during development

## Troubleshooting

**Problem**: AssetX cannot find assets  
**Solution**: Verify folders are listed in `assetx.yaml`

**Problem**: Generated code has compilation errors  
**Solution**: Run `dart run assetx` again after adding assets

**Problem**: Assets not displaying in app  
**Solution**: Import `generated_assets.dart` in your Dart files

## Summary

AssetX eliminates the need for hardcoded asset paths by generating type-safe, autocomplete-friendly code with nested access patterns. The dual generation mode supports both production builds and local testing with the same clean API.
