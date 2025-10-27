import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/lesson.dart';

/// Learning objectives section with checkmark list.
///
/// Features:
/// - Generic learning objectives for all lessons
/// - Checkmark icons with success color
/// - Circular icon backgrounds
/// - Slide-in animation
class LearningObjectivesWidget extends StatelessWidget {
  final Lesson lesson;

  const LearningObjectivesWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final objectives = [
      'Understand the core concepts',
      'Apply knowledge through practical examples',
      'Build confidence with hands-on practice',
      'Prepare for the next lesson in the series',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.flag_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Learning Objectives',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Objectives list
        ...objectives.map((objective) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkmark icon
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                // Objective text
                Expanded(
                  child: Text(
                    objective,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}
