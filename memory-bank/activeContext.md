# Active Context

## Current Focus: CLI Interface Impleme## Implementation Status

✅ **Completed Core Features**:
- Builtin type system with 4 generators (`image_hard`, `image_soft`, `kv_hard`, `kv_soft`)
- Generator registry for dynamic extension
- UID generation with collision detection
- File discovery with generator validation (`canHandle`)
- Lock file generation and management
- Dart code generation pipeline

🔄 **Current Focus**:
- CLI interface implementation (`bin/assetx.dart`)
- Command parsing and validation
- Configuration management commands
- Integration with existing services
The core generation system is now complete with builtin generators and registry. Next phase is implementing the standalone CLI interface for managing configurations and generating code.

**Key Insight**: Like Flutter Slang, AssetX works **without build_runner** using a standalone CLI approach. The CLI provides complete project management through simple commands.

## Immediate Next Steps

### 1. CLI Interface (`bin/assetx.dart`)
Create standalone CLI tool with four main commands:
- `assetx add <type> <path>` - Add new asset configuration with collision detection
- `assetx remove <path>` - Remove asset configuration 
- `assetx sync` - Update lock file and run ignore file updates
- `assetx gen` - Generate Dart code to target file

### 2. Command Implementation Details
Looking at the provided example structure:
```
assets/
├── images_1/file_example_favicon.ico, file_example_JPG_100kB.jpg
├── images_2/file_example_JPG_100kB.jpg  
├── kv_1/test.env, ww.json
└── kv_2/ww2.json
```

Should generate something like:

## CLI Command Specifications

### `assetx add <type> <path>`
- **Purpose**: Add new asset configuration entry to `assetx.yaml`
- **Validation**: 
  - Type must be one of: `image_hard`, `image_soft`, `kv_hard`, `kv_soft`
  - Path collision detection (no overlapping folders)
  - Subfolder conflict checking
- **Behavior**: Updates config file, validates against existing entries

### `assetx remove <path>`
- **Purpose**: Remove asset configuration by path
- **Validation**: Path must exist in current configuration
- **Behavior**: Updates config file, removes matching entries

### `assetx sync`
- **Purpose**: Update lock file and ignore files
- **Actions**: 
  1. Run file discovery to update `assetx.lock`
  2. Execute `update_ignore.dart` to update gitignore/etc
- **Validation**: Ensures all generators can handle discovered files

### `assetx gen`
- **Purpose**: Generate Dart code to target file
- **Actions**:
  1. Load lock file
  2. Use generators to create asset classes
  3. Write to configured target (default: `lib/asset.dart`)
- **Output**: Complete `asset.x.dart` with embedded/loading code

## Key Decisions Needed
1. **Type Implementation**: Implement the builtin type handlers for `["image_hard", "image_soft", "kv_hard", "kv_soft"]`
2. **UID Generation**: How to create unique, deterministic identifiers for each FileConfig?
3. **Type-Specific Logic**:
   - `image_hard`: `Image.memory(bytes)` from embedded base64
   - `image_soft`: `Image.asset(path)` with Flutter loading
   - `kv_hard`: Parsed JSON objects embedded in source
   - `kv_soft`: `rootBundle.loadString()` for runtime loading
4. **FileConfig Enhancement**: Add UID field and handle builtin type processing

## Current Understanding Gaps
- UID generation algorithm (hash-based? random? deterministic?)
- Large asset handling (size limits, lazy loading strategies?)
- JSON/text asset parsing (embedded as strings vs parsed objects?)
- Package path resolution for epkg_path generation

## Clarified Requirements
- **Build Strategy**: Standalone CLI tool (no build_runner dependency initially)
- **Inspiration**: Flutter Slang's approach to code generation  
- **Builtin Types**: Predefined `["image_hard", "image_soft", "kv_hard", "kv_soft"]` system
- **Hard/Soft Pattern**: _hard (embedded) vs _soft (asset loading) for each asset category
- **Configuration**: Use builtin types in assetx.yaml configuration entries
- **Future Plans**: Optional build_runner integration later