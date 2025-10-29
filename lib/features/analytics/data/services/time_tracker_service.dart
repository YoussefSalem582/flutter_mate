import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mate/features/analytics/data/models/study_session.dart';
import 'package:flutter_mate/features/analytics/data/models/time_analytics.dart';

/// Service for tracking study time and managing analytics data
///
/// Responsibilities:
/// - Start/stop study sessions
/// - Save session data to Firestore
/// - Calculate analytics from session data
/// - Track streaks and consistency
class TimeTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Currently active study session
  StudySession? _currentSession;

  /// Start a new study session
  StudySession startSession({
    required String userId,
    required String lessonId,
    required String lessonTitle,
    required String category,
  }) {
    _currentSession = StudySession(
      id: _generateSessionId(),
      userId: userId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      category: category,
      startTime: DateTime.now(),
      endTime: DateTime.now(), // Will be updated on end
      completed: false,
      activities: ['started'],
    );

    return _currentSession!;
  }

  /// Add activity to current session
  void addActivity(String activity) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        activities: [..._currentSession!.activities, activity],
      );
    }
  }

  /// End the current study session
  Future<StudySession?> endSession({bool completed = true}) async {
    if (_currentSession == null) return null;

    final session = _currentSession!.copyWith(
      endTime: DateTime.now(),
      completed: completed,
    );

    // Save to Firestore
    try {
      await _firestore
          .collection('study_sessions')
          .doc(session.id)
          .set(session.toMap());

      _currentSession = null;
      return session;
    } catch (e) {
      print('Error saving study session: $e');
      return null;
    }
  }

  /// Get current active session
  StudySession? getCurrentSession() => _currentSession;

  /// Get all sessions for a user
  Future<List<StudySession>> getUserSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudySession.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching study sessions: $e');
      return [];
    }
  }

  /// Get sessions within a date range
  Future<List<StudySession>> getSessionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs
          .map((doc) => StudySession.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching sessions in range: $e');
      return [];
    }
  }

  /// Calculate time analytics from sessions
  Future<TimeAnalytics> calculateTimeAnalytics(String userId) async {
    final sessions = await getUserSessions(userId);

    if (sessions.isEmpty) {
      return TimeAnalytics.empty();
    }

    // Calculate total study time
    Duration totalTime = Duration.zero;
    for (var session in sessions) {
      totalTime += session.duration;
    }

    // Calculate average session duration
    final avgDuration = Duration(
      seconds: totalTime.inSeconds ~/ sessions.length,
    );

    // Calculate time per category
    final Map<String, Duration> timePerCategory = {};
    for (var session in sessions) {
      timePerCategory[session.category] =
          (timePerCategory[session.category] ?? Duration.zero) +
              session.duration;
    }

    // Calculate daily study time
    final Map<DateTime, Duration> dailyStudyTime = {};
    for (var session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      dailyStudyTime[date] =
          (dailyStudyTime[date] ?? Duration.zero) + session.duration;
    }

    // Calculate study hours distribution (0-23)
    final List<int> hoursDistribution = List.filled(24, 0);
    for (var session in sessions) {
      hoursDistribution[session.startTime.hour] += session.durationInMinutes;
    }

    // Calculate study days distribution (Mon-Sun)
    final List<int> daysDistribution = List.filled(7, 0);
    for (var session in sessions) {
      final weekday = session.startTime.weekday - 1; // 0-based
      daysDistribution[weekday] += session.durationInMinutes;
    }

    // Calculate streaks
    final streaks = _calculateStreaks(dailyStudyTime.keys.toList());

    return TimeAnalytics(
      totalStudyTime: totalTime,
      averageSessionDuration: avgDuration,
      timePerCategory: timePerCategory,
      dailyStudyTime: dailyStudyTime,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      studyHoursDistribution: hoursDistribution,
      studyDaysDistribution: daysDistribution,
      lastStudyDate: sessions.first.startTime,
      totalSessions: sessions.length,
    );
  }

  /// Calculate current and longest streaks
  Map<String, int> _calculateStreaks(List<DateTime> studyDates) {
    if (studyDates.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Sort dates
    final sortedDates = studyDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    // Check if studied today or yesterday for current streak
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedYesterday =
        DateTime(yesterday.year, yesterday.month, yesterday.day);

    bool streakActive = false;
    if (sortedDates.first.isAtSameMomentAs(normalizedToday) ||
        sortedDates.first.isAtSameMomentAs(normalizedYesterday)) {
      streakActive = true;
      currentStreak = 1;
    }

    // Calculate streaks
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final current = sortedDates[i];
      final next = sortedDates[i + 1];
      final diff = current.difference(next).inDays;

      if (diff == 1) {
        tempStreak++;
        if (streakActive && i == 0 ||
            (i > 0 && sortedDates[i - 1].difference(current).inDays == 1)) {
          currentStreak++;
        }
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
        streakActive = false;
      }
    }

    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
