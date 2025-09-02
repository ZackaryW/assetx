# AssetX - Type-Safe Asset Management for Flutter

> **Generate static asset mappings with type-safe access patterns**

## What AssetX Does

AssetX generates static asset mappings for your Flutter project. It scans your assets, creates type-safe access patterns, and can optionally parse data files (JSON, YAML, ENV, TOML) into static classes when `lazy: false` is set.

```dart
// Instead of hardcoded paths:
Image.asset('assets/images/profile/user_avatar.png')

// Use generated mappings:
Image.asset(AssetMap.assets.images.profile.user_avatar.path)
```

## Quick Setup

### Step 1: Add AssetX to your project

```yaml
# pubspec.yaml
dev_dependencies:
  assetx: ^1.0.0
```

### Step 2: Create configuration

```yaml
# assetx.yaml
destination: lib/generated_assets.dart
local_destination: lib/generated_local.dart
sources_include:
  - path: assets/
    recursive: true

type_registry:
  data:
    file_extensions: [".json", ".yaml", ".yml", ".env", ".toml"]
  image:
    file_extensions: [".png", ".jpg", ".jpeg", ".gif"]

map_registry:
  data:
    builtin: datax
    lazy: false  # Parse data files into static classes
  image:
    builtin: imagex
```

### Step 3: Generate mappings

```bash
dart run assetx
```

## What Gets Generated

### Your Assets Structure
```
assets/
├── config/
│   ├── app.json          # {"title": "My App", "version": "1.0"}
│   └── theme.yaml        # colors: {primary: "#FF0000"}
├── data/
│   └── users.json        # {"admin": {"name": "Admin", "role": "super"}}
└── images/
    ├── logo.png
    └── icons/
        └── star.svg
```

### Generated Static Classes

When `lazy: false` is set for data files, AssetX parses them during code generation and creates static classes:

```dart
// Generated from app.json
class $m0000 {
  String get title => "My App";
  String get version => "1.0";
}
final $m0000Instance = $m0000();

// Generated from theme.yaml with nested structure
class $m0001 {
  get colors => $m0001_colorsInstance;
}
class $m0001_colors {
  String get primary => "#FF0000";
}
final $m0001Instance = $m0001();
final $m0001_colorsInstance = $m0001_colors();
```

### Access Patterns

```dart
// 1. Direct instance access
String appTitle = $m0000Instance.title;
String primaryColor = $m0001Instance.colors.primary;

// 2. Through AssetMap (nested folder structure)
String appTitle = AssetMap.assets.config.app.title;
String primaryColor = AssetMap.assets.config.theme.colors.primary;

// 3. Image assets
Widget logo = Image.asset(AssetMap.assets.images.logo.path);
Widget star = SvgPicture.asset(AssetMap.assets.images.icons.star.path);
```

## Features

### Data File Parsing

When `lazy: false` is configured, AssetX supports parsing multiple formats:

- **JSON**: Objects become nested classes
- **YAML**: Complex hierarchies supported
- **ENV**: Environment variables as static properties  
- **TOML**: Configuration files with sections

```dart
// From config.json: {"database": {"host": "localhost", "port": 5432}}
AssetMap.assets.config.database.host  // "localhost"
AssetMap.assets.config.database.port  // 5432

// From .env: API_KEY=secret123
AssetMap.assets.env.API_KEY  // "secret123"

// From config.toml: [server] host = "0.0.0.0"
AssetMap.assets.config.server.host  // "0.0.0.0"
```

### Custom Asset Types

Define your own asset handlers:

```yaml
# assetx.yaml
type_registry:
  config:
    pattern: ["*/config.json"]
map_registry:
  config:
    src: "lib/models.dart::AppConfig.fromJson"
    passIn: "json"  # Pass parsed JSON to constructor
```

```dart
// Your custom class
class AppConfig {
  final String title;
  AppConfig.fromJson(Map<String, dynamic> json) : title = json['title'];
}

// Generated usage
AppConfig config = AssetMap.assets.config.app; // Your custom instance!
```

### Flutter Integration

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AssetMap.assets.config.app.title,  // From parsed data
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(int.parse(AssetMap.assets.config.theme.colors.primary)),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AssetMap.assets.config.app.title),
      ),
      body: Column(
        children: [
          // Display images
          Image.asset(AssetMap.assets.images.logo.path),
          
          // Use parsed data
          Text('Welcome ${AssetMap.assets.data.users.admin.name}!'),
          Text('App Version: ${AssetMap.assets.config.app.version}'),
          
          // Arrays work too
          ...AssetMap.assets.data.menu.items.map((item) => 
            ListTile(title: Text(item.name))
          ),
        ],
      ),
    );
  }
}
```

## Configuration Reference

```yaml
# Complete configuration example
destination: lib/generated_assets.dart      # Production file (with packages/)
local_destination: lib/generated_local.dart # Local testing file (without packages/)

sources_include:
  - path: assets/
    recursive: true
  - path: config/
    recursive: false

sources_exclude:
  - path: assets/temp/
  - path: assets/cache/

patterns_exclude: 
  - "*.tmp"
  - "*.cache"
  - ".DS_Store"

type_registry:
  # Data files that can be parsed into static classes
  data:
    file_extensions: [".json", ".yaml", ".yml", ".env", ".toml"]
  
  # Image files  
  image:
    file_extensions: [".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp"]
  
  # Custom type by pattern
  config:
    pattern: ["*/config.*"]

map_registry:
  # Parse data files into static classes during code generation
  data:
    builtin: datax
    lazy: false  # Enable static class generation
  
  # Standard image assets
  image:
    builtin: imagex
  
  # Custom handler
  config:
    src: "lib/models.dart::Config.fromJson"
    passIn: "json"
```

## Benefits

### Development Experience  
- **Type safety**: Get compile-time errors for missing assets
- **IntelliSense**: Full autocomplete for all your assets
- **Organized access**: Nested folder structure preserved
- **Refactoring safe**: Rename files, paths update automatically

### Architecture
- **Single import**: Access all assets from one generated file
- **Conflict resolution**: Duplicate filenames handled automatically
- **Package awareness**: Production builds use proper package paths
- **Local testing**: Development builds use local paths
- **Static data access**: When `lazy: false`, data is available as properties

## Generated File Structure

```dart
// Your generated file structure
lib/
├── generated_assets.dart     // Production (packages/yourapp/assets/...)
├── generated_local.dart      // Development (assets/...)
└── main.dart

// In generated files:
class AssetMap {
  static get assets => $c0000Instance;    // Root assets folder
  static get config => $c0001Instance;    // Root config folder
}

class $m0000 {                           // Static class from parsed data file
  String get title => "My App";          // Direct property access
  get nested => $m0000_nestedInstance;   // Nested object reference
}
final $m0000Instance = $m0000();         // Const instance

final Map<String, dynamic> instanceMap = {
  "assets.config.app": $m0000Instance,   // Maps paths to instances
  "assets.images.logo": ImageX("assets/images/logo.png"),
};
```

---

**Get started:**

```bash
dart pub add --dev assetx
# Create assetx.yaml with your configuration
dart run assetx
# Use AssetMap.assets.your.nested.structure
```

