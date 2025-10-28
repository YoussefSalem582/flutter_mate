import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAllAchievements();
  Future<Map<String, AchievementProgress>> getUserProgress();
  Future<void> updateProgress(String achievementId, int progress);
  Future<void> unlockAchievement(String achievementId);
}

class AchievementRepositoryImpl implements AchievementRepository {
  static const _progressKey = 'achievement_progress';

  // Hive box getter for achievements (reuse progress box)
  Box get _box => Hive.box('progress');

  AchievementRepositoryImpl();

  final List<Achievement> _achievements = const [
    // Lesson Achievements
    Achievement(
      id: 'first_lesson',
      title: '🎓 First Steps',
      description: 'Complete your first lesson',
      icon: '🎓',
      requiredProgress: 1,
      category: 'lessons',
      xpReward: 50,
    ),
    Achievement(
      id: 'five_lessons',
      title: '🔥 Getting Started',
      description: 'Complete 5 lessons',
      icon: '🔥',
      requiredProgress: 5,
      category: 'lessons',
      xpReward: 100,
    ),
    Achievement(
      id: 'ten_lessons',
      title: '⚡ On Fire',
      description: 'Complete 10 lessons',
      icon: '⚡',
      requiredProgress: 10,
      category: 'lessons',
      xpReward: 200,
    ),
    Achievement(
      id: 'beginner_complete',
      title: '🌟 Beginner Master',
      description: 'Complete all beginner lessons',
      icon: '🌟',
      requiredProgress: 8,
      category: 'lessons',
      xpReward: 500,
    ),

    // Quiz Achievements
    Achievement(
      id: 'first_quiz',
      title: '🎯 Quiz Taker',
      description: 'Complete your first quiz',
      icon: '🎯',
      requiredProgress: 1,
      category: 'quizzes',
      xpReward: 50,
    ),
    Achievement(
      id: 'quiz_master',
      title: '🏆 Quiz Master',
      description: 'Score 100% on 5 quizzes',
      icon: '🏆',
      requiredProgress: 5,
      category: 'quizzes',
      xpReward: 300,
    ),

    // Streak Achievements
    Achievement(
      id: 'three_day_streak',
      title: '📅 Consistent Learner',
      description: 'Learn for 3 days in a row',
      icon: '📅',
      requiredProgress: 3,
      category: 'streak',
      xpReward: 150,
    ),
    Achievement(
      id: 'week_streak',
      title: '🔥 Weekly Warrior',
      description: 'Learn for 7 days in a row',
      icon: '🔥',
      requiredProgress: 7,
      category: 'streak',
      xpReward: 400,
    ),

    // Special Achievements
    Achievement(
      id: 'advanced_mode',
      title: '🚀 Advanced User',
      description: 'Enable advanced mode',
      icon: '🚀',
      requiredProgress: 1,
      category: 'special',
      xpReward: 100,
    ),
    Achievement(
      id: 'all_resources',
      title: '📚 Resource Explorer',
      description: 'Open 10 learning resources',
      icon: '📚',
      requiredProgress: 10,
      category: 'special',
      xpReward: 150,
    ),
    Achievement(
      id: 'perfect_score',
      title: '💯 Perfectionist',
      description: 'Get 100% on any quiz',
      icon: '💯',
      requiredProgress: 1,
      category: 'quizzes',
      xpReward: 200,
    ),
  ];

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return _achievements;
  }

  @override
  Future<Map<String, AchievementProgress>> getUserProgress() async {
    final json = _box.get(_progressKey) as String?;
    if (json == null) {
      // Initialize with zero progress for all achievements
      return {
        for (var achievement in _achievements)
          achievement.id: AchievementProgress(
            achievementId: achievement.id,
            currentProgress: 0,
            isUnlocked: false,
          ),
      };
    }

    final Map<String, dynamic> decoded = jsonDecode(json);
    return decoded.map(
      (key, value) => MapEntry(
        key,
        AchievementProgress.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Future<void> updateProgress(String achievementId, int progress) async {
    final currentProgress = await getUserProgress();
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);

    final updated = currentProgress[achievementId]?.copyWith(
      currentProgress: progress,
      isUnlocked: progress >= achievement.requiredProgress,
      unlockedAt:
          progress >= achievement.requiredProgress ? DateTime.now() : null,
    );

    if (updated != null) {
      currentProgress[achievementId] = updated;
      await _saveProgress(currentProgress);
    }
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    final currentProgress = await getUserProgress();
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);

    currentProgress[achievementId] = AchievementProgress(
      achievementId: achievementId,
      currentProgress: achievement.requiredProgress,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    await _saveProgress(currentProgress);
  }

  Future<void> _saveProgress(Map<String, AchievementProgress> progress) async {
    final json = jsonEncode(
      progress.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _box.put(_progressKey, json);
  }
}
