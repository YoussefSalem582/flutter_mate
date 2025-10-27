import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';

/// Aggregated snapshot of key progress metrics sourced from multiple controllers.
class ProgressMetrics {
  ProgressMetrics({
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.achievementsUnlocked,
    required this.totalAchievements,
    required this.achievementsXP,
    required this.quizXP,
    required this.quizzesCompleted,
    required this.averageQuizScore,
  });

  static const int xpPerLevel = 1000;

  final int lessonsCompleted;
  final int totalLessons;
  final int achievementsUnlocked;
  final int totalAchievements;
  final int achievementsXP;
  final int quizXP;
  final int quizzesCompleted;
  final double averageQuizScore;

  int get totalXP => achievementsXP + quizXP;

  int get currentLevel => (totalXP ~/ xpPerLevel) + 1;

  double get xpProgressToNextLevel {
    if (totalXP <= 0) {
      return 0;
    }
    final remainder = totalXP % xpPerLevel;
    return remainder / xpPerLevel;
  }

  String get lessonsLabel {
    if (totalLessons == 0) {
      return '$lessonsCompleted';
    }
    return '$lessonsCompleted/$totalLessons';
  }

  String get achievementsLabel {
    if (totalAchievements == 0) {
      return '$achievementsUnlocked';
    }
    return '$achievementsUnlocked/$totalAchievements';
  }

  /// Builds a consistent metrics snapshot from the app controllers.
  factory ProgressMetrics.fromSources({
    required ProgressTrackerController progressController,
    required AchievementController achievementController,
    required QuizTrackingService quizService,
  }) {
    return ProgressMetrics(
      lessonsCompleted: progressController.lessonsCompleted.value,
      totalLessons: progressController.totalLessons.value,
      achievementsUnlocked: achievementController.unlockedAchievements.length,
      totalAchievements: achievementController.achievements.length,
      achievementsXP: achievementController.totalXP,
      quizXP: quizService.totalQuizXP.value,
      quizzesCompleted: quizService.totalQuizzesCompleted.value,
      averageQuizScore: quizService.averageScore.value,
    );
  }
}
