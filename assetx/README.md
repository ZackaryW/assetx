# AssetX

Advanced Flutter asset code generation with type safety and collision resolution.

## Features

AssetX generates strongly-typed Dart classes from your asset files with four builtin asset types:

### Hard Types (Embedded Assets)
- **`image_hard`**: Embeds images as base64 ByteData for zero runtime loading
- **`kv_hard`**: Embeds JSON/YAML as parsed Map objects for immediate access

### Soft Types (Path-Based Assets)
- **`image_soft`**: Generates type-safe Image.asset() calls with path constants
- **`kv_soft`**: Generates type-safe rootBundle loading with Future returns

## Key Benefits

- 🔒 **Type Safety**: Compile-time asset validation with IDE autocomplete
- ⚡ **Zero Runtime Loading**: Hard types embed assets directly in code
- 🌳 **Tree Shaking**: Unused assets eliminated from builds
- 🎯 **Collision Resolution**: Hash-based unique class names prevent folder name conflicts
- 📱 **Cross-Package Support**: Proper package path handling for dependencies
- 🚫 **Format Compatibility**: Automatic exclusion of unsupported formats (ICO)

## Quick Start

1. **Add dependency**:
```yaml
dependencies:
  assetxf: ^0.0.1

dev_dependencies:
  assetx: ^0.0.1
```

2. **Create configuration** (`assetx.yaml`):
```yaml
- path: "assets/icons"
  type: "image_hard"
  exclusions: []
  recursive: false

- path: "assets/images"
  type: "image_soft"
  exclusions: []
  recursive: false

- path: "assets/config"
  type: "kv_hard"
  exclusions: ["*.env"]
  recursive: true
```

3. **Generate code**:
```bash
dart run assetx gen
```

4. **Use generated assets**:
```dart
import 'package:assetxf/assetxf.dart';
import 'lib/asset.x.dart';

// Hard embedded assets (zero runtime loading)
Image.memory(assetX.myApp.icons.$files.logoIcon)
final config = assetX.myApp.config.$files.appSettings; // Map<String, dynamic>

// Soft path-based assets
Image.asset(toInternalPath(assetX.myApp.images.$paths.heroImage))
final data = await assetX.myApp.data.$files.userData; // Future<Map<String, dynamic>>
```

## CLI Commands

- `assetx add <type> <path>` - Add asset configuration
- `assetx remove <path>` - Remove asset configuration  
- `assetx sync` - Update lock file and ignore files
- `assetx gen` - Generate Dart code

## Generated Structure

AssetX creates collision-resistant class hierarchies:

```dart
// Multiple folders with same name get unique classes
class Images_a1b2c3d4 { /* assets/images */ }
class Images_x9y8z7w6 { /* config/images */ }

// But readable getter names with conflict resolution
class MyApp {
  Images_a1b2c3d4 get images => const Images_a1b2c3d4();   // First occurrence
  Images_x9y8z7w6 get images1 => const Images_x9y8z7w6();  // Conflict resolved
}
```

## Folder Name Collision Resolution

AssetX handles complex project structures where multiple directories share the same name:

- `assets/icons` and `config/icons` generate unique classes
- Hash-based class names prevent compilation conflicts  
- Readable getter names with automatic numbering (`icons`, `icons1`, etc.)

## Format Support

- **Images**: JPG, PNG, GIF, BMP, WebP, SVG (ICO excluded due to Flutter limitations)
- **Key-Value**: JSON, YAML, YML (ENV files configurable via exclusions)

## Integration

Works seamlessly as a standalone CLI tool (no build_runner required) following the Flutter Slang approach. Perfect for:

- Package development with cross-package asset access
- Large applications with complex asset hierarchies
- Performance-critical apps needing embedded assets
- Type-safe asset management

## License

MIT License - see LICENSE file for details.
