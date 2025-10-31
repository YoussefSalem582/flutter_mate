import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/achievement.dart';
import '../data/repositories/achievement_repository.dart';

class AchievementController extends GetxController {
  final AchievementRepository _repository;

  AchievementController(this._repository);

  final _achievements = <Achievement>[].obs;
  final _userProgress = <String, AchievementProgress>{}.obs;
  final _totalXP = 0.obs;
  final _isLoading = true.obs;

  List<Achievement> get achievements => _achievements;
  Map<String, AchievementProgress> get userProgress => _userProgress;
  int get totalXP => _totalXP.value;
  bool get isLoading => _isLoading.value;

  List<Achievement> get unlockedAchievements => _achievements
      .where((a) => _userProgress[a.id]?.isUnlocked == true)
      .toList();

  List<Achievement> get lockedAchievements => _achievements
      .where((a) => _userProgress[a.id]?.isUnlocked != true)
      .toList();

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    _isLoading.value = true;
    try {
      _achievements.value = await _repository.getAllAchievements();
      _userProgress.value = await _repository.getUserProgress();
      _calculateTotalXP();
    } finally {
      _isLoading.value = false;
    }
  }

  void _calculateTotalXP() {
    int xp = 0;
    for (var achievement in _achievements) {
      if (_userProgress[achievement.id]?.isUnlocked == true) {
        xp += achievement.xpReward;
      }
    }
    _totalXP.value = xp;
  }

  Future<void> incrementProgress(String achievementId, {int amount = 1}) async {
    final progress = _userProgress[achievementId];
    if (progress == null || progress.isUnlocked) return;

    final newProgress = progress.currentProgress + amount;
    await _repository.updateProgress(achievementId, newProgress);
    await loadAchievements();

    // Check if just unlocked
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    if (newProgress >= achievement.requiredProgress && !progress.isUnlocked) {
      _showUnlockNotification(achievement);
    }
  }

  Future<void> unlock(String achievementId) async {
    final progress = _userProgress[achievementId];
    if (progress?.isUnlocked == true) return;

    await _repository.unlockAchievement(achievementId);
    await loadAchievements();

    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    _showUnlockNotification(achievement);
  }

  void _showUnlockNotification(Achievement achievement) {
    Get.snackbar(
      '🎉 Achievement Unlocked!',
      achievement.title,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber.shade400,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(
            achievement.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '+${achievement.xpReward} XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to track achievements from other features
  Future<void> onLessonCompleted() async {
    await incrementProgress('first_lesson');
    await incrementProgress('five_lessons');
    await incrementProgress('ten_lessons');
    await incrementProgress('beginner_complete');
  }

  Future<void> onQuizCompleted(bool isPerfectScore) async {
    await incrementProgress('first_quiz');
    if (isPerfectScore) {
      await incrementProgress('perfect_score');
      await incrementProgress('quiz_master');
    }
  }

  Future<void> onResourceOpened() async {
    await incrementProgress('all_resources');
  }

  Future<void> onAdvancedModeEnabled() async {
    await incrementProgress('advanced_mode');
  }

  Future<void> onDailyStreak(int streakDays) async {
    if (streakDays >= 3) {
      await incrementProgress('three_day_streak', amount: streakDays);
    }
    if (streakDays >= 7) {
      await incrementProgress('week_streak', amount: streakDays);
    }
  }

  double getProgressPercentage(String achievementId) {
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    final progress = _userProgress[achievementId];
    if (progress == null) return 0.0;
    return (progress.currentProgress / achievement.requiredProgress).clamp(
      0.0,
      1.0,
    );
  }

  /// Handle skill assessment completion
  Future<void> onAssessmentCompleted({
    required String skillLevel,
    required int score,
    required int maxScore,
  }) async {
    // Track first assessment
    await incrementProgress('first_assessment');
    
    // Track overall assessments count
    await incrementProgress('assessment_master');
    
    // Check for perfect score
    if (score == maxScore) {
      await unlock('assessment_perfect');
    }
    
    // Track skill level achievements
    final skillLevelLower = skillLevel.toLowerCase();
    if (skillLevelLower.contains('intermediate')) {
      await unlock('assessment_intermediate');
    } else if (skillLevelLower.contains('advanced')) {
      await unlock('assessment_advanced');
    } else if (skillLevelLower.contains('expert')) {
      await unlock('assessment_expert');
    }
  }
}
