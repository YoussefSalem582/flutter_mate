enum SkillLevel {
  beginner, // 0-30%
  elementary, // 31-50%
  intermediate, // 51-70%
  advanced, // 71-90%
  expert; // 91-100%

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.elementary:
        return 'Elementary';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case SkillLevel.beginner:
        return 'Just starting your journey';
      case SkillLevel.elementary:
        return 'Learning the basics';
      case SkillLevel.intermediate:
        return 'Building solid foundation';
      case SkillLevel.advanced:
        return 'Mastering complex concepts';
      case SkillLevel.expert:
        return 'Expert level proficiency';
    }
  }

  String get emoji {
    switch (this) {
      case SkillLevel.beginner:
        return '🌱';
      case SkillLevel.elementary:
        return '🌿';
      case SkillLevel.intermediate:
        return '🌳';
      case SkillLevel.advanced:
        return '🚀';
      case SkillLevel.expert:
        return '👑';
    }
  }

  /// Calculate skill level from percentage score
  static SkillLevel fromPercentage(double percentage) {
    if (percentage >= 91) return SkillLevel.expert;
    if (percentage >= 71) return SkillLevel.advanced;
    if (percentage >= 51) return SkillLevel.intermediate;
    if (percentage >= 31) return SkillLevel.elementary;
    return SkillLevel.beginner;
  }

  /// Get minimum percentage required for this level
  int get minPercentage {
    switch (this) {
      case SkillLevel.beginner:
        return 0;
      case SkillLevel.elementary:
        return 31;
      case SkillLevel.intermediate:
        return 51;
      case SkillLevel.advanced:
        return 71;
      case SkillLevel.expert:
        return 91;
    }
  }

  /// Get maximum percentage for this level
  int get maxPercentage {
    switch (this) {
      case SkillLevel.beginner:
        return 30;
      case SkillLevel.elementary:
        return 50;
      case SkillLevel.intermediate:
        return 70;
      case SkillLevel.advanced:
        return 90;
      case SkillLevel.expert:
        return 100;
    }
  }
}
