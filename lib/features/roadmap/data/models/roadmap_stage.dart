import 'package:flutter/material.dart';

/// Roadmap stage definition containing learning milestones.
class RoadmapStage {
  const RoadmapStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.topics,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> topics;

  RoadmapStage copyWith({List<String>? topics}) {
    return RoadmapStage(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      topics: topics ?? this.topics,
    );
  }
}
