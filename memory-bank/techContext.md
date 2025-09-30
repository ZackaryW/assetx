# Technical Context

## Technology Stack
- **Language**: Dart 3.9.2+
- **Framework**: Flutter package (not app)
- **Dependencies**: 
  - `yaml: ^3.1.2` - Configuration parsing
  - `path: ^1.8.0` - Cross-platform path handling
  - **Builtin Types**: Predefined in `lib/model/builtin.dart`
  - Future: Code generation utilities

## Project Structure
```
lib/
├── assetx.dart              # Main library export
├── assetx_service.dart      # Core service (needs refactor for codegen)
├── model/
│   ├── config.dart          # Configuration models
│   └── lock.dart            # Lock file models (secondary)
└── generator/               # [TO ADD] Code generation logic
    ├── asset_generator.dart
    ├── class_builder.dart  
    └── templates/
```

## Current Implementation Status

### ✅ Completed
- Basic YAML configuration loading (`Config`, `ConfigEntry`)
- File system scanning with exclusion patterns
- Lock file generation (JSON format)
- Basic asset type detection (images, json, env)

### 🔄 Needs Refactoring 
- `AssetXService` - Currently focused on lock files, needs pivot to code generation
- Asset discovery logic - Good foundation but needs generator integration

### ❌ Missing (Core Features)
- **Byte Embedding Engine**: Read files and convert to base64-encoded ByteData
- **UID Generation System**: Create unique identifiers for each asset
- **Template System**: Generate base64 constants, ByteData objects, and accessor classes
- **CLI Interface**: Standalone command-line tool (no build_runner dependency)  
- **Part File Management**: Handle `part 'asset.x.dart'` pattern
- **Future**: Optional build_runner integration (like Flutter Slang)

## Development Environment
- **IDE**: VS Code with Dart/Flutter extensions
- **OS**: Windows (PowerShell)
- **Package Type**: Dart package (not Flutter app)

## Key Technical Decisions

### Configuration Format
- YAML over JSON for human readability
- List-based configuration (simple array of entries)
- Support for glob patterns in exclusions

### Generated Code Style
- Part files to keep user code separate from generated code
- UID-based constant names to avoid identifier conflicts (e.g., `$3290A103D8520AB0_base64`)
- Base64 string constants for file content embedding
- ByteData objects for efficient memory access (`ByteData.sublistView`)
- Dual accessor classes: FILEPATHS (path strings) and FILES (embedded bytes)
- Directory-based class organization with UID prefixes

### Asset Processing Handling
- Read asset files as bytes during generation
- Convert to base64 strings for embedding in Dart source
- Generate package-relative paths for FILEPATHS accessors
- Create UIDs to ensure unique identifiers across all assets
- Cross-platform path normalization using `path` package