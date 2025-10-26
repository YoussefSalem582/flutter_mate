/// Quiz question model for interactive learning
class QuizQuestion {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.points = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      points: json['points'] as int? ?? 10,
    );
  }
}
