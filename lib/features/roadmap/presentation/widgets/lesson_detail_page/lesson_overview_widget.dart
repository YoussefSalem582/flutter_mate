import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/lesson.dart';
import '../../../../../../core/constants/app_text_styles.dart';

/// Lesson overview/description section.
///
/// Features:
/// - "Overview" header with icon
/// - Full lesson description with proper line height
/// - Fade-in animation
class LessonOverviewWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonOverviewWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }
}
