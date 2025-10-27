import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable difficulty chip widget with color coding.
///
/// Automatically styles based on difficulty level:
/// - Easy: Green
/// - Medium: Orange
/// - Hard: Red
/// - Default: Grey
///
/// Used in:
/// - Lesson cards
/// - Lesson detail pages
/// - Quiz cards
class DifficultyChip extends StatelessWidget {
  /// Difficulty level (easy, medium, hard)
  final String difficulty;

  /// Optional custom padding
  final EdgeInsets? padding;

  /// Optional icon size
  final double iconSize;

  /// Whether to show icon
  final bool showIcon;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    this.padding,
    this.iconSize = 18,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = getDifficultyColor(difficulty);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.speed_rounded, size: iconSize, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            difficulty.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on difficulty level
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
