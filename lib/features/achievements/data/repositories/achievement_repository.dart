import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAllAchievements();
  Future<Map<String, AchievementProgress>> getUserProgress();
  Future<void> updateProgress(String achievementId, int progress);
  Future<void> unlockAchievement(String achievementId);
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
}

class AchievementRepositoryImpl implements AchievementRepository {
  static const _progressKey = 'achievement_progress';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hive box getter for achievements (reuse progress box)
  Box get _box => Hive.box('progress');

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is authenticated (not guest)
  bool get _isAuthenticated {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

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

    // Skill Assessment Achievements
    Achievement(
      id: 'first_assessment',
      title: '📊 First Assessment',
      description: 'Complete your first skill assessment',
      icon: '📊',
      requiredProgress: 1,
      category: 'assessment',
      xpReward: 100,
    ),
    Achievement(
      id: 'assessment_intermediate',
      title: '📈 Intermediate Skills',
      description: 'Reach Intermediate level in assessment',
      icon: '📈',
      requiredProgress: 1,
      category: 'assessment',
      xpReward: 200,
    ),
    Achievement(
      id: 'assessment_advanced',
      title: '🚀 Advanced Developer',
      description: 'Reach Advanced level in assessment',
      icon: '🚀',
      requiredProgress: 1,
      category: 'assessment',
      xpReward: 300,
    ),
    Achievement(
      id: 'assessment_expert',
      title: '💎 Flutter Expert',
      description: 'Reach Expert level in assessment',
      icon: '💎',
      requiredProgress: 1,
      category: 'assessment',
      xpReward: 500,
    ),
    Achievement(
      id: 'assessment_perfect',
      title: '🏆 Perfect Assessment',
      description: 'Score 100% on skill assessment',
      icon: '🏆',
      requiredProgress: 1,
      category: 'assessment',
      xpReward: 400,
    ),
    Achievement(
      id: 'assessment_master',
      title: '👑 Assessment Master',
      description: 'Complete 10 skill assessments',
      icon: '👑',
      requiredProgress: 10,
      category: 'assessment',
      xpReward: 600,
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
    // Save to Hive first (always succeeds, works offline)
    final json = jsonEncode(
      progress.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _box.put(_progressKey, json);

    // Sync to Firestore (if authenticated)
    if (_isAuthenticated) {
      try {
        await syncToCloud();
      } catch (e) {
        print('Could not sync achievements to cloud: $e');
        // Continue anyway - local save succeeded
      }
    }
  }

  /// Sync achievements progress to Firestore
  @override
  Future<void> syncToCloud() async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      // Get local data from Hive
      final progressJson = _box.get(_progressKey) as String?;
      if (progressJson == null) return;

      final progressMap = Map<String, dynamic>.from(jsonDecode(progressJson));

      // Save to Firestore
      final achievementsDoc = _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .doc('progress');

      await achievementsDoc.set({
        'progress': progressMap,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Achievements synced to cloud successfully');
    } catch (e) {
      print('❌ Error syncing achievements to cloud: $e');
      rethrow;
    }
  }

  /// Sync achievements progress from Firestore
  @override
  Future<void> syncFromCloud() async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      // Get user's achievements document
      final achievementsDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .doc('progress')
          .get();

      if (achievementsDoc.exists) {
        final data = achievementsDoc.data()!;
        final cloudProgressMap =
            Map<String, dynamic>.from(data['progress'] ?? {});

        // Get local data
        final localProgressJson = _box.get(_progressKey) as String?;
        final localProgressMap = localProgressJson != null
            ? Map<String, dynamic>.from(jsonDecode(localProgressJson))
            : <String, dynamic>{};

        // Merge progress: prefer more recent unlock dates, higher progress values
        final mergedMap = <String, dynamic>{...localProgressMap};

        for (final entry in cloudProgressMap.entries) {
          final cloudProgress = AchievementProgress.fromJson(
            Map<String, dynamic>.from(entry.value),
          );

          if (!mergedMap.containsKey(entry.key)) {
            // New achievement from cloud
            mergedMap[entry.key] = entry.value;
          } else {
            // Merge existing achievement
            final localProgress = AchievementProgress.fromJson(
              Map<String, dynamic>.from(mergedMap[entry.key]),
            );

            // Use higher progress and earlier unlock date
            final merged = AchievementProgress(
              achievementId: entry.key,
              currentProgress:
                  cloudProgress.currentProgress > localProgress.currentProgress
                      ? cloudProgress.currentProgress
                      : localProgress.currentProgress,
              isUnlocked: cloudProgress.isUnlocked || localProgress.isUnlocked,
              unlockedAt: _getEarlierDate(
                  cloudProgress.unlockedAt, localProgress.unlockedAt),
            );

            mergedMap[entry.key] = merged.toJson();
          }
        }

        // Save merged data to Hive
        final mergedJson = jsonEncode(mergedMap);
        await _box.put(_progressKey, mergedJson);

        // If merged data is different, sync back to cloud
        if (mergedJson != jsonEncode(cloudProgressMap)) {
          await syncToCloud();
        }

        print('✅ Achievements synced from cloud successfully');
      } else {
        // No cloud data exists, sync local data to cloud
        await syncToCloud();
      }
    } catch (e) {
      print('❌ Error syncing achievements from cloud: $e');
      rethrow;
    }
  }

  /// Helper to get earlier of two dates
  DateTime? _getEarlierDate(DateTime? date1, DateTime? date2) {
    if (date1 == null) return date2;
    if (date2 == null) return date1;
    return date1.isBefore(date2) ? date1 : date2;
  }
}
