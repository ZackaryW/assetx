
import 'dart:convert';

Map<String, dynamic> jsonDecodeWithComments(String value) {
  // convert to lines
  final lines = LineSplitter.split(value);
  final jsonString = StringBuffer();
  for (var line in lines) {
    // Remove comments
    final commentIndex = line.indexOf('//');
    if (commentIndex != -1) {
      line = line.substring(0, commentIndex);
    }
    jsonString.writeln(line);
  }
  return json.decode(jsonString.toString());
}
