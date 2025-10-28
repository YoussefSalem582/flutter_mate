import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/lesson.dart';
import '../data/repositories/lesson_repository.dart';
import '../../achievements/controller/achievement_controller.dart';

class LessonController extends GetxController {
  final LessonRepository _repository;

  LessonController(this._repository);

  final _lessons = <Lesson>[].obs;
  final _completionStatus = <String, bool>{}.obs;
  final _isLoading = false.obs;
  final _currentStageId = ''.obs;
  final _advancedMode = false.obs; // Advanced user mode to skip prerequisites

  List<Lesson> get lessons => _lessons;
  Map<String, bool> get completionStatus => _completionStatus;
  bool get isLoading => _isLoading.value;
  String get currentStageId => _currentStageId.value;
  bool get advancedMode => _advancedMode.value;

  // Computed properties
  int get completedCount => _completionStatus.values.where((v) => v).length;
  double get completionPercentage =>
      _lessons.isEmpty ? 0.0 : completedCount / _lessons.length;

  @override
  void onInit() {
    super.onInit();
    _loadCompletionStatus();
    _loadAdvancedMode();
    _syncProgress();
  }

  Future<void> _syncProgress() async {
    try {
      await _repository.syncProgress();
      print('✅ Progress synced on lesson controller init');
    } catch (e) {
      print('❌ Error syncing progress: $e');
    }
  }

  Future<void> _loadAdvancedMode() async {
    final mode = await _repository.getAdvancedMode();
    _advancedMode.value = mode;
  }

  Future<void> toggleAdvancedMode() async {
    _advancedMode.value = !_advancedMode.value;
    await _repository.setAdvancedMode(_advancedMode.value);

    // Track advanced mode achievement
    if (_advancedMode.value) {
      final achievementController = Get.find<AchievementController>();
      await achievementController.onAdvancedModeEnabled();
    }

    Get.snackbar(
      _advancedMode.value
          ? '🚀 Advanced Mode Enabled'
          : '📚 Normal Mode Enabled',
      _advancedMode.value
          ? 'All lessons are now unlocked! You can access any lesson.'
          : 'Prerequisites are now required to access lessons.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: _advancedMode.value ? Colors.purple : Colors.blue,
      colorText: Colors.white,
    );
  }

  Future<void> loadLessonsByStage(String stageId) async {
    try {
      _isLoading.value = true;
      _currentStageId.value = stageId;

      final lessons = await _repository.getLessonsByStage(stageId);
      _lessons.value = lessons;

      await _loadCompletionStatus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load lessons: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCompletionStatus() async {
    final status = await _repository.getCompletionStatus();
    _completionStatus.value = status;
  }

  Future<void> toggleLessonCompletion(String lessonId) async {
    final isCompleted = _completionStatus[lessonId] ?? false;

    if (!isCompleted) {
      await _repository.markLessonCompleted(lessonId);
      _completionStatus[lessonId] = true;

      // Track lesson completion achievement
      final achievementController = Get.find<AchievementController>();
      await achievementController.onLessonCompleted();

      Get.snackbar(
        'Great Job! 🎉',
        'Lesson marked as completed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }

    // Refresh to trigger UI update
    _completionStatus.refresh();
  }

  bool isLessonCompleted(String lessonId) {
    return _completionStatus[lessonId] ?? false;
  }

  bool canAccessLesson(Lesson lesson) {
    // Advanced mode unlocks all lessons
    if (_advancedMode.value) return true;

    // Check if all prerequisites are completed
    if (lesson.prerequisites.isEmpty) return true;

    return lesson.prerequisites.every(
      (prereqId) => _completionStatus[prereqId] ?? false,
    );
  }

  Future<Lesson?> getLessonById(String lessonId) async {
    return await _repository.getLessonById(lessonId);
  }

  Future<double> getStageCompletionPercentage(String stageId) async {
    return await _repository.getStageCompletionPercentage(stageId);
  }
}
