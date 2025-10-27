/// Model for code snippets in the playground
class CodeSnippet {
  final String id;
  final String title;
  final String description;
  final String initialCode;
  final String category;
  final List<String> tags;
  final String expectedOutput;

  const CodeSnippet({
    required this.id,
    required this.title,
    required this.description,
    required this.initialCode,
    this.category = 'general',
    this.tags = const [],
    this.expectedOutput = '',
  });

  CodeSnippet copyWith({
    String? id,
    String? title,
    String? description,
    String? initialCode,
    String? category,
    List<String>? tags,
    String? expectedOutput,
  }) {
    return CodeSnippet(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      initialCode: initialCode ?? this.initialCode,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      expectedOutput: expectedOutput ?? this.expectedOutput,
    );
  }
}

/// Model for code execution result
class CodeExecutionResult {
  final bool isSuccess;
  final String output;
  final String? error;
  final DateTime executedAt;
  final int executionTimeMs;

  const CodeExecutionResult({
    required this.isSuccess,
    required this.output,
    this.error,
    required this.executedAt,
    required this.executionTimeMs,
  });

  bool get hasError => error != null && error!.isNotEmpty;
}
