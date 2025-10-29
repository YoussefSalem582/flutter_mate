import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mate/features/analytics/data/models/study_session.dart';
import 'package:flutter_mate/features/analytics/data/models/productivity_metrics.dart';
import 'package:flutter_mate/features/analytics/data/services/time_tracker_service.dart';

/// Service for comprehensive analytics calculations and data management
///
/// Responsibilities:
/// - Calculate productivity metrics
/// - Generate analytics reports
/// - Track quiz performance
/// - Monitor learning progress
/// - Provide insights and recommendations
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TimeTrackerService _timeTracker = TimeTrackerService();

  /// Calculate comprehensive productivity metrics for a user
  Future<ProductivityMetrics> calculateProductivityMetrics(
    String userId,
  ) async {
    try {
      // Get all sessions
      final sessions = await _timeTracker.getUserSessions(userId);

      if (sessions.isEmpty) {
        return ProductivityMetrics.empty();
      }

      // Calculate focus score (completed sessions / total sessions)
      final completedSessions = sessions.where((s) => s.completed).length;
      final focusScore = (completedSessions / sessions.length) * 100;

      // Get user progress data
      final progressDoc =
          await _firestore.collection('user_progress').doc(userId).get();

      final progressData = progressDoc.data() ?? {};
      final completedLessons =
          List<String>.from(progressData['completedLessons'] ?? []);
      final startedLessons =
          List<String>.from(progressData['startedLessons'] ?? []);

      // Calculate completion rate
      final completionRate = startedLessons.isNotEmpty
          ? (completedLessons.length / startedLessons.length) * 100
          : 0.0;

      // Calculate sessions per week (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentSessions = sessions
          .where(
            (s) => s.startTime.isAfter(weekAgo),
          )
          .length;

      // Calculate optimal study duration (average of completed sessions)
      final completedSessionsDurations =
          sessions.where((s) => s.completed).map((s) => s.duration).toList();

      final optimalDuration = completedSessionsDurations.isNotEmpty
          ? Duration(
              seconds: completedSessionsDurations
                      .map((d) => d.inSeconds)
                      .reduce((a, b) => a + b) ~/
                  completedSessionsDurations.length,
            )
          : const Duration(minutes: 30);

      // Calculate peak productivity hours
      final hourlyPerformance = <int, int>{};
      for (var session in sessions.where((s) => s.completed)) {
        final hour = session.startTime.hour;
        hourlyPerformance[hour] = (hourlyPerformance[hour] ?? 0) + 1;
      }

      final sortedHours = hourlyPerformance.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final peakHours = sortedHours.take(3).map((e) => '${e.key}:00').toList();

      // Calculate category progress
      final categoryProgress = <String, double>{};
      final categoryData = progressData['categoryProgress'] as Map? ?? {};
      categoryData.forEach((key, value) {
        if (value is num) {
          categoryProgress[key.toString()] = value.toDouble();
        }
      });

      // Get quiz data for average score
      final quizSnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .get();

      double averageQuizScore = 0.0;
      if (quizSnapshot.docs.isNotEmpty) {
        final scores = quizSnapshot.docs
            .map((doc) => (doc.data()['score'] as num?)?.toDouble() ?? 0.0)
            .toList();
        averageQuizScore = scores.reduce((a, b) => a + b) / scores.length;
      }

      return ProductivityMetrics(
        focusScore: focusScore,
        completionRate: completionRate,
        sessionsPerWeek: recentSessions,
        optimalStudyDuration: optimalDuration,
        peakProductivityHours: peakHours,
        categoryProgress: categoryProgress,
        averageQuizScore: averageQuizScore,
        totalLessonsCompleted: completedLessons.length,
        totalLessonsStarted: startedLessons.length,
        lastActiveDate: sessions.first.startTime,
      );
    } catch (e) {
      print('Error calculating productivity metrics: $e');
      return ProductivityMetrics.empty();
    }
  }

  /// Get comprehensive analytics for a user
  Future<Map<String, dynamic>> getComprehensiveAnalytics(
    String userId,
  ) async {
    final timeAnalytics = await _timeTracker.calculateTimeAnalytics(userId);
    final productivityMetrics = await calculateProductivityMetrics(userId);

    return {
      'timeAnalytics': timeAnalytics.toMap(),
      'productivityMetrics': productivityMetrics.toMap(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Get analytics for a specific time period
  Future<Map<String, dynamic>> getAnalyticsForPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await _timeTracker.getSessionsInRange(
      userId,
      startDate,
      endDate,
    );

    if (sessions.isEmpty) {
      return {
        'totalStudyTime': 0,
        'sessionCount': 0,
        'averageScore': 0.0,
        'completionRate': 0.0,
      };
    }

    // Calculate total study time
    final totalTime = sessions.map((s) => s.duration).reduce((a, b) => a + b);

    // Calculate completion rate
    final completed = sessions.where((s) => s.completed).length;
    final completionRate = (completed / sessions.length) * 100;

    // Get quiz results for period
    final quizSnapshot = await _firestore
        .collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double averageScore = 0.0;
    if (quizSnapshot.docs.isNotEmpty) {
      final scores = quizSnapshot.docs
          .map((doc) => (doc.data()['score'] as num?)?.toDouble() ?? 0.0)
          .toList();
      averageScore = scores.reduce((a, b) => a + b) / scores.length;
    }

    return {
      'totalStudyTime': totalTime.inMinutes,
      'sessionCount': sessions.length,
      'averageScore': averageScore,
      'completionRate': completionRate,
      'topCategory': _getMostStudiedCategory(sessions),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  /// Generate weekly report
  Future<Map<String, dynamic>> generateWeeklyReport(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekData = await getAnalyticsForPeriod(
      userId,
      weekStart,
      weekEnd,
    );

    // Get previous week for comparison
    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekEnd = weekStart.subtract(const Duration(days: 1));

    final prevWeekData = await getAnalyticsForPeriod(
      userId,
      prevWeekStart,
      prevWeekEnd,
    );

    // Calculate improvements
    final timeImprovement =
        weekData['totalStudyTime'] - prevWeekData['totalStudyTime'];
    final scoreImprovement =
        weekData['averageScore'] - prevWeekData['averageScore'];

    return {
      'weekData': weekData,
      'previousWeekData': prevWeekData,
      'improvements': {
        'studyTime': timeImprovement,
        'averageScore': scoreImprovement,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Generate monthly report
  Future<Map<String, dynamic>> generateMonthlyReport(String userId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthData = await getAnalyticsForPeriod(
      userId,
      monthStart,
      monthEnd,
    );

    // Get previous month for comparison
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prevMonthEnd = DateTime(now.year, now.month, 0);

    final prevMonthData = await getAnalyticsForPeriod(
      userId,
      prevMonthStart,
      prevMonthEnd,
    );

    return {
      'monthData': monthData,
      'previousMonthData': prevMonthData,
      'monthName': _getMonthName(now.month),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get personalized insights and recommendations
  Future<List<String>> getPersonalizedInsights(String userId) async {
    final insights = <String>[];

    final timeAnalytics = await _timeTracker.calculateTimeAnalytics(userId);
    final productivity = await calculateProductivityMetrics(userId);

    // Streak insights
    if (timeAnalytics.currentStreak >= 7) {
      insights.add(
        '🔥 Amazing! You\'re on a ${timeAnalytics.currentStreak}-day streak!',
      );
    } else if (timeAnalytics.currentStreak == 0) {
      insights.add(
        '💪 Start a new streak today! Consistency is key to mastery.',
      );
    }

    // Study time insights
    final todayTime = timeAnalytics.getTodayStudyTime();
    if (todayTime.inMinutes < 15 && !timeAnalytics.studiedToday) {
      insights.add(
        '⏰ You haven\'t studied today. Even 15 minutes can make a difference!',
      );
    }

    // Peak productivity insights
    final peakHour = timeAnalytics.getMostProductiveHour();
    insights.add(
      '🌟 You\'re most productive around $peakHour:00. Try scheduling study sessions then!',
    );

    // Category insights
    final weakCategory = productivity.getWeakestCategory();
    if (weakCategory != null) {
      insights.add(
        '📚 Consider focusing more on $weakCategory to balance your learning.',
      );
    }

    // Focus insights
    if (productivity.focusScore < 50) {
      insights.add(
        '🎯 Try shorter study sessions to improve focus and completion rate.',
      );
    }

    // Quiz performance
    if (productivity.averageQuizScore < 70) {
      insights.add(
        '📝 Your quiz scores suggest reviewing lesson materials before taking quizzes.',
      );
    } else if (productivity.averageQuizScore >= 90) {
      insights.add(
        '🎯 Excellent quiz performance! You\'re mastering the material.',
      );
    }

    // Assessment completion
    try {
      final assessmentSnapshot = await _firestore
          .collection('skill_assessments')
          .where('userId', isEqualTo: userId)
          .get();

      if (assessmentSnapshot.docs.isEmpty) {
        insights.add(
          '🎓 Take a skill assessment to discover your strengths and areas for improvement!',
        );
      } else if (assessmentSnapshot.docs.length == 1) {
        insights.add(
          '📊 Your skills are being tracked! Regular assessments help measure your progress.',
        );
      }
    } catch (e) {
      print('Error getting assessment insights: $e');
    }

    return insights;
  }

  /// Helper: Get most studied category from sessions
  String _getMostStudiedCategory(List<StudySession> sessions) {
    if (sessions.isEmpty) return 'None';

    final categoryTime = <String, int>{};
    for (var session in sessions) {
      categoryTime[session.category] =
          (categoryTime[session.category] ?? 0) + session.durationInMinutes;
    }

    final sorted = categoryTime.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  /// Helper: Get month name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
