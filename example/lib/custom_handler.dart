
import 'package:flutter/services.dart';

class CustomAsset {
  final String path;

  CustomAsset(this.path);

  Future<String> get fileContent {
    return rootBundle.loadString(path);
  }
}