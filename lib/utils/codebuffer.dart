class CodeBuffer {
  final List<String> importLines;
  final StringBuffer codeBody;

  CodeBuffer() : importLines = [], codeBody = StringBuffer();

  void addImport(String importLine) {
    importLines.add(importLine);
  }

  void addCode(String code) {
    codeBody.writeln(code);
  }

  String generate() {
    return '''
${importLines.join('\n')}

${codeBody.toString()}
''';
  }

  void merge(CodeBuffer other) {
    importLines.addAll(other.importLines);
    codeBody.write(other.codeBody.toString());
  }
}
