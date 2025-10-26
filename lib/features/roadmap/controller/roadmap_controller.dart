import 'package:flutter/material.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/lesson_repository.dart';
import 'package:get/get.dart';

/// Controller responsible for managing roadmap stages and their progress.
class RoadmapController extends GetxController {
  RoadmapController({
    required RoadmapRepository repository,
    LessonRepository? lessonRepository,
  }) : _repository = repository,
       _lessonRepository = lessonRepository;

  final RoadmapRepository _repository;
  final LessonRepository? _lessonRepository;

  final RxBool isLoading = false.obs;
  final RxList<RoadmapStage> stages = <RoadmapStage>[].obs;
  final RxMap<String, double> progress = <String, double>{}.obs;

  double get overallProgress {
    if (progress.isEmpty) return 0.0;
    return progress.values.reduce((a, b) => a + b) / progress.length;
  }

  @override
  void onInit() {
    super.onInit();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    isLoading.value = true;
    try {
      final fetchedStages = await _repository.fetchStages();
      stages.assignAll(fetchedStages);

      // Load progress from lesson completion if available
      for (final stage in fetchedStages) {
        if (_lessonRepository != null) {
          final lessonProgress = await _lessonRepository
              .getStageCompletionPercentage(stage.id);
          progress[stage.id] = lessonProgress;
        } else {
          final value = await _repository.getStageProgress(stage.id);
          progress[stage.id] = value;
        }
      }
    } catch (e) {
      debugPrint('Failed to load roadmap: $e');
      Get.snackbar(
        'Error',
        'Unable to load roadmap data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProgress() async {
    // Refresh stage progress from lesson completion
    if (_lessonRepository != null) {
      for (final stage in stages) {
        final lessonProgress = await _lessonRepository
            .getStageCompletionPercentage(stage.id);
        progress[stage.id] = lessonProgress;
      }
      progress.refresh();
    }
  }

  Future<void> updateProgress(String stageId, double value) async {
    progress[stageId] = value.clamp(0.0, 1.0);
    progress.refresh();
    await _repository.updateStageProgress(stageId, progress[stageId]!);
  }

  double stageProgress(String stageId) {
    return progress[stageId] ?? 0.0;
  }
}
