import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local implementation persisting progress via Hive + Firestore sync
class RoadmapRepositoryImpl implements RoadmapRepository {
  static const String _boxName = 'roadmap';
  static const String _progressPrefix = 'progress_';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get Hive box
  Box get _box => Hive.box(_boxName);

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is authenticated (not guest)
  bool get _isAuthenticated {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  @override
  Future<List<RoadmapStage>> fetchStages() async {
    // Static roadmap definition for now. These can be loaded from remote source later.
    return const [
      RoadmapStage(
        id: 'beginner',
        title: 'Beginner',
        subtitle: 'Master the fundamentals',
        icon: Icons.stars,
        color: Color(0xFF4CAF50),
        topics: ['Dart Basics', 'Widgets', 'Layouts', 'Navigation'],
      ),
      RoadmapStage(
        id: 'intermediate',
        title: 'Intermediate',
        subtitle: 'Build real applications',
        icon: Icons.trending_up,
        color: Color(0xFF2196F3),
        topics: ['State Management', 'APIs', 'Database', 'Authentication'],
      ),
      RoadmapStage(
        id: 'advanced',
        title: 'Advanced',
        subtitle: 'Become an expert',
        icon: Icons.workspace_premium,
        color: Color(0xFF9C27B0),
        topics: ['Architecture', 'Testing', 'Performance', 'Deployment'],
      ),
    ];
  }

  @override
  Future<double> getStageProgress(String stageId) async {
    // Try to sync from cloud first (if authenticated)
    if (_isAuthenticated) {
      try {
        await _syncProgressFromCloud(stageId);
      } catch (e) {
        print('Could not sync roadmap progress from cloud: $e');
        // Continue with local data
      }
    }

    return _box.get('$_progressPrefix$stageId',
        defaultValue: _defaultProgress(stageId)) as double;
  }

  @override
  Future<void> updateStageProgress(String stageId, double progress) async {
    final clampedProgress = progress.clamp(0.0, 1.0);

    // Save to Hive first (always succeeds, works offline)
    await _box.put('$_progressPrefix$stageId', clampedProgress);

    // Sync to Firestore (if authenticated)
    if (_isAuthenticated) {
      try {
        await _syncProgressToCloud(stageId, clampedProgress);
      } catch (e) {
        print('Could not sync roadmap progress to cloud: $e');
        // Continue anyway - local save succeeded
      }
    }
  }

  @override
  Future<double> getOverallProgress() async {
    final stages = await fetchStages();
    final progressValues = await Future.wait(
      stages.map((stage) => getStageProgress(stage.id)),
    );
    if (progressValues.isEmpty) return 0.0;
    return progressValues.reduce((a, b) => a + b) / progressValues.length;
  }

  double _defaultProgress(String stageId) {
    // Provide initial mock progress so returning users see non-zero values.
    switch (stageId) {
      case 'beginner':
        return 0.3;
      case 'intermediate':
        return 0.0;
      case 'advanced':
        return 0.0;
      default:
        return 0.0;
    }
  }

  /// Sync stage progress to Firestore
  Future<void> _syncProgressToCloud(String stageId, double progress) async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      final progressDoc = _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc('stages');

      await progressDoc.set({
        stageId: progress,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Roadmap stage $stageId progress synced to cloud');
    } catch (e) {
      print('❌ Error syncing roadmap progress to cloud: $e');
      rethrow;
    }
  }

  /// Sync stage progress from Firestore
  Future<void> _syncProgressFromCloud(String stageId) async {
    if (!_isAuthenticated || _userId == null) return;

    try {
      final progressDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc('stages')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data()!;
        if (data.containsKey(stageId)) {
          final cloudProgress = (data[stageId] as num).toDouble();
          final localProgress = _box.get('$_progressPrefix$stageId',
              defaultValue: _defaultProgress(stageId)) as double;

          // Use higher progress value (merge strategy)
          final mergedProgress =
              cloudProgress > localProgress ? cloudProgress : localProgress;

          // Save merged progress to Hive
          await _box.put('$_progressPrefix$stageId', mergedProgress);

          // If merged is different from cloud, sync back
          if (mergedProgress != cloudProgress) {
            await _syncProgressToCloud(stageId, mergedProgress);
          }
        }
      }
    } catch (e) {
      print('❌ Error syncing roadmap progress from cloud: $e');
      // Continue with local data
    }
  }
}
