import 'package:flutter/material.dart';

/// Roadmap stage definition containing learning milestones.
class RoadmapStage {
  const RoadmapStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.colorHex,
    required this.topics,
  });

  final String id;
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int colorHex;
  final List<String> topics;

  /// Helper to material icon reference.
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Helper to color value.
  Color get color => Color(colorHex);

  RoadmapStage copyWith({List<String>? topics}) {
    return RoadmapStage(
      id: id,
      title: title,
      subtitle: subtitle,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
      topics: topics ?? this.topics,
    );
  }
}
