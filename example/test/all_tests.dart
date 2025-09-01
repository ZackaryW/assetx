import 'package:flutter_test/flutter_test.dart';

import 'asset_lookup_test.dart' as asset_lookup_test;
import 'config_test.dart' as config_test;
import 'discovery_test.dart' as discovery_test;
import 'yaml_utils_test.dart' as yaml_utils_test;

void main() {
  group('AssetX Test Suite', () {
    asset_lookup_test.main();
    config_test.main();
    discovery_test.main();
    yaml_utils_test.main();
  });
}
