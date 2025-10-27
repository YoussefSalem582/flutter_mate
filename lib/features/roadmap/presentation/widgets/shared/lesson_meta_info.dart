import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../shared/widgets/widgets.dart';
import '../../../data/models/lesson.dart';

/// Displays lesson metadata (duration and difficulty).
///
/// Features:
/// - Duration chip with clock icon (using shared InfoChip)
/// - Difficulty chip with color coding (using shared DifficultyChip)
/// - Slide-in animation
/// 
/// Refactored to use shared widgets from lib/shared/widgets
class LessonMetaInfo extends StatelessWidget {
  final Lesson lesson;

  const LessonMetaInfo({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Duration chip - using shared InfoChip widget
        InfoChip(
          icon: Icons.schedule_rounded,
          label: '${lesson.duration} min',
          color: AppColors.info,
        ),
        const SizedBox(width: 12),

        // Difficulty chip - using shared DifficultyChip widget
        DifficultyChip(
          difficulty: lesson.difficulty,
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2);
  }
}
