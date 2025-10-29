import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/lesson.dart';
import './lesson_controller.dart';
import '../../analytics/controller/analytics_controller.dart';

/// Controller for managing persistent study timers across app sessions.
///
/// Features:
/// - Persistent timer storage (continues counting even when app is closed)
/// - Per-lesson timer tracking
/// - Auto-save timer state
/// - Calculate elapsed time based on start timestamp
/// - Auto-complete lesson and navigate to next when timer finishes
class StudyTimerController extends GetxController {
  static const String _boxName = 'study_timer';
  static const String _prefixKey = 'timer_';
  static const String _startTimeSuffix = '_start';
  static const String _elapsedSuffix = '_elapsed';
  static const String _isRunningSuffix = '_running';

  /// Get Hive box
  Box get _box => Hive.box(_boxName);

  // Current lesson being studied
  final RxString currentLessonId = ''.obs;

  // Timer state
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isRunning = false.obs;
  final RxInt targetDuration = 0.obs; // Target duration in seconds

  DateTime? _startTime;
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    // Hive box should already be initialized in main.dart
  }

  /// Start timer for a specific lesson
  Future<void> startTimer(String lessonId, {int? durationMinutes}) async {
    currentLessonId.value = lessonId;

    // Set target duration if provided
    if (durationMinutes != null) {
      targetDuration.value = durationMinutes * 60;
    }

    // Load existing elapsed time
    final savedElapsed =
        _box.get('$_prefixKey$lessonId$_elapsedSuffix', defaultValue: 0) as int;
    elapsedSeconds.value = savedElapsed;

    // Check if timer was already running
    final wasRunning = _box.get('$_prefixKey$lessonId$_isRunningSuffix',
        defaultValue: false) as bool;

    if (wasRunning) {
      // Calculate additional elapsed time since app was closed
      final savedStartTime =
          _box.get('$_prefixKey$lessonId$_startTimeSuffix') as int?;
      if (savedStartTime != null) {
        final startDateTime =
            DateTime.fromMillisecondsSinceEpoch(savedStartTime);
        final now = DateTime.now();
        final additionalSeconds = now.difference(startDateTime).inSeconds;
        elapsedSeconds.value = savedElapsed + additionalSeconds;
      }
    }

    // Start new timer session
    _startTime = DateTime.now();
    isRunning.value = true;

    await _saveTimerState(lessonId);
    _startPeriodicUpdate();

    // Start analytics tracking
    try {
      final analyticsController = Get.find<AnalyticsController>();
      final lessonController = Get.find<LessonController>();
      final lesson = await lessonController.getLessonById(lessonId);

      if (lesson != null) {
        analyticsController.startStudySession(
          lessonId: lessonId,
          lessonTitle: lesson.title,
          category: lesson.difficulty,
        );
      }
    } catch (e) {
      print('Analytics not available: $e');
    }
  }

  /// Toggle timer play/pause
  Future<void> toggleTimer() async {
    if (currentLessonId.value.isEmpty) return;

    if (isRunning.value) {
      // Pause: save current elapsed time
      _pauseTimer();
    } else {
      // Resume: start from current elapsed time
      _resumeTimer();
    }

    await _saveTimerState(currentLessonId.value);
  }

  void _pauseTimer() {
    if (_startTime != null) {
      final now = DateTime.now();
      final sessionSeconds = now.difference(_startTime!).inSeconds;
      elapsedSeconds.value += sessionSeconds;
    }

    isRunning.value = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _startTime = null;

    // End analytics session when pausing
    try {
      final analyticsController = Get.find<AnalyticsController>();
      analyticsController.endStudySession(completed: false);
    } catch (e) {
      print('Analytics not available: $e');
    }
  }

  void _resumeTimer() {
    _startTime = DateTime.now();
    isRunning.value = true;
    _startPeriodicUpdate();
  }

  /// Reset timer to zero
  Future<void> resetTimer() async {
    if (currentLessonId.value.isEmpty) return;

    elapsedSeconds.value = 0;
    _startTime = DateTime.now();
    isRunning.value = true;

    await _saveTimerState(currentLessonId.value);
    _startPeriodicUpdate();
  }

  /// Start periodic timer update (every second)
  void _startPeriodicUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isRunning.value && _startTime != null) {
        final now = DateTime.now();
        final sessionSeconds = now.difference(_startTime!).inSeconds;

        // Update displayed time but don't save yet (save happens on pause/background)
        final baseElapsed = _box.get(
          '$_prefixKey${currentLessonId.value}$_elapsedSuffix',
          defaultValue: 0,
        ) as int;
        elapsedSeconds.value = baseElapsed + sessionSeconds;

        // Check if target duration reached
        if (targetDuration.value > 0 &&
            elapsedSeconds.value >= targetDuration.value) {
          _onTimerComplete();
        }
      }
    });
  }

  /// Handle timer completion - pause, award XP, and navigate to next lesson
  Future<void> _onTimerComplete() async {
    // Pause the timer
    _pauseTimer();
    await _saveTimerState(currentLessonId.value);

    // End analytics session as completed
    try {
      final analyticsController = Get.find<AnalyticsController>();
      analyticsController.endStudySession(completed: true);
    } catch (e) {
      print('Analytics not available: $e');
    }

    // Mark lesson as completed
    try {
      final lessonController = Get.find<LessonController>();
      final currentLesson =
          await lessonController.getLessonById(currentLessonId.value);

      if (currentLesson != null &&
          !lessonController.isLessonCompleted(currentLessonId.value)) {
        // Mark as complete (this will award XP)
        await lessonController.toggleLessonCompletion(currentLessonId.value);

        // Show completion dialog
        Get.dialog(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber, size: 32),
                SizedBox(width: 12),
                Text('Lesson Complete! 🎉'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Great job! You\'ve completed this lesson.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '+25 XP Earned!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to lessons list
                },
                child: const Text('Back to Lessons'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Get.back(); // Close dialog
                  await _navigateToNextLesson(lessonController, currentLesson);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next Lesson'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      // If lesson controller not found, just show simple message
      Get.snackbar(
        'Timer Complete! ⏱️',
        'You\'ve finished the study duration for this lesson.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Navigate to the next lesson in the sequence
  Future<void> _navigateToNextLesson(
      LessonController lessonController, Lesson currentLesson) async {
    try {
      // Get all lessons for the current stage
      await lessonController.loadLessonsByStage(currentLesson.stageId);
      final stageLessons = lessonController.lessons;

      // Sort by order
      final sortedLessons = List<Lesson>.from(stageLessons);
      sortedLessons.sort((a, b) => a.order.compareTo(b.order));

      // Find next lesson
      final currentIndex =
          sortedLessons.indexWhere((l) => l.id == currentLesson.id);
      if (currentIndex != -1 && currentIndex < sortedLessons.length - 1) {
        final nextLesson = sortedLessons[currentIndex + 1];

        // Check if next lesson is accessible
        if (lessonController.canAccessLesson(nextLesson)) {
          Get.back(); // Go back from current lesson
          // Navigate to next lesson
          await Future.delayed(const Duration(milliseconds: 300));
          Get.toNamed('/lesson-detail', arguments: nextLesson);
        } else {
          Get.back(); // Just go back to lessons list
          Get.snackbar(
            'Next Lesson Locked 🔒',
            'Complete the prerequisites first.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // No next lesson (stage complete)
        Get.back(); // Go back to lessons list
        Get.snackbar(
          'Stage Complete! 🎊',
          'You\'ve finished all lessons in this stage!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Go back to lessons list on error
      Get.snackbar(
        'Error',
        'Could not load next lesson.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save timer state to persistent storage
  Future<void> _saveTimerState(String lessonId) async {
    if (isRunning.value && _startTime != null) {
      // Save start time for calculating elapsed time when app reopens
      await _box.put(
        '$_prefixKey$lessonId$_startTimeSuffix',
        _startTime!.millisecondsSinceEpoch,
      );
      await _box.put('$_prefixKey$lessonId$_isRunningSuffix', true);

      // Save base elapsed time (before current session)
      final now = DateTime.now();
      final sessionSeconds = now.difference(_startTime!).inSeconds;
      final baseElapsed = elapsedSeconds.value - sessionSeconds;
      await _box.put('$_prefixKey$lessonId$_elapsedSuffix', baseElapsed);
    } else {
      // Timer is paused, save total elapsed time
      await _box.put(
        '$_prefixKey$lessonId$_elapsedSuffix',
        elapsedSeconds.value,
      );
      await _box.put('$_prefixKey$lessonId$_isRunningSuffix', false);
      await _box.delete('$_prefixKey$lessonId$_startTimeSuffix');
    }
  }

  /// Get total study time for a lesson (in seconds)
  Future<int> getTotalStudyTime(String lessonId) async {
    return _box.get('$_prefixKey$lessonId$_elapsedSuffix', defaultValue: 0)
        as int;
  }

  /// Format seconds to readable time string
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  @override
  void onClose() {
    // Save state before closing
    if (currentLessonId.value.isNotEmpty) {
      _saveTimerState(currentLessonId.value);

      // End analytics session if still tracking
      try {
        final analyticsController = Get.find<AnalyticsController>();
        if (analyticsController.isTracking) {
          analyticsController.endStudySession(completed: false);
        }
      } catch (e) {
        print('Analytics not available: $e');
      }
    }
    _updateTimer?.cancel();
    super.onClose();
  }
}
