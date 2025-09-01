import 'package:assetx/gen/config.dart';

final mapRegistry = {
  "image": MapConfig(builtin: "imagex"),
  "data": MapConfig(builtin: "datax"),
  "env": MapConfig(builtin: "envx"),
};

final typeRegistry = {
  "image": TypeConfig(
    fileExtensions: [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp"],
  ),
  "data": TypeConfig(fileExtensions: [".json", ".yaml", ".yml"]),
  "env": TypeConfig(fileExtensions: [".env"]),
};

final builtinTypeMapping = {
  "imagex": "ImageX",
  "datax": "DataX",
  "envx": "EnvX",
  "basex": "BaseX",
};
