import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single study session with timing and activity tracking
///
/// A study session tracks:
/// - When the user started and ended studying
/// - Which lesson they were studying
/// - What activities they performed (reading, quiz, practice)
/// - Whether they completed the session
class StudySession {
  final String id;
  final String userId;
  final String lessonId;
  final String lessonTitle;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final bool completed;
  final List<String> activities;

  StudySession({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.lessonTitle,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.completed,
    this.activities = const [],
  });

  /// Calculate session duration
  Duration get duration => endTime.difference(startTime);

  /// Get duration in minutes
  int get durationInMinutes => duration.inMinutes;

  /// Get duration in seconds
  int get durationInSeconds => duration.inSeconds;

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'category': category,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'completed': completed,
      'activities': activities,
      'durationInSeconds': durationInSeconds,
    };
  }

  /// Create from Firestore document
  factory StudySession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudySession(
      id: doc.id,
      userId: data['userId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      lessonTitle: data['lessonTitle'] ?? '',
      category: data['category'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      completed: data['completed'] ?? false,
      activities: List<String>.from(data['activities'] ?? []),
    );
  }

  /// Create from map (for local storage)
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      lessonTitle: map['lessonTitle'] ?? '',
      category: map['category'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      completed: map['completed'] ?? false,
      activities: List<String>.from(map['activities'] ?? []),
    );
  }

  /// Copy with modifications
  StudySession copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? lessonTitle,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
    List<String>? activities,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      activities: activities ?? this.activities,
    );
  }
}
