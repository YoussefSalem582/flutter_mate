import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_mate/features/analytics/data/models/study_session.dart';
import 'package:flutter_mate/features/analytics/data/models/time_analytics.dart';

/// Service for tracking study time and managing analytics data
///
/// Responsibilities:
/// - Start/stop study sessions
/// - Save session data locally (Hive) and to Firestore
/// - Calculate analytics from session data
/// - Track streaks and consistency
/// - Works offline-first with optional cloud sync
class TimeTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Hive box for local storage
  Box get _box => Hive.box('quiz'); // Reuse quiz box

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

    // Save to local storage first (always succeeds, works offline)
    try {
      final sessionData =
          session.toMap(forFirestore: false); // Use ISO strings for Hive
      final sessionKey = 'session_${session.id}';
      await _box.put(sessionKey, sessionData);
    } catch (e) {
      print('Error saving session to local storage: $e');
    }

    // Try to save to Firestore (requires internet and auth)
    try {
      await _firestore
          .collection('study_sessions')
          .doc(session.id)
          .set(session.toMap(forFirestore: true)); // Explicit Timestamp format
    } catch (e) {
      print('Error syncing session to Firestore: $e');
      // Continue anyway - local storage succeeded
    }

      _currentSession = null;
      return session;
  }

  /// Get current active session
  StudySession? getCurrentSession() => _currentSession;

  /// Get all sessions for a user (from Hive cache first, then Firestore)
  Future<List<StudySession>> getUserSessions(String userId) async {
    List<StudySession> sessions = [];

    // First, load from local cache (fast, works offline)
    try {
      final allKeys =
          _box.keys.where((key) => key.toString().startsWith('session_'));

      for (final key in allKeys) {
        final data = _box.get(key);
        if (data is Map) {
          try {
            final session =
                StudySession.fromMap(Map<String, dynamic>.from(data));
            if (session.userId == userId) {
              sessions.add(session);
            }
          } catch (e) {
            print('Error parsing cached session: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading cached sessions: $e');
    }

    // Then, try to sync with Firestore (online only)
    try {
      final snapshot = await _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      final firestoreSessions =
          snapshot.docs.map((doc) => StudySession.fromFirestore(doc)).toList();

      // Merge: prefer Firestore data, add local-only sessions
      final sessionIds = firestoreSessions.map((s) => s.id).toSet();
      final localOnlySessions =
          sessions.where((s) => !sessionIds.contains(s.id)).toList();

      sessions = [...firestoreSessions, ...localOnlySessions];

      // Cache Firestore sessions locally
      for (final session in firestoreSessions) {
        final sessionKey = 'session_${session.id}';
        await _box.put(sessionKey, session.toMap(forFirestore: false));
      }
    } catch (e) {
      print('Error syncing with Firestore (using cached data): $e');
      // Continue with cached sessions
    }

    // Sort by date (most recent first)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
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
