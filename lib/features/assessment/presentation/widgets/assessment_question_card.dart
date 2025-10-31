import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/assessment_question.dart';

class AssessmentQuestionCard extends StatelessWidget {
  final AssessmentQuestion question;
  final Function(int) onAnswer;
  final int? selectedAnswer;

  const AssessmentQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
    this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.category,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question text
            Text(
              question.question,
              style: AppTextStyles.h4.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...List.generate(
              question.options.length,
              (index) => _buildOption(context, index, question.options[index]),
            ),

            // XP indicator
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.stars,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  '${question.xp} XP',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.lightPrimary : AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, int index, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedAnswer == index;
    final optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

    return GestureDetector(
      onTap: () => onAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.info.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          border: Border.all(
            color: isSelected
                ? AppColors.info
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Option label
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.info
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLabels[index],
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Option text
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Selected indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.info,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
