class AssessmentQuestion {
  final String id;
  final String category;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct option
  final int xp; // XP reward for correct answer
  final String? explanation; // Optional explanation for correct answer
  final List<String> tags; // Related topics

  AssessmentQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.xp,
    this.explanation,
    this.tags = const [],
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'xp': xp,
      'explanation': explanation,
      'tags': tags,
    };
  }

  // Create from Firestore document
  factory AssessmentQuestion.fromMap(Map<String, dynamic> map) {
    return AssessmentQuestion(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      xp: map['xp'] ??
          map['points'] ??
          1, // Support both xp and old points field
      explanation: map['explanation'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Create from JSON (for hardcoded questions)
  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      xp: json['xp'] ??
          json['points'] ??
          1, // Support both xp and old points field
      explanation: json['explanation'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Helper: Get XP based on difficulty
  static int getXPForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 10;
      case 'medium':
        return 20;
      case 'hard':
        return 30;
      default:
        return 10;
    }
  }

  // Helper: Check if answer is correct
  bool isCorrect(int userAnswer) {
    return userAnswer == correctAnswer;
  }

  AssessmentQuestion copyWith({
    String? id,
    String? category,
    String? difficulty,
    String? question,
    List<String>? options,
    int? correctAnswer,
    int? xp,
    String? explanation,
    List<String>? tags,
  }) {
    return AssessmentQuestion(
      id: id ?? this.id,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      xp: xp ?? this.xp,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
    );
  }
}
