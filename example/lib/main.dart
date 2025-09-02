import 'package:flutter/material.dart';
import 'generated_local.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AssetX Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AssetTestPage(),
    );
  }
}

class AssetTestPage extends StatefulWidget {
  const AssetTestPage({super.key});

  @override
  _AssetTestPageState createState() => _AssetTestPageState();
}

class _AssetTestPageState extends State<AssetTestPage> {
  final List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _runTests() async {
    _addResult('Testing Generated Assets Configuration');
    _addResult('=====================================');

    // Test static class direct access
    _addResult('\n1. Testing static class direct access:');
    try {
      _addResult(
        '   Static instance \$m0000Instance.hello: "${$m0000Instance.hello}"',
      );
      _addResult(
        '   Static instance \$m0000Instance.anumber: ${$m0000Instance.anumber}',
      );
      _addResult(
        '   Static nested \$m0000Instance.nested.key: "${$m0000Instance.nested.key}"',
      );
      _addResult(
        '   Static deep nested \$m0000Instance.nested.evenchild.wow.test: ${$m0000Instance.nested.evenchild.wow.test}',
      );
      _addResult('   Static array \$m0001Instance.x: ${$m0001Instance.x}');
      _addResult(
        '   Static complex array \$m0001Instance.hello: ${$m0001Instance.hello}',
      );
      _addResult('   ✅ Direct static instance access working!');
    } catch (e) {
      _addResult('   ❌ Static instance access failed: $e');
    }

    // Test AssetMap access to root folders
    _addResult('\n2. Testing AssetMap static getters:');
    _addResult('   Assets folder path: ${AssetMap.assets.path}');
    _addResult('   Coolassets folder path: ${AssetMap.coolassets.path}');

    // Test nested structure access
    _addResult('\n3. Testing nested folder access:');
    try {
      // Test nested access: assets.folder.foldersub.foldersub2.data
      final dataAsset = AssetMap.assets.folder.foldersub.foldersub2.data;
      _addResult(
        '   ✅ Nested access works: assets.folder.foldersub.foldersub2.data',
      );
      _addResult('   Data asset type: ${dataAsset.runtimeType}');

      // Since dataAsset is now $m0000Instance, we can access its properties directly
      _addResult('   Via AssetMap -> dataAsset.hello: "${dataAsset.hello}"');
      _addResult('   Via AssetMap -> dataAsset.anumber: ${dataAsset.anumber}');
      _addResult(
        '   Via AssetMap -> dataAsset.nested.key: "${dataAsset.nested.key}"',
      );

      // Test another nested file
      final data1Asset = AssetMap.assets.folder.foldersub.foldersub2.data1;
      _addResult(
        '   ✅ Another nested access: assets.folder.foldersub.foldersub2.data1',
      );
      _addResult('   Data1 asset type: ${data1Asset.runtimeType}');
      _addResult('   Via AssetMap -> data1Asset.x: ${data1Asset.x}');
      _addResult('   Via AssetMap -> data1Asset.hello: ${data1Asset.hello}');

      // Test image access
      final imageAsset = AssetMap.assets.image.image;
      _addResult('   ✅ Image access: assets.image.image');
      _addResult('   Image path: ${imageAsset.path}');

      // Test the new x.jpg image
      final xImageAsset = AssetMap.assets.image.x;
      _addResult('   ✅ New image access: assets.image.x');
      _addResult('   X Image path: ${xImageAsset.path}');
      _addResult('   X Image type: ${xImageAsset.runtimeType}');

      // Test coolassets nested access
      final coolDataAsset = AssetMap.coolassets.data1.datachild.data;
      _addResult('   ✅ Coolassets nested: coolassets.data1.datachild.data');
      _addResult('   Cool data type: ${coolDataAsset.runtimeType}');
      _addResult(
        '   Via AssetMap -> coolDataAsset.hello: "${coolDataAsset.hello}"',
      );

      final coolImageAsset = AssetMap.coolassets.image1.image2.img_jpeg;
      _addResult('   ✅ Cool image nested: coolassets.image1.image2.img_jpeg');
      _addResult('   Cool image path: ${coolImageAsset.path}');
    } catch (e) {
      _addResult('   ❌ Nested access failed: $e');
    }

    // Test custom asset type
    _addResult('\n4. Testing custom asset type:');
    try {
      final customAsset = AssetMap.assets.data.kk;
      _addResult('   ✅ Custom asset access: assets.data.kk');
      _addResult('   Custom asset path: ${customAsset.path}');
      _addResult('   Custom asset type: ${customAsset.runtimeType}');
      _addResult('   Custom content: ${await customAsset.fileContent}');
    } catch (e) {
      _addResult('   ❌ Error accessing custom asset: $e');
    }

    // Test static class comparison
    _addResult('\n5. Testing static class integration:');
    try {
      final viaAssetMap = AssetMap.assets.folder.foldersub.foldersub2.data;
      final viaStatic = $m0000Instance;
      _addResult('   AssetMap access type: ${viaAssetMap.runtimeType}');
      _addResult('   Direct static type: ${viaStatic.runtimeType}');
      _addResult(
        '   Same instance reference: ${identical(viaAssetMap, viaStatic)}',
      );
      _addResult(
        '   Both reference same type: ${viaAssetMap.runtimeType == viaStatic.runtimeType}',
      );

      // Both should return the same instance, so we can access properties on both
      _addResult('   ✅ AssetMap correctly returns \$m0000Instance');
      _addResult(
        '   Instance property access: \$m0000Instance.hello = "${viaStatic.hello}"',
      );
      _addResult(
        '   Via AssetMap same result: dataAsset.hello = "${viaAssetMap.hello}"',
      );
    } catch (e) {
      _addResult('   ❌ Static integration test failed: $e');
    }

    // Show all static classes and their properties
    _addResult('\n6. All generated static class instances:');
    _addResult(
      '   \$m0000Instance: hello="${$m0000Instance.hello}", anumber=${$m0000Instance.anumber}',
    );
    _addResult(
      '   \$m0000_nestedInstance: key="${$m0000_nestedInstance.key}", another_key="${$m0000_nestedInstance.another_key}"',
    );
    _addResult(
      '   \$m0000_nested_evenchildInstance: key="${$m0000_nested_evenchildInstance.key}"',
    );
    _addResult(
      '   \$m0000_nested_evenchild_wowInstance: test=${$m0000_nested_evenchild_wowInstance.test}',
    );
    _addResult(
      '   \$m0001Instance: x=${$m0001Instance.x}, hello=${$m0001Instance.hello}',
    );
    _addResult('   \$m0002Instance: test=${$m0002Instance.test}');
    _addResult('   \$m0003Instance: hello="${$m0003Instance.hello}"');

    // Show all assets in instance map
    _addResult('\n7. All available assets in instanceMap:');
    for (final entry in instanceMap.entries) {
      final value = entry.value;
      if (value.runtimeType.toString().startsWith('\$m')) {
        _addResult(
          '   "${entry.key}" -> ${value.runtimeType} (static instance)',
        );
      } else {
        _addResult(
          '   "${entry.key}" -> ${value.runtimeType}("${value.path}")',
        );
      }
    }

    _addResult('\n✅ Asset configuration test completed!');
    _addResult('\nImage Display Test:');
    _addResult('   📸 The x.jpg image should be displayed above the test results');
    _addResult('   📸 Image path: ${AssetMap.assets.image.x.path}');
    _addResult('   📸 Image accessible via: AssetMap.assets.image.x');
    _addResult('\nNew static instance access patterns available:');
    _addResult('   Direct: \$m0000Instance.hello, \$m0000Instance.nested.key');
    _addResult(
      '   Via AssetMap: AssetMap.assets.folder.foldersub.foldersub2.data.hello',
    );
    _addResult('   Nested objects: \$m0000Instance.nested.evenchild.wow.test');
    _addResult('   Arrays: \$m0001Instance.x, \$m0001Instance.hello');
    _addResult('   Images: AssetMap.assets.image.x.path (displayed above)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AssetX Test Results')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the x.jpg image
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Displaying assets.image.x (x.jpg):',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        AssetMap.assets.image.x.path,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not found:\n${AssetMap.assets.image.x.path}',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Path: ${AssetMap.assets.image.x.path}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 10),
            // Test results
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    result,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12.0,
                      color: result.contains('✅')
                          ? Colors.green.shade700
                          : result.contains('❌')
                          ? Colors.red.shade700
                          : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
