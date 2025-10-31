import 'package:get/get.dart';
import 'package:flutter_mate/features/analytics/data/models/study_session.dart';
import 'package:flutter_mate/features/analytics/data/models/time_analytics.dart';
import 'package:flutter_mate/features/analytics/data/models/productivity_metrics.dart';
import 'package:flutter_mate/features/analytics/data/services/analytics_service.dart';
import 'package:flutter_mate/features/analytics/data/services/time_tracker_service.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';

/// Controller for managing analytics data and study time tracking
///
/// Features:
/// - Automatic study session tracking
/// - Real-time analytics updates
/// - Weekly/monthly report generation
/// - Personalized insights
/// - Performance metrics
class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();
  final TimeTrackerService _timeTrackerService = TimeTrackerService();

  // Observable analytics data
  final Rx<TimeAnalytics?> timeAnalytics = Rx<TimeAnalytics?>(null);
  final Rx<ProductivityMetrics?> productivityMetrics =
      Rx<ProductivityMetrics?>(null);
  final RxList<StudySession> recentSessions = <StudySession>[].obs;
  final RxList<String> personalizedInsights = <String>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<StudySession?> currentSession = Rx<StudySession?>(null);

  // Weekly/Monthly reports
  final RxMap<String, dynamic> weeklyReport = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> monthlyReport = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  /// Load all analytics data for current user
  Future<void> loadAnalytics() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      // Analytics requires authentication (not available for guests)
      if (userId == null || authController.isGuest) {
        isLoading.value = false;
        timeAnalytics.value = null;
        productivityMetrics.value = null;
        recentSessions.clear();
        personalizedInsights.clear();
        return;
      }

      // Load time analytics
      final timeData = await _timeTrackerService.calculateTimeAnalytics(userId);
      timeAnalytics.value = timeData;

      // Load productivity metrics
      final productivityData =
          await _analyticsService.calculateProductivityMetrics(userId);
      productivityMetrics.value = productivityData;

      // Load recent sessions
      final sessions = await _timeTrackerService.getUserSessions(userId);
      recentSessions.value = sessions.take(10).toList();

      // Load personalized insights
      final insights = await _analyticsService.getPersonalizedInsights(userId);
      personalizedInsights.value = insights;

      isLoading.value = false;
    } catch (e) {
      print('Error loading analytics: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Start tracking a study session
  void startStudySession({
    required String lessonId,
    required String lessonTitle,
    required String category,
  }) {
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    if (userId == null) return;

    final session = _timeTrackerService.startSession(
      userId: userId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      category: category,
    );

    currentSession.value = session;
  }

  /// Add an activity to the current session
  void addSessionActivity(String activity) {
    _timeTrackerService.addActivity(activity);
  }

  /// End the current study session
  Future<void> endStudySession({bool completed = true}) async {
    try {
      final session = await _timeTrackerService.endSession(
        completed: completed,
      );

      if (session != null) {
        // Add to recent sessions
        recentSessions.insert(0, session);
        if (recentSessions.length > 10) {
          recentSessions.removeLast();
        }

        // Refresh analytics
        await loadAnalytics();
      }

      currentSession.value = null;
    } catch (e) {
      print('Error ending study session: $e');
    }
  }

  /// Generate weekly report
  Future<void> generateWeeklyReport() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final report = await _analyticsService.generateWeeklyReport(userId);
      weeklyReport.value = report;
      isLoading.value = false;
    } catch (e) {
      print('Error generating weekly report: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to generate weekly report',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Generate monthly report
  Future<void> generateMonthlyReport() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final report = await _analyticsService.generateMonthlyReport(userId);
      monthlyReport.value = report;
      isLoading.value = false;
    } catch (e) {
      print('Error generating monthly report: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to generate monthly report',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get current session info
  StudySession? getCurrentSession() {
    return currentSession.value ?? _timeTrackerService.getCurrentSession();
  }

  /// Check if currently tracking a session
  bool get isTracking => getCurrentSession() != null;

  /// Get today's study time
  String getTodayStudyTime() {
    if (timeAnalytics.value == null) return '0 min';
    final duration = timeAnalytics.value!.getTodayStudyTime();
    return _formatDuration(duration);
  }

  /// Get this week's study time
  String getWeekStudyTime() {
    if (timeAnalytics.value == null) return '0 min';
    final duration = timeAnalytics.value!.getWeekStudyTime();
    return _formatDuration(duration);
  }

  /// Get this month's study time
  String getMonthStudyTime() {
    if (timeAnalytics.value == null) return '0 min';
    final duration = timeAnalytics.value!.getMonthStudyTime();
    return _formatDuration(duration);
  }

  /// Get total study time
  String getTotalStudyTime() {
    if (timeAnalytics.value == null) return '0 min';
    return _formatDuration(timeAnalytics.value!.totalStudyTime);
  }

  /// Get current streak
  int getCurrentStreak() {
    return timeAnalytics.value?.currentStreak ?? 0;
  }

  /// Get longest streak
  int getLongestStreak() {
    return timeAnalytics.value?.longestStreak ?? 0;
  }

  /// Get focus score
  double getFocusScore() {
    return productivityMetrics.value?.focusScore ?? 0.0;
  }

  /// Get completion rate
  double getCompletionRate() {
    return productivityMetrics.value?.completionRate ?? 0.0;
  }

  /// Get average quiz score
  double getAverageQuizScore() {
    return productivityMetrics.value?.averageQuizScore ?? 0.0;
  }

  /// Get sessions per week
  int getSessionsPerWeek() {
    return productivityMetrics.value?.sessionsPerWeek ?? 0;
  }

  /// Get productivity level description
  String getProductivityLevel() {
    return productivityMetrics.value?.productivityLevel ?? 'Inactive';
  }

  /// Get focus level description
  String getFocusLevel() {
    return productivityMetrics.value?.focusLevel ?? 'N/A';
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Refresh all analytics
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
}
