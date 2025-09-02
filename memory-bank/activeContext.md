# Active Context

## Current Status
Static class generation is implemented and working. All features complete.

## Recent Work
- Added `gen_static.dart` with StaticGenerator class
- Implemented multi-format parsing (JSON/YAML/ENV/TOML)
- Fixed instance vs class type issue in instanceMap
- Updated test file with Flutter integration examples
- Corrected documentation tone

## Next Steps
- None. All requested features are complete and tested.

## Key Working Features
```dart
// Static classes from parsed data
class $m0000 {
  String get hello => "x";
  get nested => $m0000_nestedInstance;
}
final $m0000Instance = $m0000();

// Instance mapping
final instanceMap = {
  "assets.folder.data": $m0000Instance, // uses instance
};
```

## Access Patterns Available
- Direct: `$m0000Instance.hello`
- AssetMap: `AssetMap.assets.folder.data.hello`
- Flutter: `Image.asset(AssetMap.assets.image.x.path)`
