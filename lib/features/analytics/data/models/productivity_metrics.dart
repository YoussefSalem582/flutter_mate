/// Productivity and efficiency metrics for learning performance
///
/// Measures:
/// - Focus score (session completion rate)
/// - Completion rate (lessons completed)
/// - Session frequency
/// - Optimal study patterns
/// - Peak productivity times
/// - Progress by category
class ProductivityMetrics {
  final double focusScore; // 0-100
  final double completionRate; // 0-100 percentage
  final int sessionsPerWeek;
  final Duration optimalStudyDuration;
  final List<String> peakProductivityHours;
  final Map<String, double> categoryProgress; // category -> progress percentage
  final double averageQuizScore; // 0-100
  final int totalLessonsCompleted;
  final int totalLessonsStarted;
  final DateTime? lastActiveDate;

  ProductivityMetrics({
    required this.focusScore,
    required this.completionRate,
    required this.sessionsPerWeek,
    required this.optimalStudyDuration,
    required this.peakProductivityHours,
    required this.categoryProgress,
    this.averageQuizScore = 0.0,
    this.totalLessonsCompleted = 0,
    this.totalLessonsStarted = 0,
    this.lastActiveDate,
  });

  /// Get focus level description
  String get focusLevel {
    if (focusScore >= 90) return 'Excellent';
    if (focusScore >= 70) return 'Good';
    if (focusScore >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  /// Get productivity level
  String get productivityLevel {
    if (sessionsPerWeek >= 7) return 'Very High';
    if (sessionsPerWeek >= 5) return 'High';
    if (sessionsPerWeek >= 3) return 'Moderate';
    if (sessionsPerWeek >= 1) return 'Low';
    return 'Inactive';
  }

  /// Get completion efficiency
  double get completionEfficiency {
    if (totalLessonsStarted == 0) return 0.0;
    return (totalLessonsCompleted / totalLessonsStarted) * 100;
  }

  /// Check if optimal study time
  bool isOptimalStudyTime(DateTime time) {
    final hour = time.hour;
    return peakProductivityHours.contains('${hour}:00');
  }

  /// Get recommended study duration in minutes
  int get recommendedStudyMinutes => optimalStudyDuration.inMinutes;

  /// Get weakest category
  String? getWeakestCategory() {
    if (categoryProgress.isEmpty) return null;

    String weakest = categoryProgress.keys.first;
    double minProgress = categoryProgress.values.first;

    categoryProgress.forEach((category, progress) {
      if (progress < minProgress) {
        minProgress = progress;
        weakest = category;
      }
    });

    return weakest;
  }

  /// Get strongest category
  String? getStrongestCategory() {
    if (categoryProgress.isEmpty) return null;

    String strongest = categoryProgress.keys.first;
    double maxProgress = categoryProgress.values.first;

    categoryProgress.forEach((category, progress) {
      if (progress > maxProgress) {
        maxProgress = progress;
        strongest = category;
      }
    });

    return strongest;
  }

  /// Get overall progress percentage
  double get overallProgress {
    if (categoryProgress.isEmpty) return 0.0;

    double total = 0;
    categoryProgress.values.forEach((progress) {
      total += progress;
    });

    return total / categoryProgress.length;
  }

  /// Check if user is on track (studying regularly)
  bool get isOnTrack {
    if (lastActiveDate == null) return false;

    final daysSinceActive = DateTime.now().difference(lastActiveDate!).inDays;
    return daysSinceActive <= 2; // Active within last 2 days
  }

  /// Get productivity trend
  String getTrendDescription() {
    if (focusScore >= 80 && sessionsPerWeek >= 5) {
      return 'You\'re on fire! 🔥';
    } else if (focusScore >= 60 && sessionsPerWeek >= 3) {
      return 'Great progress! 📈';
    } else if (focusScore >= 40 || sessionsPerWeek >= 2) {
      return 'Keep it up! 💪';
    } else {
      return 'Let\'s get back on track! 🎯';
    }
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'focusScore': focusScore,
      'completionRate': completionRate,
      'sessionsPerWeek': sessionsPerWeek,
      'optimalStudyDurationSeconds': optimalStudyDuration.inSeconds,
      'peakProductivityHours': peakProductivityHours,
      'categoryProgress': categoryProgress,
      'averageQuizScore': averageQuizScore,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalLessonsStarted': totalLessonsStarted,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }

  /// Create from map
  factory ProductivityMetrics.fromMap(Map<String, dynamic> map) {
    return ProductivityMetrics(
      focusScore: (map['focusScore'] ?? 0.0).toDouble(),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      sessionsPerWeek: map['sessionsPerWeek'] ?? 0,
      optimalStudyDuration: Duration(
        seconds: map['optimalStudyDurationSeconds'] ?? 1800, // Default 30 min
      ),
      peakProductivityHours:
          List<String>.from(map['peakProductivityHours'] ?? []),
      categoryProgress: Map<String, double>.from(
        (map['categoryProgress'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      averageQuizScore: (map['averageQuizScore'] ?? 0.0).toDouble(),
      totalLessonsCompleted: map['totalLessonsCompleted'] ?? 0,
      totalLessonsStarted: map['totalLessonsStarted'] ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.parse(map['lastActiveDate'])
          : null,
    );
  }

  /// Create empty metrics
  factory ProductivityMetrics.empty() {
    return ProductivityMetrics(
      focusScore: 0.0,
      completionRate: 0.0,
      sessionsPerWeek: 0,
      optimalStudyDuration: const Duration(minutes: 30),
      peakProductivityHours: [],
      categoryProgress: {},
    );
  }

  /// Copy with modifications
  ProductivityMetrics copyWith({
    double? focusScore,
    double? completionRate,
    int? sessionsPerWeek,
    Duration? optimalStudyDuration,
    List<String>? peakProductivityHours,
    Map<String, double>? categoryProgress,
    double? averageQuizScore,
    int? totalLessonsCompleted,
    int? totalLessonsStarted,
    DateTime? lastActiveDate,
  }) {
    return ProductivityMetrics(
      focusScore: focusScore ?? this.focusScore,
      completionRate: completionRate ?? this.completionRate,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      optimalStudyDuration: optimalStudyDuration ?? this.optimalStudyDuration,
      peakProductivityHours:
          peakProductivityHours ?? this.peakProductivityHours,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalLessonsStarted: totalLessonsStarted ?? this.totalLessonsStarted,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
