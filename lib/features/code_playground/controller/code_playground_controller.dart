import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/code_snippet.dart';
import '../data/repositories/code_playground_repository.dart';

// Output segment with color information
class OutputSegment {
  final String text;
  final Color color;
  final bool isBold;

  OutputSegment(this.text, this.color, {this.isBold = false});
}

class CodePlaygroundController extends GetxController {
  final CodePlaygroundRepository _repository;

  CodePlaygroundController(this._repository);

  final _snippets = <CodeSnippet>[].obs;
  final _currentSnippet = Rx<CodeSnippet?>(null);
  final _code = ''.obs;
  final _output = ''.obs;
  final _coloredOutput = <List<OutputSegment>>[].obs;
  final _isExecuting = false.obs;
  final _hasError = false.obs;
  final _selectedCategory = 'all'.obs;

  final TextEditingController codeController = TextEditingController();

  List<CodeSnippet> get snippets => _snippets;
  CodeSnippet? get currentSnippet => _currentSnippet.value;
  String get code => _code.value;
  String get output => _output.value;
  List<List<OutputSegment>> get coloredOutput => _coloredOutput;
  bool get isExecuting => _isExecuting.value;
  bool get hasError => _hasError.value;
  String get selectedCategory => _selectedCategory.value;

  List<CodeSnippet> get filteredSnippets {
    if (_selectedCategory.value == 'all') {
      return _snippets;
    }
    return _snippets
        .where((s) => s.category == _selectedCategory.value)
        .toList();
  }

