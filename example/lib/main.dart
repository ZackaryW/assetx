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

    // Test AssetMap access to root folders
    _addResult('\n1. Testing AssetMap static getters:');
    _addResult('   Assets folder path: ${AssetMap.assets.path}');
    _addResult('   Coolassets folder path: ${AssetMap.coolassets.path}');

    // Test nested structure access
    _addResult('\n2. Testing nested folder access:');
    try {
      // Test nested access: assets.folder.foldersub.foldersub2.data
      final dataAsset = AssetMap.assets.folder.foldersub.foldersub2.data;
      _addResult(
        '   ✅ Nested access works: assets.folder.foldersub.foldersub2.data',
      );
      _addResult('   Data asset path: ${dataAsset.path}');
      _addResult('   Data asset type: ${dataAsset.runtimeType}');

      // Test another nested file
      final data1Asset = AssetMap.assets.folder.foldersub.foldersub2.data1;
      _addResult(
        '   ✅ Another nested access: assets.folder.foldersub.foldersub2.data1',
      );
      _addResult('   Data1 asset path: ${data1Asset.path}');

      // Test image access
      final imageAsset = AssetMap.assets.image.image;
      _addResult('   ✅ Image access: assets.image.image');
      _addResult('   Image path: ${imageAsset.path}');

      // Test coolassets nested access
      final coolDataAsset = AssetMap.coolassets.data1.datachild.data;
      _addResult('   ✅ Coolassets nested: coolassets.data1.datachild.data');
      _addResult('   Cool data path: ${coolDataAsset.path}');

      final coolImageAsset = AssetMap.coolassets.image1.image2.img_jpeg;
      _addResult('   ✅ Cool image nested: coolassets.image1.image2.img_jpeg');
      _addResult('   Cool image path: ${coolImageAsset.path}');
    } catch (e) {
      _addResult('   ❌ Nested access failed: $e');
    }

    // Test custom asset type
    _addResult('\n3. Testing custom asset type:');
    try {
      final customAsset = AssetMap.assets.data.kk;
      _addResult('   ✅ Custom asset access: assets.data.kk');
      _addResult('   Custom asset path: ${customAsset.path}');
      _addResult('   Custom asset type: ${customAsset.runtimeType}');
      _addResult(await customAsset.fileContent);
    } catch (e) {
      _addResult('   ❌ Error accessing custom asset: $e');
    }

    // Test package prefix verification
    _addResult('\n4. Package prefix verification:');
    var allHavePackagePrefix = true;
    for (final entry in instanceMap.entries) {
      final path = entry.value.path;
      if (!path.startsWith('packages/example/')) {
        _addResult('   ❌ Missing package prefix: $path');
        allHavePackagePrefix = false;
      }
    }

    if (allHavePackagePrefix) {
      _addResult('   ✅ All asset paths have correct package prefix');
    }

    // Show all assets
    _addResult('\n5. All available assets:');
    for (final entry in instanceMap.entries) {
      _addResult(
        '   "${entry.key}" -> ${entry.value.runtimeType}("${entry.value.path}")',
      );
    }

    _addResult('\n✅ Asset configuration test completed!');
    _addResult('\nNow you can use nested access like:');
    _addResult('   AssetMap.assets.folder.foldersub.foldersub2.data');
    _addResult('   AssetMap.coolassets.image1.image2.img_jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AssetX Test Results')),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
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
      ),
    );
  }
}
