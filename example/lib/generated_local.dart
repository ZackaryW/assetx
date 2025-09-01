// ignore_for_file: non_constant_identifier_names
import 'package:assetx/objectx/objectx.dart';
import 'package:example/custom_handler.dart';

// Instance mapping
final Map<String, dynamic> instanceMap = {
  "assets.data.kk": CustomAsset("assets/data/kk.ww"),
  "assets.folder.foldersub.foldersub2.data": DataX("assets/folder/foldersub/foldersub2/data.json"),
  "assets.folder.foldersub.foldersub2.data1": DataX("assets/folder/foldersub/foldersub2/data1.json"),
  "assets.folder.foldersub.foldersub2.data2": DataX("assets/folder/foldersub/foldersub2/data2.json"),
  "assets.image.image": ImageX("assets/image/image.gif"),
  "coolassets.data1.datachild.data": DataX("coolassets/data1/datachild/data.json"),
  "coolassets.image1.image2.img_jpeg": ImageX("coolassets/image1/image2/img.jpeg"),
  "coolassets.image1.image2.img_jpg": ImageX("coolassets/image1/image2/img.jpg"),
  "coolassets.image1.image2.img_png": ImageX("coolassets/image1/image2/img.png")
};

// Generated Folder Structure
class $c0000 extends FolderX {
  const $c0000() : super('data');
  get kk => instanceMap["assets.data.kk"];
}
final $c0000Instance = $c0000();

class $c0001 extends FolderX {
  const $c0001() : super('folder');
  get foldersub => $c0002Instance;
}
final $c0001Instance = $c0001();

class $c0002 extends FolderX {
  const $c0002() : super('foldersub');
  get foldersub2 => $c0003Instance;
}
final $c0002Instance = $c0002();

class $c0003 extends FolderX {
  const $c0003() : super('foldersub2');
  get data => instanceMap["assets.folder.foldersub.foldersub2.data"];
  get data1 => instanceMap["assets.folder.foldersub.foldersub2.data1"];
  get data2 => instanceMap["assets.folder.foldersub.foldersub2.data2"];
}
final $c0003Instance = $c0003();

class $c0004 extends FolderX {
  const $c0004() : super('image');
  get image => instanceMap["assets.image.image"];
}
final $c0004Instance = $c0004();

class $c0005 extends FolderX {
  const $c0005() : super('data1');
  get datachild => $c0006Instance;
}
final $c0005Instance = $c0005();

class $c0006 extends FolderX {
  const $c0006() : super('datachild');
  get data => instanceMap["coolassets.data1.datachild.data"];
}
final $c0006Instance = $c0006();

class $c0007 extends FolderX {
  const $c0007() : super('folder1');
  get folderexclude => $c0008Instance;
}
final $c0007Instance = $c0007();

class $c0008 extends FolderX {
  const $c0008() : super('folderexclude');
}
final $c0008Instance = $c0008();

class $c0009 extends FolderX {
  const $c0009() : super('image1');
  get image2 => $c0010Instance;
}
final $c0009Instance = $c0009();

class $c0010 extends FolderX {
  const $c0010() : super('image2');
  get img_jpeg => instanceMap["coolassets.image1.image2.img_jpeg"];
  get img_jpg => instanceMap["coolassets.image1.image2.img_jpg"];
  get img_png => instanceMap["coolassets.image1.image2.img_png"];
}
final $c0010Instance = $c0010();

class $c0011 extends FolderX {
  const $c0011() : super('assets');
  get data => $c0000Instance;
  get folder => $c0001Instance;
  get image => $c0004Instance;
}
final $c0011Instance = $c0011();

class $c0012 extends FolderX {
  const $c0012() : super('coolassets');
  get data1 => $c0005Instance;
  get folder1 => $c0007Instance;
  get image1 => $c0009Instance;
}
final $c0012Instance = $c0012();

// AssetMap class for easy access to all root folders
class AssetMap {
  AssetMap._();

  static get assets => $c0011Instance;
  static get coolassets => $c0012Instance;
}

