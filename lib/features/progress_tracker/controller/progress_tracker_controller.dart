import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/controller/lesson_controller.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';
import 'package:get/get.dart';

/// Aggregates progress information for the tracker screen.
class ProgressTrackerController extends GetxController {
  ProgressTrackerController({
    required RoadmapController roadmapController,
    required LessonController lessonController,
  })  : _roadmapController = roadmapController,
        _lessonController = lessonController;

  final RoadmapController _roadmapController;
  final LessonController _lessonController;

  final RxDouble overallProgress = 0.0.obs;
  final RxInt lessonsCompleted = 0.obs;
  final RxInt totalLessons = 0.obs;

  final RxInt projectsCompleted = 5.obs; // Placeholder values for now
  final RxInt dayStreak = 8.obs;
  final RxInt xpPoints = 350.obs;

  final RxList<ActivityItem> activity = <ActivityItem>[
    const ActivityItem(
      title: 'Completed: Dart Basics',
      subtitle: '2 hours ago',
      icon: Icons.check_circle,
      color: Color(0xFF4CAF50),
    ),
    const ActivityItem(
      title: 'Started: Widget Tree',
      subtitle: '5 hours ago',
      icon: Icons.play_circle,
      color: Color(0xFF2196F3),
    ),
    const ActivityItem(
      title: 'Achievement: First Widget',
      subtitle: 'Yesterday',
      icon: Icons.emoji_events,
      color: Color(0xFFFFC107),
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _computeStats();
    ever<Map<String, double>>(
      _roadmapController.progress,
      (_) => _computeStats(),
    );
    ever<List<RoadmapStage>>(_roadmapController.stages, (_) => _computeStats());
    // Recompute when navigating back to progress page to get latest lesson data
    ever(Get.currentRoute.obs, (_) => _computeStats());
  }

  void _computeStats() {
    // Get total lessons completed from lesson controller
    final completionStatus = _lessonController.completionStatus;
    final completed =
        completionStatus.values.where((isCompleted) => isCompleted).length;

    lessonsCompleted.value = completed;
    totalLessons.value = completionStatus.length;

    // Calculate overall progress from all stages
    double totalProgress = 0;
    int stageCount = _roadmapController.stages.length;

    for (final stage in _roadmapController.stages) {
      totalProgress += _roadmapController.stageProgress(stage.id);
    }

    overallProgress.value = stageCount > 0 ? totalProgress / stageCount : 0.0;

    // Derived stats
    projectsCompleted.value = max((lessonsCompleted.value / 3).round(), 0);
    dayStreak.value = max((overallProgress.value * 30).round(), 0);
    xpPoints.value =
        (lessonsCompleted.value * 25) + (projectsCompleted.value * 100);
  }
}

/// Activity feed item used to populate the recent activity list.
class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
