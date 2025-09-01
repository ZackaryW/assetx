# Active Context

## Current State
AssetX is **PRODUCTION READY** with full nested asset access and local testing support.

## Core Features Working
- ✅ Configuration system with type and map registries
- ✅ Asset discovery with filtering
- ✅ Nested folder access: `AssetMap.assets.folder.subfolder.file`
- ✅ Package-aware paths for production builds
- ✅ Local testing mode without package prefixes
- ✅ Conflict resolution for duplicate filenames
- ✅ CLI interface with dual generation

## Recent Addition
- **Local Testing Support**: Added `local_destination` config option
- **Dual Generation**: CLI generates both production and local versions
- **Path Toggling**: Package prefixes can be enabled/disabled per build

## Output Formats
**Production Version** (with package prefixes):
```dart
final Map<String, dynamic> instanceMap = {
  "assets.data.file": DataX("packages/myapp/assets/data/file.json"),
};
```

**Local Version** (without package prefixes):
```dart
final Map<String, dynamic> instanceMap = {
  "assets.data.file": DataX("assets/data/file.json"),
};
```

## Access Pattern
```dart
// Both versions support the same nested access
AssetMap.assets.folder.subfolder.file.asset
```

**Status: Production ready with local testing support**
