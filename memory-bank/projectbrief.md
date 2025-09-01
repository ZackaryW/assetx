# AssetX Project Brief

## Overview
AssetX is a simple tool to create asset mapping and generate a target Dart file. This is a simple tool, not some complex and sophisticated design.

## Core Purpose
- Scan assets using command tool
- Generate Dart code with asset instances and folder structure
- Create mapping with customization

## Target Output
Generate Dart code like this:

```dart
// Generated Asset Instances
final DataX $_00000 = DataX('assets/data/config.json');
final DataX $_00001 = DataX('assets/data/data/config.json');
final ImageX $_00002 = ImageX('assets/images/logo.png');
final BaseX $_00003 = BaseX('assets/images/some_folder/x.mp4');
final ImageX $_00004 = ImageX('assets/images/test.jpg');
final Profile $_00005 = Profile('assets/profiles/user.json');

// Generated Folder Structure
class $c0000 extends FolderX {
  const $c0000() : super('data');
  static get config => $_00000;
  static get data => $c0003Instance;
}
final $c0000Instance = $c0000();

class $c0001 extends FolderX {
  const $c0001() : super('images');
  static get logo => $_00002;
  static get test => $_00004;
  static get some_folder => $c0004Instance;
}
final $c0001Instance = $c0001();
```

## Key Requirement
Keep it simple and minimal - only implement what's needed for the asset mapping generation.
