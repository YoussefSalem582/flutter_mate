import 'package:flutter/material.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local implementation persisting progress via [SharedPreferences].
class RoadmapRepositoryImpl implements RoadmapRepository {
  RoadmapRepositoryImpl({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _progressPrefix = 'roadmap_progress_';

  SharedPreferences? _preferences;

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
    final prefs = await _ensurePrefs();
    return prefs.getDouble('$_progressPrefix$stageId') ??
        _defaultProgress(stageId);
  }

  @override
  Future<void> updateStageProgress(String stageId, double progress) async {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final prefs = await _ensurePrefs();
    await prefs.setDouble('$_progressPrefix$stageId', clampedProgress);
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

  Future<SharedPreferences> _ensurePrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
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
}
