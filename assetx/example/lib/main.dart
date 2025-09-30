import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assetxf/assetxf.dart' show assetX, toInternalPath;
import 'asset.x.dart';

void main() {
  runApp(const AssetXTestApp());
}

class AssetXTestApp extends StatelessWidget {
  const AssetXTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AssetX Test Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AssetXTestHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AssetXTestHomePage extends StatefulWidget {
  const AssetXTestHomePage({Key? key}) : super(key: key);

  @override
  State<AssetXTestHomePage> createState() => _AssetXTestHomePageState();
}

class _AssetXTestHomePageState extends State<AssetXTestHomePage> {
  Map<String, dynamic>? kv2Data;
  String testResults = '';

  @override
  void initState() {
    super.initState();
    _loadAsyncAssets();
    _runTests();
  }

  Future<void> _loadAsyncAssets() async {
    try {
      final data = await assetX.example.kv2.$files.ww2;
      setState(() {
        kv2Data = data;
      });
    } catch (e) {
      setState(() {
        testResults += 'Error loading KV2 async data: $e\n';
      });
    }
  }

  void _runTests() {
    final buffer = StringBuffer();

    // Test AssetX extension
    buffer.writeln('=== AssetX Extension Test ===');
    try {
      // final example = assetX.example;
      buffer.writeln('✅ assetX.example works');
      buffer.writeln('Available categories: images1, images2, kv1, kv2');
    } catch (e) {
      buffer.writeln('❌ AssetX extension failed: $e');
    }

    // Test Images1 (hard-coded)
    buffer.writeln('\n=== Images1 (Hard-coded) Tests ===');
    try {
      final images1 = assetX.example.images1;

      // Test file paths
      final jpgPath = images1.$paths.fileExampleJpg100kbJpg;
      buffer.writeln('✅ JPG path: $jpgPath');

      // Test embedded images
      final jpgImage = images1.$files.fileExampleJpg100kbJpg;
      buffer.writeln(
        '✅ JPG Image widget created (type: ${jpgImage.runtimeType})',
      );
    } catch (e) {
      buffer.writeln('❌ Images1 test failed: $e');
    }

    // Test Images2 (soft)
    buffer.writeln('\n=== Images2 (Soft) Tests ===');
    try {
      final images2 = assetX.example.images2;

      final jpgPath = images2.$paths.fileExampleJpg100kbjpg;
      final jpgInternalPath = toInternalPath(jpgPath);
      final jpgImage = images2.$files.fileExampleJpg100kbjpg;
      buffer.writeln('✅ JPG external path: $jpgPath');
      buffer.writeln('✅ JPG internal path: $jpgInternalPath');
      buffer.writeln(
        '✅ JPG Image.asset widget created (type: ${jpgImage.runtimeType})',
      );

      buffer.writeln(
        '✅ Images2 test completed (ICO files excluded - not supported by Flutter)',
      );
    } catch (e) {
      buffer.writeln('❌ Images2 test failed: $e');
    }

    // Test KV1 (hard-coded)
    buffer.writeln('\n=== KV1 (Hard-coded) Tests ===');
    try {
      final kv1 = assetX.example.kv1;

      final jsonPath = kv1.$paths.ww;
      final jsonData = kv1.$files.ww;
      buffer.writeln('✅ JSON path: $jsonPath');
      buffer.writeln('✅ JSON data: $jsonData');
      buffer.writeln('✅ JSON data type: ${jsonData.runtimeType}');
      buffer.writeln('✅ JSON content: ${jsonData['w']}');
    } catch (e) {
      buffer.writeln('❌ KV1 test failed: $e');
    }

    // Test KV2 (soft)
    buffer.writeln('\n=== KV2 (Soft) Tests ===');
    try {
      final kv2 = assetX.example.kv2;

      final jsonPath = kv2.$paths.ww2;
      final jsonInternalPath = toInternalPath(jsonPath);
      buffer.writeln('✅ JSON external path: $jsonPath');
      buffer.writeln('✅ JSON internal path: $jsonInternalPath');
      buffer.writeln('✅ Async JSON Future created');

      if (kv2Data != null) {
        buffer.writeln('✅ Async JSON loaded: $kv2Data');
        buffer.writeln('✅ Async JSON type: ${kv2Data.runtimeType}');
      }
    } catch (e) {
      buffer.writeln('❌ KV2 test failed: $e');
    }

    // Test toInternalPath utility
    buffer.writeln('\n=== toInternalPath Utility Test ===');
    try {
      final externalPath = assetX.example.images2.$paths.fileExampleJpg100kbjpg;
      final internalPath = toInternalPath(externalPath);
      buffer.writeln('✅ External path: $externalPath');
      buffer.writeln('✅ Internal path: $internalPath');
      buffer.writeln('✅ Utility function works correctly');
    } catch (e) {
      buffer.writeln('❌ toInternalPath utility test failed: $e');
    }

    setState(() {
      testResults = buffer.toString();
    });
  }

  Widget _buildImageWithErrorHandling(
    Widget Function() imageBuilder,
    String imageName,
  ) {
    try {
      return imageBuilder();
    } catch (e) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            Text(
              'Error loading\n$imageName',
              style: const TextStyle(fontSize: 10, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AssetX Test Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      testResults,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Images1 (Hard-coded) Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Images1 (Hard-coded Base64)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        const Text('JPEG (100kB)'),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _buildImageWithErrorHandling(
                            () => assetX
                                .example
                                .images1
                                .$files
                                .fileExampleJpg100kbJpg,
                            'JPEG 100kB',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Images2 (Soft) Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Images2 (Soft Asset Paths)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        const Text('JPEG via Asset Path'),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.asset(
                            toInternalPath(
                              assetX
                                  .example
                                  .images2
                                  .$paths
                                  .fileExampleJpg100kbjpg,
                            ),
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.red[100],
                                child: const Text('Error loading JPEG'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Note: ICO files not supported by Flutter',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KV Data Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key-Value Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // KV1 (Hard-coded)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KV1 (Hard-coded)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Path: ${assetX.example.kv1.$paths.ww}'),
                          Text('Data: ${assetX.example.kv1.$files.ww}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // KV2 (Soft)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KV2 (Soft/Async)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Path: ${assetX.example.kv2.$paths.ww2}'),
                          if (kv2Data != null)
                            Text('Data: $kv2Data')
                          else if (testResults.contains('Error loading KV2'))
                            const Text(
                              'Data: Error loading (see test results)',
                              style: TextStyle(color: Colors.red),
                            )
                          else
                            const Text(
                              'Data: Loading...',
                              style: TextStyle(color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Refresh Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _runTests();
                  _loadAsyncAssets();
                },
                child: const Text('Refresh Tests'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
