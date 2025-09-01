# System Patterns

## Architecture Overview
Config → Discovery → Generation → Output (Dual Mode)

## Core Components
1. **Config**: Registry-based configuration with type/map mappings
2. **Discovery**: Asset scanning with filtering rules
3. **Generation**: CodeBuffer-based code generation with path toggling
4. **Output**: Dual generation for production and local testing

## Key Patterns

### Configuration System
- Type registry: Maps extensions to asset types
- Map registry: Maps types to implementation classes  
- Custom types: Support for complex instantiation patterns

### Code Generation
- **CodeBuffer**: Clean separation of imports and code
- **Path Toggling**: Package prefixes optional for local testing
- **Nested Access**: Subfolder getters enable deep navigation

### Dual Generation Pattern
```dart
// Production (usePackagePrefix: true)
"packages/myapp/assets/file.json"

// Local (usePackagePrefix: false)  
"assets/file.json"
```

## Generated Structure
```dart
// Instance mapping
final Map<String, dynamic> instanceMap = { ... };

// Nested folder classes with subfolder getters
class $c0001 extends FolderX {
  get subfolder => $c0002Instance;  // Enables nested access
}

// Root access via AssetMap
class AssetMap {
  static get assets => $c0001Instance;
}
```

## Configuration Example
```yaml
destination: lib/generated_assets.dart
local_destination: lib/generated_assets_local.dart  # Optional

type_registry:
  data: { file_extensions: [json, yaml] }
  
map_registry:
  custom: { src: "lib/models.dart::Custom", passIn: "path" }
```

## Design Principles
- **Simple**: Clean pipeline without unnecessary complexity
- **Flexible**: Configurable types and generation modes
- **Testable**: Local generation for development/testing
- **Nested**: Intuitive dot notation access
