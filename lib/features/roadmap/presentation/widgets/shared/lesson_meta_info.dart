import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/lesson.dart';

/// Displays lesson metadata with enhanced visual design.
///
/// Features:
/// - Duration and difficulty in elegant cards
/// - Progress indicator if lesson is started
/// - Estimated completion time
/// - Animated entrance
class LessonMetaInfo extends StatelessWidget {
  final Lesson lesson;

  const LessonMetaInfo({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Duration info
          Expanded(
            child: _buildInfoCard(
              context,
              icon: Icons.schedule_rounded,
              label: 'Duration',
              value: '${lesson.duration} min',
            ),
          ),
          const SizedBox(width: 12),

          // Difficulty info
          Expanded(
            child: _buildInfoCard(
              context,
              icon: _getDifficultyIcon(lesson.difficulty),
              label: 'Level',
              value: _formatDifficulty(lesson.difficulty),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1);
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied_rounded;
      case 'medium':
        return Icons.trending_up_rounded;
      case 'hard':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  String _formatDifficulty(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }
}
