import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../controller/lesson_controller.dart';
import '../../../data/models/lesson.dart';

/// Displays lesson prerequisites with completion status.
///
/// Features:
/// - List of required lessons
/// - Check/unchecked icons based on completion
/// - Strikethrough for completed prerequisites
/// - Reactive updates with Obx
class PrerequisitesWidget extends StatelessWidget {
  final Lesson lesson;
  final LessonController controller;

  const PrerequisitesWidget({
    super.key,
    required this.lesson,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (lesson.prerequisites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.link_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Prerequisites',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Complete these lessons first to unlock this content.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),

        // Prerequisites list
        ...lesson.prerequisites.map((prereqId) {
          return Obx(() {
            final isCompleted = controller.isLessonCompleted(prereqId);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.3)
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? AppColors.success : null,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lesson: $prereqId',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        }),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}
