import 'package:cloud_firestore/cloud_firestore.dart';
import 'skill_level.dart';

class SkillAssessment {
  final String id;
  final String userId;
  final Map<String, SkillLevel> skills; // category -> skill level
  final DateTime completedAt;
  final int totalScore;
  final int maxScore;
  final Map<String, int> categoryScores; // category -> score
  final Map<String, int> categoryMaxScores; // category -> max possible score
  final List<String> weakAreas; // Categories needing improvement
  final List<String> strongAreas; // Categories with high performance
  final Duration timeTaken;
  final int questionsAnswered;
  final int correctAnswers;

  SkillAssessment({
    required this.id,
    required this.userId,
    required this.skills,
    required this.completedAt,
    required this.totalScore,
    required this.maxScore,
    required this.categoryScores,
    required this.categoryMaxScores,
    required this.weakAreas,
    required this.strongAreas,
    required this.timeTaken,
    required this.questionsAnswered,
    required this.correctAnswers,
  });

  // Calculate overall percentage
  double get overallPercentage {
    if (maxScore == 0) return 0;
    return (totalScore / maxScore) * 100;
  }

  // Get overall skill level
  SkillLevel get overallSkillLevel {
    return SkillLevel.fromPercentage(overallPercentage);
  }

  // Get accuracy percentage
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }

  // Get category percentage
  double getCategoryPercentage(String category) {
    final score = categoryScores[category] ?? 0;
    final maxScore = categoryMaxScores[category] ?? 0;
    if (maxScore == 0) return 0;
    return (score / maxScore) * 100;
  }

  // Get skill level for specific category
  SkillLevel getCategorySkillLevel(String category) {
    return skills[category] ?? SkillLevel.beginner;
  }

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'skills': skills.map((key, value) => MapEntry(key, value.name)),
      'completedAt': Timestamp.fromDate(completedAt),
      'totalScore': totalScore,
      'maxScore': maxScore,
      'categoryScores': categoryScores,
      'categoryMaxScores': categoryMaxScores,
      'weakAreas': weakAreas,
      'strongAreas': strongAreas,
      'timeTaken': timeTaken.inSeconds,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
    };
  }

  // Create from Firestore document
  factory SkillAssessment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillAssessment.fromMap(data);
  }

  factory SkillAssessment.fromMap(Map<String, dynamic> map) {
    // Parse skills map
    final skillsMap = (map['skills'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        SkillLevel.values.firstWhere(
          (e) => e.name == value,
          orElse: () => SkillLevel.beginner,
        ),
      ),
    );

    return SkillAssessment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      skills: skillsMap,
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
      totalScore: map['totalScore'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      categoryScores: Map<String, int>.from(map['categoryScores'] ?? {}),
      categoryMaxScores: Map<String, int>.from(map['categoryMaxScores'] ?? {}),
      weakAreas: List<String>.from(map['weakAreas'] ?? []),
      strongAreas: List<String>.from(map['strongAreas'] ?? []),
      timeTaken: Duration(seconds: map['timeTaken'] ?? 0),
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
    );
  }

  SkillAssessment copyWith({
    String? id,
    String? userId,
    Map<String, SkillLevel>? skills,
    DateTime? completedAt,
    int? totalScore,
    int? maxScore,
    Map<String, int>? categoryScores,
    Map<String, int>? categoryMaxScores,
    List<String>? weakAreas,
    List<String>? strongAreas,
    Duration? timeTaken,
    int? questionsAnswered,
    int? correctAnswers,
  }) {
    return SkillAssessment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skills: skills ?? this.skills,
      completedAt: completedAt ?? this.completedAt,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      categoryScores: categoryScores ?? this.categoryScores,
      categoryMaxScores: categoryMaxScores ?? this.categoryMaxScores,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      timeTaken: timeTaken ?? this.timeTaken,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}
