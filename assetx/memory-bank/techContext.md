# Technical Context

## Technology Stack
- **Language**: Dart 3.9.2+
- **Framework**: Flutter package (not app)
- **Dependencies**: 
  - `yaml: ^3.1.2` - Configuration parsing
  - `path: ^1.8.0` - Cross-platform path handling
  - `crypto: ^3.0.3` - SHA256 hashing for UID generation
  - `args: ^2.4.2` - CLI argument parsing
  - **AssetXF Package**: Reference to `AssetX` class for extension-based generation
- **Builtin Types**: Predefined in `lib/model/builtin.dart`
- **CLI Executable**: Configured in `pubspec.yaml` as `assetx`

## Project Structure
```
bin/
└── assetx.dart              # CLI executable entry point

lib/
├── assetx.dart              # Main library export  
├── assetx_service.dart      # Core service with complete code generation
├── core/
│   ├── asset_discovery.dart   # File system scanning with generator validation
│   ├── code_generation.dart   # Hash-based collision resolution and class generation
│   └── lock_file_service.dart # Lock file management with UID collision detection
├── generators/
│   ├── base.dart            # BaseGenerator abstract class with FileAccessor support
│   ├── builtin.dart         # Four builtin generators + registry with ICO exclusion
│   ├── image_hard.dart      # Base64 embedding generator (excludes ICO)
│   ├── image_soft.dart      # Asset path generator (excludes ICO)
│   ├── kv_hard.dart         # JSON/YAML embedding generator
│   └── kv_soft.dart         # JSON/YAML path generator
├── model/
│   ├── config.dart          # Configuration models with validation
│   └── lock.dart            # Lock file models with UID generation
└── utils/
    └── file/
        ├── config.dart        # IdentifierUtils for Dart naming + hash-based collision resolution
        ├── package_path.dart  # PackagePathUtils for asset path generation
        ├── pubspec_resolve.dart # PubspecResolver for parsing pubspec.yaml
        ├── pubspec_update.dart  # Automatic pubspec.yaml asset updates
        └── update_ignore.dart   # Gitignore management
```

## Current Implementation Status

### ✅ Production Ready
- Complete YAML configuration system with builtin type validation
- Four builtin generators (`ImageHardGenerator`, `ImageSoftGenerator`, `KvHardGenerator`, `KvSoftGenerator`)
- Generator registry system for extensibility
- SHA256-based UID generation with collision detection
- Complete CLI interface with all four commands (add/remove/sync/gen)
- Cross-platform path normalization (Windows/Unix compatibility)
- Centralized identifier generation utilities
- Base64 byte embedding for hardcode modes
- Asset path loading for soft modes
- Automatic gitignore management
- Lock file generation and management
- **🎉 CRITICAL: Hash-Based Folder Name Collision Resolution** with `IdentifierUtils.createUniqueClassName()`
- **toInternalPath Utility Function** for same-package asset path conversion
- **ICO File Format Exclusion** from both hard and soft generators due to Flutter limitations
- **Readable API with Conflict Resolution** using numbered getters for duplicate folder names

### ✅ Completed Architecture Improvements
- **Direct Generation**: Simplified `asset.x.dart` generation at target location
- **Proper Generator Delegation**: CodeGenerationService now correctly delegates to generators
- **Enhanced BaseGenerator**: Added FileAccessor class and generateAccessors() method
- **Type-Safe Code Generation**: All accessors have correct, specific types
- **Complete Asset Support**: All 4 builtin types generate proper constants and accessors
- **Automatic Pubspec Integration**: Soft assets automatically added to pubspec.yaml during generation
- **Package-Aware Asset Paths**: All generated paths use `packages/{packageName}/` format
- **Cross-Package Compatibility**: Generated code works when used as external dependency
- **Extension Pattern**: Creating extensions on `AssetX` class from `assetxf.dart` package
- **Root Folder Classes**: Generating classes that include all root folder instances
- **Simplified API**: Final extension structure: `extension ... on AssetX { get {classname} }`

### 🔄 Continuous Improvement
## Recent Major Architecture Improvements ✅

### Fixed Generator Delegation (Major Refactoring)
**Problem**: CodeGenerationService was manually reimplementing generator functionality
- Had `_getFileAccessorForType()` that created incorrect accessors like `ByteData get name => bytes` instead of `Image get name => Image.memory(bytes)`
- Generator `varReferrer` containing proper accessors was completely ignored

**Solution**: Proper delegation architecture
1. **Enhanced BaseGenerator**: Added `FileAccessor` class with structured accessor information
2. **Removed Manual Logic**: Deleted `_getFileAccessorForType()` method entirely
3. **Use Generator Expertise**: CodeGenerationService now uses generator-provided accessors from `varReferrer`
4. **Type-Safe Results**: All generators now provide correct, specific return types

### Current Generator Architecture
```dart
// BaseGenerator provides structured accessors
class FileAccessor {
  final String assetName;
  final String accessorCode;      // e.g., "Image get logo => Image.memory(bytes)"
  final String filePathAccessor;  // e.g., "String get logo => path"
}

// Generators implement generateAccessors() 
List<FileAccessor> generateAccessors(List<FileConfig> fileCfgs)
```

### Code Quality & Integration Enhancements
- **Type Safety**: All generated accessors have correct types (Image, Map, Future, String)
- **Generator Completeness**: All asset types generate both data/content AND path constants  
- **Error Resolution**: Fixed missing constants and type assignment errors
- **Cross-Platform Compatibility**: Proper path normalization in all generators
- **Package-Aware Paths**: All generated paths use Flutter package format (`packages/{packageName}/path`)
- **Automatic Pubspec Integration**: Soft assets automatically declared in pubspec.yaml
- **Clean Utility Architecture**: Dedicated utilities for package paths, pubspec parsing, and updates
- **Cross-Package Loading**: Generated assets work correctly when package used as dependency

### 🎯 Future Enhancements
- Optional build_runner integration (following Flutter Slang pattern)  
- Additional builtin asset types
- Custom generator plugin system
- Advanced template customization

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
- Dual accessor classes: `$paths` (path strings) and `$files` (embedded bytes)
- Directory-based class organization with UID prefixes

### Asset Processing Handling
- Read asset files as bytes during generation
- Convert to base64 strings for embedding in Dart source
- Generate package-relative paths for `$paths` accessors
- Create UIDs to ensure unique identifiers across all assets
- Cross-platform path normalization using `path` package