# Product Context

## Problem Statement
Flutter asset loading has several performance and maintainability issues:
- **Runtime Overhead**: Asset loading requires file system access during execution
- **Bundle Size**: All assets included whether used or not (poor tree shaking)
- **Runtime Errors**: Asset paths can be mistyped leading to loading failures
- **No Type Safety**: String-based asset references with no compile-time validation
- **Maintenance Burden**: Manual tracking of asset references across codebase

## Solution
AssetX generates strongly-typed Dart classes using predefined builtin asset types:

**Hard Types** (`image_hard`, `kv_hard`):
- **Zero Runtime Loading**: Assets embedded as ByteData, no file system access needed
- **Maximum Tree Shaking**: Unused assets completely eliminated from build
- **Optimal for Small Assets**: Icons, config files, small images

**Soft Types** (`image_soft`, `kv_soft`):
- **Standard Flutter Integration**: Uses `Image.asset()` and `rootBundle` loading
- **Smaller Binary Size**: Assets remain external files
- **Better for Large Assets**: Large images, dynamic content

**Both Provide**:
- **Type Safety**: Strongly-typed accessors with IDE autocomplete support
- **UID-based Naming**: Unique identifiers prevent naming conflicts
- **Consistent API**: Same accessor pattern regardless of hard/soft mode

## User Experience Goals

### Developer Workflow
1. **Setup**: Add `assetx.yaml` configuration file
2. **Configure**: Specify asset directories and types to include
3. **Generate**: Run AssetX CLI command to scan and generate asset classes
4. **Use**: Import generated classes for type-safe asset access
5. **Maintain**: Re-run generation when assets change

**Note**: Following Flutter Slang's approach - works as standalone CLI tool without build_runner dependency. Future build_runner integration planned for enhanced IDE experience.

### Generated Code Quality
- Clean, readable generated Dart code
- Intuitive naming conventions (snake_case files → camelCase properties)
- Hierarchical organization matching directory structure
- Proper documentation comments in generated code

### Integration Experience
- Seamless Flutter asset loading integration
- Works with existing `pubspec.yaml` asset declarations
- No runtime dependencies beyond generated code
- Compatible with build systems and CI/CD pipelines

## Success Metrics
- Zero runtime asset path errors
- Reduced development time for asset management
- Improved code maintainability and refactoring confidence
- Developer adoption in Flutter projects