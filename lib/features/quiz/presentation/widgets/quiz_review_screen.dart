import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/shared/widgets/custom_button.dart';
import '../../data/models/quiz_question.dart';

/// Screen for reviewing quiz answers with suggestions for incorrect ones
class QuizReviewScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, int> userAnswers;
  final VoidCallback onClose;

  const QuizReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF42A5F5),
                          const Color(0xFF64B5F6),
                        ]
                      : [
                          AppColors.info,
                          AppColors.info.withOpacity(0.8),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learn from Your Mistakes',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review each question to understand what went wrong',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 24),

            // Questions review
            ...List.generate(questions.length, (index) {
              final question = questions[index];
              final userAnswerIndex = userAnswers[index];
              final isCorrect = userAnswerIndex == question.correctAnswerIndex;

              return _buildQuestionReview(
                context,
                index + 1,
                question,
                userAnswerIndex,
                isCorrect,
                isDark,
              )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn()
                  .slideX(begin: 0.2);
            }),

            const SizedBox(height: 24),

            // Close button
            CustomButton(
              text: 'Back to Results',
              onPressed: onClose,
              icon: Icons.arrow_back,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview(
    BuildContext context,
    int questionNumber,
    QuizQuestion question,
    int? userAnswerIndex,
    bool isCorrect,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
              : (isDark ? const Color(0xFFFFCA28) : AppColors.warning),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
            blurRadius: isDark ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isCorrect
                          ? (isDark
                              ? const Color(0xFF66BB6A)
                              : AppColors.success)
                          : (isDark
                              ? const Color(0xFFFFCA28)
                              : AppColors.warning))
                      .withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: isCorrect
                        ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                        : (isDark
                            ? const Color(0xFFFFCA28)
                            : AppColors.warning),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isCorrect
                          ? (isDark
                              ? const Color(0xFF66BB6A)
                              : AppColors.success)
                          : (isDark
                              ? const Color(0xFFFFCA28)
                              : AppColors.warning))
                      .withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCorrect ? 'Correct' : 'Incorrect',
                  style: AppTextStyles.caption.copyWith(
                    color: isCorrect
                        ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                        : (isDark
                            ? const Color(0xFFFFCA28)
                            : AppColors.warning),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Question text
          Text(
            question.question,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // User's answer
          if (userAnswerIndex != null) ...[
            Text(
              'Your Answer:',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isCorrect
                        ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                        : (isDark
                            ? const Color(0xFFFFCA28)
                            : AppColors.warning))
                    .withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                      : (isDark ? const Color(0xFFFFCA28) : AppColors.warning),
                  width: 1.5,
                ),
              ),
              child: Text(
                question.options[userAnswerIndex],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isCorrect
                      ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                      : (isDark ? const Color(0xFFFFCA28) : AppColors.warning),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Correct answer (if user was wrong)
          if (!isCorrect) ...[
            const SizedBox(height: 16),
            Text(
              'Correct Answer:',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                    .withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF66BB6A) : AppColors.success,
                  width: 1.5,
                ),
              ),
              child: Text(
                question.options[question.correctAnswerIndex],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? const Color(0xFF66BB6A) : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF42A5F5) : AppColors.info)
                  .withOpacity(isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? const Color(0xFF42A5F5) : AppColors.info)
                    .withOpacity(isDark ? 0.3 : 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: isDark ? const Color(0xFF64B5F6) : AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explanation',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isDark ? const Color(0xFF64B5F6) : AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Suggestion for incorrect answers
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFFFFB300) : AppColors.warning)
                    .withOpacity(isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? const Color(0xFFFFB300) : AppColors.warning)
                      .withOpacity(isDark ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: isDark
                            ? const Color(0xFFFFCA28)
                            : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Study Tip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? const Color(0xFFFFCA28)
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review the lesson material related to this topic. '
                    'Understanding the explanation above will help you remember '
                    'the correct answer for next time.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
