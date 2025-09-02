import 'package:assetx/objectx/basex.dart';
import 'package:flutter/widgets.dart';

class ImageX extends BaseX {
  ImageX(super.path, {super.lazy = true}) {
    // if not jpg, jpeg, png, webp, gif, bmp
    if (!path.endsWith('.jpg') &&
        !path.endsWith('.jpeg') &&
        !path.endsWith('.png') &&
        !path.endsWith('.webp') &&
        !path.endsWith('.gif') &&
        !path.endsWith('.bmp')) {
      throw Exception(
        'ImageX only supports jpg, jpeg, png, webp, gif, and bmp files.',
      );
    }

    if (!lazy) {
      Future.microtask(() => asset);
    }
  }

  Image get asset {
    final cached = BaseX.getCacheMethod<Image>(path);
    if (cached != null) {
      return cached;
    }

    // If not cached, load the image
    final image = Image.asset(path);
    BaseX.setCacheMethod(path, image);
    return image;
  }
}
