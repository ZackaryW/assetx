# System Patterns

## Architecture Overview
AssetX follows a **configuration-driven code generation** pattern:

```
assetx.yaml (config) → Asset Scanner → Code Generator → asset.x.dart (generated)
```

## Core Components

### 1. Configuration System (`Config`, `ConfigEntry`)
- **Purpose**: Parse `assetx.yaml` to understand what assets to scan
- **Pattern**: YAML → Dart model mapping
- **Key Features**: Path patterns, type filtering, exclusions, recursive scanning

### 2. Asset Discovery Engine  
- **Purpose**: Scan file system based on configuration
- **Pattern**: Strategy pattern for different asset types (images, json, etc.)
- **Output**: Structured asset metadata for code generation

### 3. Code Generation Engine
- **Purpose**: Transform discovered assets into Dart class hierarchies
- **Pattern**: Template-based code generation with AST building
- **Output**: Strongly-typed Dart classes with asset path constants

### 4. Lock File System (Secondary)
- **Purpose**: Track discovered assets for caching/diff detection
- **Pattern**: JSON serialization of asset metadata
- **Use Case**: Incremental builds and debugging

## Key Design Patterns

### Code Generation Strategy
- **Direct File Generation**: Generate `asset.x.dart` directly at target location (simplified from part files)
- **Extension Pattern**: Create extensions on `AssetX` class from `assetxf.dart` package
- **Root Folder Classes**: Generate classes containing all root folder instances
- **UID Generation**: Create unique identifiers for each asset to avoid naming conflicts
- **Proper Generator Delegation**: CodeGenerationService coordinates, generators provide expertise
  - **Enhanced BaseGenerator**: FileAccessor class for structured accessor information
  - **Type-Safe Accessors**: Generators provide correct types (Image, Map, Future, etc.)
  - **No Manual Reimplementation**: Use generator `varReferrer` instead of hardcoded logic
- **Mode-Based Generation**: 
  - **Hardcode**: Read files and embed as base64-encoded ByteData constants
  - **Regular**: Generate path constants for Flutter's `Image.asset()`
- **Dual Access Classes**: Generate both `$files` and `$paths` accessors
- **Configuration-Driven**: Mode selection per asset type or globally

### Asset Type Handling
- **Predefined Types**: `["image_hard", "image_soft", "kv_hard", "kv_soft"]` from builtin.dart
- **Hard/Soft Variants**: Each asset category has embedding (_hard) and loading (_soft) modes
- **Type-Specific Generation** (Properly Delegated to Generators):
  - `image_hard`: `Image get name => Image.memory(bytes.buffer.asUint8List())` ✅
  - `image_soft`: `Image get name => Image.asset(path)` ✅
  - `kv_hard`: `Map<String, dynamic> get name => data` (JSON) or `String get name => content` ✅
  - `kv_soft`: `Future<Map<String, dynamic>> get name => rootBundle.loadString(path).then((s) => jsonDecode(s) as Map<String, dynamic>)` ✅
- **Complete Constants**: All types generate both data/content constants AND path constants
- **Package-Aware Paths**: All generated paths use `packages/{packageName}/` format for cross-package compatibility
- **Automatic Pubspec Integration**: Soft types automatically declared in pubspec.yaml via `requiresPubspecAsset` property
- **Extensible**: Generator registry pattern allows custom asset type plugins

### Utility Organization
- **IdentifierUtils**: Centralized Dart identifier generation (`lib/utils/file/config.dart`)
  - Cross-platform path normalization (Windows backslashes → forward slashes)
  - Valid Dart identifier creation (camelCase, special character handling)
  - Numeric prefix handling for valid identifiers
- **PackagePathUtils**: Package-aware asset path generation (`lib/utils/file/package_path.dart`)
  - Converts relative paths to `packages/{packageName}/` format
  - Parses pubspec.yaml for package name extraction
  - Ensures cross-package asset loading compatibility
- **PubspecResolver & PubspecUpdate**: Pubspec.yaml integration utilities
  - Automatic parsing and updating of pubspec.yaml files
  - Clean integration with Flutter's asset declaration system
- **FileUtils**: File system operations and ignore file management (`lib/utils/file/update_ignore.dart`)
- **Shared Utilities**: Reusable helper methods across all generators

### File System Interaction
- **Immutable Scanning**: Read-only file system operations during generation
- **Path Normalization**: Handle cross-platform path differences
- **Error Handling**: Graceful handling of missing directories/files

## Integration Points

### Flutter Asset System
- Generated paths must align with `pubspec.yaml` asset declarations
- Support Flutter's asset variant system (2.0x, 3.0x images)
- Compatible with Flutter's asset loading APIs

### Build System Integration  
- **Primary**: Standalone CLI interface for build script integration
- **No build_runner dependency**: Following Flutter Slang's approach
- **Future Enhancement**: Optional build_runner integration for seamless IDE experience
- Watch mode for development workflow
- Incremental generation for large asset sets