  final List<String> categories = const [
    'all',
    'beginner',
    'control_flow',
    'collections',
    'functions',
    'oop',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSnippets();
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  void loadSnippets() {
    _snippets.value = _repository.getAllSnippets();
    if (_snippets.isNotEmpty && _currentSnippet.value == null) {
      loadSnippet(_snippets.first.id);
    }
  }

  void loadSnippet(String id) {
    final snippet = _repository.getSnippetById(id);
    if (snippet != null) {
      _currentSnippet.value = snippet;
      _code.value = snippet.initialCode;
      codeController.text = snippet.initialCode;
      _output.value = '';
      _coloredOutput.clear();
      _hasError.value = false;
    }
  }

  void updateCode(String newCode) {
    _code.value = newCode;
  }

  void setCategory(String category) {
    _selectedCategory.value = category;
  }

  Future<void> executeCode() async {
    if (_isExecuting.value) return;

    _isExecuting.value = true;
    _output.value = 'Executing...';
    _hasError.value = false;

    try {
      // Simulate code execution
      // In a real implementation, this would use DartPad API or similar
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, we'll simulate output based on the code
      final result = _simulateExecution(_code.value);

      _output.value = result.output;
      _hasError.value = !result.isSuccess;

      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Code executed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _output.value = 'Error: $e';
      _hasError.value = true;
    } finally {
      _isExecuting.value = false;
    }
  }

  CodeExecutionResult _simulateExecution(String code) {
    try {
      final startTime = DateTime.now();
      final outputLines = <String>[];

      // Clear previous colored output
      _coloredOutput.clear();

      // Simple simulation - extract print statements
      final printRegex = RegExp(r'''print\(['"](.+?)['"]\);|print\((.+?)\);''');
      final matches = printRegex.allMatches(code);

      if (matches.isEmpty) {
        return CodeExecutionResult(
          isSuccess: true,
          output: '(No output - code executed successfully)',
          executedAt: startTime,
          executionTimeMs: DateTime.now().difference(startTime).inMilliseconds,
        );
      }

      for (var match in matches) {
        // Get the content from whichever group matched
        final content =
            match.group(1) ?? match.group(2) ?? match.group(3) ?? '';

        // Handle string interpolation simulation
        var output = content;

        // Simple variable detection for common patterns
        if (output.contains('\$')) {
          output = _evaluateStringInterpolation(output, code);
        }

        outputLines.add(output);

        // Parse the output line for syntax highlighting
        _coloredOutput.add(_parseOutputLine(output));
      }

      final endTime = DateTime.now();
      return CodeExecutionResult(
        isSuccess: true,
        output: outputLines.join('\n'),
        executedAt: startTime,
        executionTimeMs: endTime.difference(startTime).inMilliseconds,
      );
    } catch (e) {
      return CodeExecutionResult(
        isSuccess: false,
        output: '',
        error: e.toString(),
        executedAt: DateTime.now(),
        executionTimeMs: 0,
      );
    }
  }

  String _evaluateStringInterpolation(String text, String code) {
    // This is a simple simulation - in real implementation, use proper parsing
    var result = text;

    // Handle common variable patterns
    final varRegex = RegExp(r'''var\s+(\w+)\s*=\s*['"](.+?)['"]''');
    final intRegex = RegExp(r'int\s+(\w+)\s*=\s*(\d+)');
    final doubleRegex = RegExp(r'double\s+(\w+)\s*=\s*([\d.]+)');
    final boolRegex = RegExp(r'bool\s+(\w+)\s*=\s*(true|false)');

    // Replace string variables
    for (var match in varRegex.allMatches(code)) {
      final varName = match.group(1);
      final varValue = match.group(2);
      result = result.replaceAll('\$$varName', varValue ?? '');
    }

    // Replace int variables
    for (var match in intRegex.allMatches(code)) {
      final varName = match.group(1);
      final varValue = match.group(2);
      result = result.replaceAll('\$$varName', varValue ?? '');
    }

    // Replace double variables
    for (var match in doubleRegex.allMatches(code)) {
      final varName = match.group(1);
      final varValue = match.group(2);
      result = result.replaceAll('\$$varName', varValue ?? '');
    }

    // Replace bool variables
    for (var match in boolRegex.allMatches(code)) {
      final varName = match.group(1);
      final varValue = match.group(2);
      result = result.replaceAll('\$$varName', varValue ?? '');
    }

    return result;
  }

  // Parse output line and apply VS Code-like syntax highlighting
  List<OutputSegment> _parseOutputLine(String line) {
    final segments = <OutputSegment>[];

    // VS Code-like color scheme (brighter colors for dark background)
    const stringColor = Color(0xFFCE9178); // Orange for strings
    const numberColor = Color(0xFFB5CEA8); // Light green for numbers
    const boolColor = Color(0xFF569CD6); // Blue for booleans
    const nullColor = Color(0xFF569CD6); // Blue for null
    const keywordColor = Color(0xFFC586C0); // Purple for keywords
    const punctuationColor = Color(0xFFD4D4D4); // Light gray for punctuation
    const defaultColor = Color(0xFFD4D4D4); // Light gray for default text

    var currentIndex = 0;
    final length = line.length;

    while (currentIndex < length) {
      // Check for brackets and special punctuation
      if (RegExp(r'[\[\]{}(),:]').hasMatch(line[currentIndex])) {
        segments.add(OutputSegment(line[currentIndex], punctuationColor));
        currentIndex++;
        continue;
      }

      // Check for string literals (single or double quotes)
      if (line[currentIndex] == '"' || line[currentIndex] == "'") {
        final quote = line[currentIndex];
        var endIndex = currentIndex + 1;

        // Find the closing quote
        while (endIndex < length && line[endIndex] != quote) {
          if (line[endIndex] == '\\' && endIndex + 1 < length) {
            endIndex += 2; // Skip escaped character
          } else {
            endIndex++;
          }
        }

        if (endIndex < length) {
          endIndex++; // Include the closing quote
        }

        segments.add(
          OutputSegment(line.substring(currentIndex, endIndex), stringColor),
        );
        currentIndex = endIndex;
        continue;
      }

      // Check for numbers (including decimals and negatives)
      if (RegExp(r'[0-9-]').hasMatch(line[currentIndex])) {
        var endIndex = currentIndex;
        // Handle negative numbers
        if (line[currentIndex] == '-' &&
            currentIndex + 1 < length &&
            RegExp(r'[0-9]').hasMatch(line[currentIndex + 1])) {
          endIndex++;
        }

        while (endIndex < length &&
            RegExp(r'[0-9.]').hasMatch(line[endIndex])) {
          endIndex++;
        }

        // Only treat as number if we moved past the initial position
        if (endIndex > currentIndex &&
            (line[currentIndex] != '-' || endIndex > currentIndex + 1)) {
          segments.add(
            OutputSegment(
              line.substring(currentIndex, endIndex),
              numberColor,
              isBold: true,
            ),
          );
          currentIndex = endIndex;
          continue;
        }
      }

      // Check for boolean keywords
      if (currentIndex + 4 <= length &&
          line.substring(currentIndex, currentIndex + 4) == 'true') {
        // Make sure it's a complete word
        if (currentIndex + 4 >= length ||
            !RegExp(r'[a-zA-Z0-9_]').hasMatch(line[currentIndex + 4])) {
          segments.add(OutputSegment('true', boolColor, isBold: true));
          currentIndex += 4;
          continue;
        }
      }

      if (currentIndex + 5 <= length &&
          line.substring(currentIndex, currentIndex + 5) == 'false') {
        // Make sure it's a complete word
        if (currentIndex + 5 >= length ||
            !RegExp(r'[a-zA-Z0-9_]').hasMatch(line[currentIndex + 5])) {
          segments.add(OutputSegment('false', boolColor, isBold: true));
          currentIndex += 5;
          continue;
        }
      }

      // Check for null keyword
      if (currentIndex + 4 <= length &&
          line.substring(currentIndex, currentIndex + 4) == 'null') {
        // Make sure it's a complete word
        if (currentIndex + 4 >= length ||
            !RegExp(r'[a-zA-Z0-9_]').hasMatch(line[currentIndex + 4])) {
          segments.add(OutputSegment('null', nullColor, isBold: true));
          currentIndex += 4;
          continue;
        }
      }

      // Check for common Dart keywords in output
      final keywords = [
        'List',
        'Set',
        'Map',
        'String',
        'int',
        'double',
        'bool',
      ];
      var foundKeyword = false;
      for (final keyword in keywords) {
        if (currentIndex + keyword.length <= length &&
            line.substring(currentIndex, currentIndex + keyword.length) ==
                keyword) {
          // Make sure it's a complete word
          if (currentIndex + keyword.length >= length ||
              !RegExp(
                r'[a-zA-Z0-9_]',
              ).hasMatch(line[currentIndex + keyword.length])) {
            segments.add(OutputSegment(keyword, keywordColor, isBold: true));
            currentIndex += keyword.length;
            foundKeyword = true;
            break;
          }
        }
      }

      if (foundKeyword) continue;

      // Default: collect text until next special character
      var endIndex = currentIndex;
      while (endIndex < length &&
          !RegExp(r'[0-9"\[\]{}(),:' + r"']").hasMatch(line[endIndex])) {
        // Check for keywords ahead
        var hasKeywordAhead = false;
        for (final keyword in ['true', 'false', 'null', ...keywords]) {
          if (line.substring(endIndex).startsWith(keyword)) {
            hasKeywordAhead = true;
            break;
          }
        }
        if (hasKeywordAhead) break;

        endIndex++;
      }

      if (endIndex > currentIndex) {
        segments.add(
          OutputSegment(line.substring(currentIndex, endIndex), defaultColor),
        );
        currentIndex = endIndex;
      } else {
        // Fallback: add single character
        segments.add(OutputSegment(line[currentIndex], defaultColor));
        currentIndex++;
      }
    }

    return segments.isEmpty ? [OutputSegment(line, defaultColor)] : segments;
  }

  void resetCode() {
    if (_currentSnippet.value != null) {
      _code.value = _currentSnippet.value!.initialCode;
      codeController.text = _currentSnippet.value!.initialCode;
      _output.value = '';
      _hasError.value = false;

      Get.snackbar(
        'Reset',
        'Code reset to original',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void clearOutput() {
    _output.value = '';
    _coloredOutput.clear();
    _hasError.value = false;
  }

  String getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'beginner':
        return '🎓 Beginner';
      case 'control_flow':
        return '🔄 Control Flow';
      case 'collections':
        return '📦 Collections';
      case 'functions':
        return '⚡ Functions';
      case 'oop':
        return '🏗️ OOP';
      default:
        return category;
    }
  }
}
