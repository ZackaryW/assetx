# Product Context

## Purpose
AssetX generates type-safe Dart code for Flutter asset access, eliminating hardcoded paths and enabling nested folder navigation.

## Core Value
- **Type Safety**: No more string typos in asset paths
- **Nested Access**: Intuitive dot notation for deep folder structures  
- **Dual Mode**: Production builds with package paths, local testing without
- **Auto-Discovery**: Scans and maps all assets automatically

## User Experience
1. Configure asset folders in `assetx.yaml`
2. Run `dart run assetx`
3. Use generated code: `AssetMap.assets.images.profile.avatar.asset`

## Output
Transforms folder structure into clean, type-safe access patterns:

```dart
// Instead of error-prone strings
Image.asset('assets/images/profile/avatar.png')

// Use generated, autocomplete-friendly code  
AssetMap.assets.images.profile.avatar.asset
```

## Key Benefits
- **No Typos**: Generated code prevents path errors
- **IDE Support**: Full autocomplete and navigation
- **Maintenance**: Assets automatically stay in sync
- **Testing**: Local mode for development without package complexity
