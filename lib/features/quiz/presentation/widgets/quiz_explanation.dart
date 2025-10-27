import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';

/// Displays explanation after answering a quiz question
class QuizExplanation extends StatelessWidget {
  final String explanation;
  final bool isCorrect;
  final bool isDark;

  const QuizExplanation({
    super.key,
    required this.explanation,
    required this.isCorrect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.success : AppColors.warning)
            .withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info,
                color: isCorrect ? AppColors.success : AppColors.warning,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Correct! 🎉' : 'Not quite right',
                style: AppTextStyles.h3.copyWith(
                  color: isCorrect ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, duration: 300.ms);
  }
}
