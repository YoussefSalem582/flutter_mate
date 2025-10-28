import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to sync user progress between local storage (Hive) and Firestore
class ProgressSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _boxName = 'progress';
  static const _completedLessonsKey = 'completed_lessons';
  static const _advancedModeKey = 'advanced_mode';
  static const _lastSyncKey = 'last_sync_timestamp';

  /// Get Hive box
  Box get _box => Hive.box(_boxName);

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is authenticated (not guest)
  bool get _isAuthenticated {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Sync local progress to Firestore
  Future<void> syncToCloud() async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      // Get local data from Hive
      final completedLessons = List<String>.from(
          _box.get(_completedLessonsKey, defaultValue: <String>[]));
      final advancedMode =
          _box.get(_advancedModeKey, defaultValue: false) as bool;

      // Get user's progress document
      final progressDoc = _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc('lessons');

      // Save to Firestore
      await progressDoc.set({
        'completedLessons': completedLessons,
        'advancedMode': advancedMode,
        'lessonsCompleted': completedLessons.length,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update user stats in main user document
      await _firestore.collection('users').doc(_userId).update({
        'lessonsCompleted': completedLessons.length,
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      // Save last sync timestamp
      await _box.put(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Progress synced to cloud successfully');
    } catch (e) {
      print('❌ Error syncing progress to cloud: $e');
    }
  }

  /// Sync Firestore progress to local storage
  Future<void> syncFromCloud() async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      // Get user's progress document
      final progressDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc('lessons')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data()!;

        // Get cloud data
        final cloudCompletedLessons =
            List<String>.from(data['completedLessons'] ?? []);
        final cloudAdvancedMode = data['advancedMode'] ?? false;

        // Get local data from Hive
        final localCompletedLessons = List<String>.from(
            _box.get(_completedLessonsKey, defaultValue: <String>[]));

        // Merge completed lessons (union of both)
        final mergedLessons = {
          ...localCompletedLessons,
          ...cloudCompletedLessons,
        }.toList();

        // Save merged data locally to Hive
        await _box.put(_completedLessonsKey, mergedLessons);
        await _box.put(_advancedModeKey, cloudAdvancedMode);

        // If merged data is different from cloud, sync back to cloud
        if (mergedLessons.length != cloudCompletedLessons.length) {
          await syncToCloud();
        }

        print('✅ Progress synced from cloud successfully');
      } else {
        // No cloud data exists, sync local data to cloud
        await syncToCloud();
      }
    } catch (e) {
      print('❌ Error syncing progress from cloud: $e');
    }
  }

  /// Mark a lesson as completed and sync to cloud
  Future<void> markLessonCompleted(String lessonId) async {
    // Save locally first to Hive
    final completedLessons = List<String>.from(
        _box.get(_completedLessonsKey, defaultValue: <String>[]));
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      await _box.put(_completedLessonsKey, completedLessons);
    }

    // Sync to cloud if authenticated
    if (_isAuthenticated) {
      await syncToCloud();
    }
  }

  /// Set advanced mode and sync to cloud
  Future<void> setAdvancedMode(bool enabled) async {
    // Save locally first to Hive
    await _box.put(_advancedModeKey, enabled);

    // Sync to cloud if authenticated
    if (_isAuthenticated) {
      await syncToCloud();
    }
  }

  /// Get last sync timestamp
  DateTime? getLastSyncTime() {
    final timestamp = _box.get(_lastSyncKey) as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Auto-sync on app start
  Future<void> autoSync() async {
    if (!_isAuthenticated) {
      print('⏭️ Skipping auto-sync: User not authenticated');
      return;
    }

    final lastSync = getLastSyncTime();
    final now = DateTime.now();

    // Sync if never synced or if more than 5 minutes since last sync
    if (lastSync == null || now.difference(lastSync).inMinutes > 5) {
      print('🔄 Auto-syncing progress...');
      await syncFromCloud();
    } else {
      print('✓ Progress already synced recently');
    }
  }

  /// Clear local data (for sign out)
  Future<void> clearLocalData() async {
    await _box.delete(_completedLessonsKey);
    await _box.delete(_advancedModeKey);
    await _box.delete(_lastSyncKey);
    print('🗑️ Local progress data cleared');
  }

  /// Migrate guest progress to authenticated user
  Future<void> migrateGuestProgress() async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      // Get local guest progress from Hive
      final guestLessons = List<String>.from(
          _box.get(_completedLessonsKey, defaultValue: <String>[]));

      if (guestLessons.isNotEmpty) {
        print(
            '🔄 Migrating ${guestLessons.length} lessons from guest to user account...');

        // Sync local data to new user account
        await syncToCloud();

        print('✅ Guest progress migrated successfully');
      }
    } catch (e) {
      print('❌ Error migrating guest progress: $e');
    }
  }
}
