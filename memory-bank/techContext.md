# Technical Context

## Technology Stack
- **Language**: Dart
- **Dependencies**: `path`, `yaml`, `json_annotation`
- **Build**: `build_runner` for code generation
- **Testing**: Flutter Web validation

## Configuration System
- **Type Registry**: Maps file extensions to asset types
- **Map Registry**: Maps types to implementation classes
- **Custom Types**: Support for complex instantiation patterns
- **Local Testing**: Optional non-prefixed paths for development

## Asset Types
- **DataX**: JSON/YAML data files
- **ImageX**: All image formats (png, jpg, gif, webp, bmp, svg)
- **EnvX**: Environment files
- **BaseX**: Default fallback
- **Custom**: User-defined types via configuration

## File Structure
```
lib/
├── gen/           # Code generation system
│   ├── config.dart     # Configuration models  
│   ├── gen.dart        # Main generation logic
│   └── default.dart    # Default mappings
├── objectx/       # Asset type classes
├── utils/         # Discovery and utilities
│   ├── lookup.dart     # Asset discovery
│   ├── codebuffer.dart # Code generation utility
│   └── pubspec_resolve.dart # Package resolution
bin/
└── assetx.dart    # CLI interface
```

## Generation Modes
**Production**: Package-prefixed paths (`packages/myapp/...`)
**Local**: Direct paths (`assets/...`) for testing

## Generated Output
- **Instance mapping**: Asset path to object mapping
- **Nested access**: Folder classes with subfolder getters
- **Root access**: AssetMap class with static getters
- **Conflict resolution**: Extension suffixes for duplicates

## CLI Features
- Package name resolution from pubspec.yaml
- Dual file generation (production + local)
- Automatic pubspec.yaml updates
- Asset discovery with filtering

**Status: Production ready**
