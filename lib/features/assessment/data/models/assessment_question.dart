class AssessmentQuestion {
  final String id;
  final String category;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct option
  final int points;
  final String? explanation; // Optional explanation for correct answer
  final List<String> tags; // Related topics

  AssessmentQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.points,
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
      'points': points,
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
      points: map['points'] ?? 1,
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
      points: json['points'] ?? 1,
      explanation: json['explanation'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Helper: Get points based on difficulty
  static int getPointsForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 1;
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
    int? points,
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
      points: points ?? this.points,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
    );
  }
}
