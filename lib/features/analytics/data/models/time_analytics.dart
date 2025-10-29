/// Comprehensive time-based analytics for user study patterns
///
/// Tracks:
/// - Total study time across different periods
/// - Average session durations
/// - Time spent per category/topic
/// - Daily/weekly study patterns
/// - Study streaks and consistency
/// - Peak study hours
class TimeAnalytics {
  final Duration totalStudyTime;
  final Duration averageSessionDuration;
  final Map<String, Duration> timePerCategory;
  final Map<DateTime, Duration> dailyStudyTime;
  final int currentStreak;
  final int longestStreak;
  final List<int> studyHoursDistribution; // 24-hour array
  final List<int> studyDaysDistribution; // 7-day array (Mon-Sun)
  final DateTime? lastStudyDate;
  final int totalSessions;

  TimeAnalytics({
    required this.totalStudyTime,
    required this.averageSessionDuration,
    required this.timePerCategory,
    required this.dailyStudyTime,
    required this.currentStreak,
    required this.longestStreak,
    required this.studyHoursDistribution,
    required this.studyDaysDistribution,
    this.lastStudyDate,
    required this.totalSessions,
  });

  /// Get total study time in hours
  double get totalHours => totalStudyTime.inMinutes / 60.0;

  /// Get total study time in minutes
  int get totalMinutes => totalStudyTime.inMinutes;

  /// Get average session in minutes
  int get averageSessionMinutes => averageSessionDuration.inMinutes;

  /// Get study time for today
  Duration getTodayStudyTime() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    return dailyStudyTime[todayKey] ?? Duration.zero;
  }

  /// Get study time for this week
  Duration getWeekStudyTime() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    Duration total = Duration.zero;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      total += dailyStudyTime[dayKey] ?? Duration.zero;
    }
    return total;
  }

  /// Get study time for this month
  Duration getMonthStudyTime() {
    final now = DateTime.now();
    Duration total = Duration.zero;

    dailyStudyTime.forEach((date, duration) {
      if (date.year == now.year && date.month == now.month) {
        total += duration;
      }
    });

    return total;
  }

  /// Get most productive hour (0-23)
  int getMostProductiveHour() {
    if (studyHoursDistribution.isEmpty) return 0;

    int maxIndex = 0;
    int maxValue = studyHoursDistribution[0];

    for (int i = 1; i < studyHoursDistribution.length; i++) {
      if (studyHoursDistribution[i] > maxValue) {
        maxValue = studyHoursDistribution[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  /// Get most productive day (1=Monday, 7=Sunday)
  int getMostProductiveDay() {
    if (studyDaysDistribution.isEmpty) return 1;

    int maxIndex = 0;
    int maxValue = studyDaysDistribution[0];

    for (int i = 1; i < studyDaysDistribution.length; i++) {
      if (studyDaysDistribution[i] > maxValue) {
        maxValue = studyDaysDistribution[i];
        maxIndex = i;
      }
    }

    return maxIndex + 1; // 1-based
  }

  /// Get category with most study time
  String? getTopCategory() {
    if (timePerCategory.isEmpty) return null;

    String topCategory = timePerCategory.keys.first;
    Duration maxDuration = timePerCategory.values.first;

    timePerCategory.forEach((category, duration) {
      if (duration > maxDuration) {
        maxDuration = duration;
        topCategory = category;
      }
    });

    return topCategory;
  }

  /// Check if user studied today
  bool get studiedToday {
    if (lastStudyDate == null) return false;

    final today = DateTime.now();
    final lastStudy = lastStudyDate!;

    return today.year == lastStudy.year &&
        today.month == lastStudy.month &&
        today.day == lastStudy.day;
  }

  /// Get study consistency percentage (days studied / total days)
  double getConsistencyPercentage(int totalDays) {
    if (totalDays == 0) return 0.0;
    final daysStudied = dailyStudyTime.length;
    return (daysStudied / totalDays) * 100;
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'totalStudyTimeSeconds': totalStudyTime.inSeconds,
      'averageSessionDurationSeconds': averageSessionDuration.inSeconds,
      'timePerCategory': timePerCategory.map(
        (key, value) => MapEntry(key, value.inSeconds),
      ),
      'dailyStudyTime': dailyStudyTime.map(
        (key, value) => MapEntry(key.toIso8601String(), value.inSeconds),
      ),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'studyHoursDistribution': studyHoursDistribution,
      'studyDaysDistribution': studyDaysDistribution,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'totalSessions': totalSessions,
    };
  }

  /// Create from map
  factory TimeAnalytics.fromMap(Map<String, dynamic> map) {
    return TimeAnalytics(
      totalStudyTime: Duration(seconds: map['totalStudyTimeSeconds'] ?? 0),
      averageSessionDuration: Duration(
        seconds: map['averageSessionDurationSeconds'] ?? 0,
      ),
      timePerCategory: (map['timePerCategory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Duration(seconds: value as int)),
          ) ??
          {},
      dailyStudyTime: (map['dailyStudyTime'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              DateTime.parse(key),
              Duration(seconds: value as int),
            ),
          ) ??
          {},
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      studyHoursDistribution:
          List<int>.from(map['studyHoursDistribution'] ?? List.filled(24, 0)),
      studyDaysDistribution:
          List<int>.from(map['studyDaysDistribution'] ?? List.filled(7, 0)),
      lastStudyDate: map['lastStudyDate'] != null
          ? DateTime.parse(map['lastStudyDate'])
          : null,
      totalSessions: map['totalSessions'] ?? 0,
    );
  }

  /// Create empty analytics
  factory TimeAnalytics.empty() {
    return TimeAnalytics(
      totalStudyTime: Duration.zero,
      averageSessionDuration: Duration.zero,
      timePerCategory: {},
      dailyStudyTime: {},
      currentStreak: 0,
      longestStreak: 0,
      studyHoursDistribution: List.filled(24, 0),
      studyDaysDistribution: List.filled(7, 0),
      totalSessions: 0,
    );
  }
}
