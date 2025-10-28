import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../achievements/controller/achievement_controller.dart';

/// Service for tracking quiz completion and scores
class QuizTrackingService extends GetxService {
  static const String _boxName = 'quiz';

  /// Get Hive box
  Box get _box => Hive.box(_boxName);

  final RxMap<String, QuizResult> quizResults = <String, QuizResult>{}.obs;
  final RxInt totalQuizzesCompleted = 0.obs;
  final RxInt totalQuizXP = 0.obs;
  final RxDouble averageScore = 0.0.obs;

  Future<QuizTrackingService> init() async {
    await _loadQuizResults();
    return this;
  }

  Future<void> _loadQuizResults() async {
    final allKeys =
        _box.keys.where((key) => key.toString().startsWith('quiz_'));

    for (final key in allKeys) {
      final lessonId = key.toString().replaceFirst('quiz_', '');
      final data = _box.get(key) as Map?;

      if (data != null) {
        quizResults[lessonId] = QuizResult(
          lessonId: lessonId,
          score: data['score'] as int? ?? 0,
          maxScore: data['maxScore'] as int? ?? 0,
          xpEarned: data['xpEarned'] as int? ?? 0,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              data['timestamp'] as int? ?? 0),
          correctAnswers: data['correctAnswers'] as int? ?? 0,
          totalQuestions: data['totalQuestions'] as int? ?? 0,
        );
      }
    }

    _updateStats();
  }

  Future<void> saveQuizResult({
    required String lessonId,
    required int score,
    required int maxScore,
    required int xpEarned,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final now = DateTime.now();

    // Save quiz result as a map
    await _box.put('quiz_$lessonId', {
      'score': score,
      'maxScore': maxScore,
      'xpEarned': xpEarned,
      'timestamp': now.millisecondsSinceEpoch,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
    });

    quizResults[lessonId] = QuizResult(
      lessonId: lessonId,
      score: score,
      maxScore: maxScore,
      xpEarned: xpEarned,
      timestamp: now,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    _updateStats();

    // Track quiz achievements
    final achievementController = Get.find<AchievementController>();
    final isPerfectScore = correctAnswers == totalQuestions;
    await achievementController.onQuizCompleted(isPerfectScore);
  }

  void _updateStats() {
    totalQuizzesCompleted.value = quizResults.length;

    if (quizResults.isNotEmpty) {
      totalQuizXP.value = quizResults.values.fold<int>(
        0,
        (sum, result) => sum + result.xpEarned,
      );

      final totalScorePercent = quizResults.values.fold<double>(
        0.0,
        (sum, result) => sum + result.scorePercentage,
      );
      averageScore.value = totalScorePercent / quizResults.length;
    } else {
      totalQuizXP.value = 0;
      averageScore.value = 0.0;
    }
  }

  QuizResult? getQuizResult(String lessonId) {
    return quizResults[lessonId];
  }

  bool hasCompletedQuiz(String lessonId) {
    return quizResults.containsKey(lessonId);
  }

  /// Check if user got all questions correct (100% score)
  bool hasPassedQuizPerfectly(String lessonId) {
    final result = quizResults[lessonId];
    if (result == null) return false;
    return result.correctAnswers == result.totalQuestions;
  }

  double getQuizScore(String lessonId) {
    final result = quizResults[lessonId];
    return result?.scorePercentage ?? 0.0;
  }

  Future<void> clearAllQuizResults() async {
    final keys =
        _box.keys.where((key) => key.toString().startsWith('quiz_')).toList();
    for (final key in keys) {
      await _box.delete(key);
    }
    quizResults.clear();
    _updateStats();
  }
}

class QuizResult {
  final String lessonId;
  final int score;
  final int maxScore;
  final int xpEarned;
  final DateTime timestamp;
  final int correctAnswers;
  final int totalQuestions;

  QuizResult({
    required this.lessonId,
    required this.score,
    required this.maxScore,
    required this.xpEarned,
    required this.timestamp,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  double get scorePercentage {
    if (maxScore == 0) return 0.0;
    return (score / maxScore) * 100;
  }

  bool get isPassed => scorePercentage >= 70.0;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
