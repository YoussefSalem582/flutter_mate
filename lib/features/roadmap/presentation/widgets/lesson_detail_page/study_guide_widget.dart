import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/lesson.dart';

/// Study guide widget showing step-by-step learning approach.
///
/// Features:
/// - 5-step study methodology (Read → Review → Practice → Test → Complete)
/// - Numbered steps with icons
/// - Estimated duration display
/// - Gradient background with info colors
class StudyGuideWidget extends StatelessWidget {
  final Lesson lesson;

  const StudyGuideWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.lightSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'How to Study This Lesson',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Study steps
          _buildStudyStep(
            '1',
            'Read',
            'Go through the overview and description carefully',
            Icons.visibility_rounded,
          ),
          const SizedBox(height: 12),
          _buildStudyStep(
            '2',
            'Review',
            'Check learning resources and objectives',
            Icons.fact_check_rounded,
          ),
          const SizedBox(height: 12),
          _buildStudyStep(
            '3',
            'Practice',
            'Try the exercises to apply what you learned',
            Icons.code_rounded,
          ),
          const SizedBox(height: 12),
          _buildStudyStep(
            '4',
            'Test',
            'Take the quiz to verify your understanding',
            Icons.quiz_rounded,
          ),
          const SizedBox(height: 12),
          _buildStudyStep(
            '5',
            'Complete',
            'Mark lesson complete when you\'re ready',
            Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),

          // Duration estimate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estimated time: ${lesson.duration} minutes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1);
  }

  /// Build a single study step row
  Widget _buildStudyStep(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.info),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
