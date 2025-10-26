/// Individual lesson within a roadmap stage
class Lesson {
  const Lesson({
    required this.id,
    required this.stageId,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.order,
    this.prerequisites = const [],
    this.resources = const {},
  });

  final String id;
  final String stageId;
  final String title;
  final String description;
  final int duration; // in minutes
  final String difficulty; // 'easy', 'medium', 'hard'
  final int order;
  final List<String> prerequisites;
  final Map<String, String> resources; // title -> URL

  Lesson copyWith({
    String? id,
    String? stageId,
    String? title,
    String? description,
    int? duration,
    String? difficulty,
    int? order,
    List<String>? prerequisites,
    Map<String, String>? resources,
  }) {
    return Lesson(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      order: order ?? this.order,
      prerequisites: prerequisites ?? this.prerequisites,
      resources: resources ?? this.resources,
    );
  }
}
