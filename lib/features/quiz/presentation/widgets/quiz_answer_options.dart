import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import '../../data/models/quiz_question.dart';

/// Grid of answer options for quiz questions
class QuizAnswerOptions extends StatelessWidget {
  final QuizQuestion question;
  final int? userAnswer;
  final bool showResult;
  final bool isDark;
  final Function(int) onSelectAnswer;

  const QuizAnswerOptions({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.showResult,
    required this.isDark,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(question.options.length, (index) {
        return _buildOptionTile(context, index);
      }),
    );
  }

  Widget _buildOptionTile(BuildContext context, int index) {
    final isSelected = userAnswer == index;
    final isCorrect = index == question.correctAnswerIndex;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (isSelected) {
        backgroundColor = AppColors.warning.withOpacity(0.1);
        borderColor = AppColors.warning;
        textColor = AppColors.warning;
      } else {
        backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
        borderColor = Theme.of(context).dividerColor;
        textColor =
            Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
      }
    } else {
      backgroundColor = isSelected
          ? AppColors.info.withOpacity(0.1)
          : (isDark ? AppColors.darkSurface : Colors.white);
      borderColor =
          isSelected ? AppColors.info : Theme.of(context).dividerColor;
      textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showResult ? null : () => onSelectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (showResult && isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                if (showResult && isSelected && !isCorrect)
                  const Icon(
                    Icons.cancel,
                    color: AppColors.warning,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}
