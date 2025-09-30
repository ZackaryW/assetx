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
- **Part Files**: Use `part 'asset.x.dart'` pattern for generated code
- **UID Generation**: Create unique identifiers for each asset to avoid naming conflicts
- **Mode-Based Generation**: 
  - **Hardcode**: Read files and embed as base64-encoded ByteData constants
  - **Regular**: Generate path constants for Flutter's `Image.asset()`
- **Dual Access Classes**: Generate both FILES and FILEPATHS accessors
- **Configuration-Driven**: Mode selection per asset type or globally

### Asset Type Handling
- **Predefined Types**: `["image_hard", "image_soft", "kv_hard", "kv_soft"]` from builtin.dart
- **Hard/Soft Variants**: Each asset category has embedding (_hard) and loading (_soft) modes
- **Type-Specific Generation**: 
  - `image_*`: Generate `Image.memory()` vs `Image.asset()` accessors
  - `kv_*`: Generate parsed JSON objects vs `rootBundle.loadString()` accessors
- **Extensible**: Future support for additional builtin types

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