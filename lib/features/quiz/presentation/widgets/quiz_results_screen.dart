import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/shared/widgets/custom_button.dart';
import 'package:flutter_mate/shared/widgets/stat_card.dart';

/// Quiz results screen showing score and performance
class QuizResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int totalXP;
  final VoidCallback onRetry;
  final VoidCallback onBackToLesson;
  final VoidCallback? onReviewAnswers;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.totalXP,
    required this.onRetry,
    required this.onBackToLesson,
    this.onReviewAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final passed = percentage >= 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Trophy Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed
                      ? [
                          isDark ? const Color(0xFF4CAF50) : AppColors.success,
                          isDark
                              ? const Color(0xFF66BB6A)
                              : AppColors.success.withOpacity(0.6)
                        ]
                      : [
                          isDark ? const Color(0xFFFFB300) : AppColors.warning,
                          isDark
                              ? const Color(0xFFFFCA28)
                              : AppColors.warning.withOpacity(0.6)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (passed
                            ? (isDark
                                ? const Color(0xFF4CAF50)
                                : AppColors.success)
                            : (isDark
                                ? const Color(0xFFFFB300)
                                : AppColors.warning))
                        .withOpacity(isDark ? 0.5 : 0.4),
                    blurRadius: isDark ? 30 : 20,
                    spreadRadius: isDark ? 8 : 5,
                  ),
                ],
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 60,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1000.ms),

            const SizedBox(height: 24),

            // Result Title
            Text(
              passed ? 'Quiz Completed! 🎉' : 'Keep Practicing! 💪',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            Text(
              passed
                  ? 'Great job! You have a solid understanding.'
                  : 'Don\'t worry, practice makes perfect!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Score',
                    value: '$score/$totalQuestions',
                    icon: Icons.check_circle,
                    color: passed
                        ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                        : (isDark
                            ? const Color(0xFFFFCA28)
                            : AppColors.warning),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Percentage',
                    value: '$percentage%',
                    icon: Icons.pie_chart,
                    color: isDark ? const Color(0xFF42A5F5) : AppColors.info,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                ),
              ],
            ),

            const SizedBox(height: 16),

            StatCard(
              title: totalXP > 0 ? 'XP Earned' : 'No XP Earned',
              value: totalXP > 0 ? '+$totalXP XP' : '0 XP',
              icon: totalXP > 0 ? Icons.stars : Icons.lock,
              color: totalXP > 0
                  ? (isDark ? const Color(0xFF00BCD4) : AppColors.lightPrimary)
                  : (isDark ? const Color(0xFF757575) : Colors.grey),
              isDark: isDark,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            // Message for no XP
            if (totalXP == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFFFB300).withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFFFB300).withOpacity(0.4)
                        : AppColors.warning.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          isDark ? const Color(0xFFFFCA28) : AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Get all answers correct to earn XP!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? const Color(0xFFFFCA28)
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),
            ],

            const SizedBox(height: 40),

            // Action Buttons
            CustomButton(
              text: 'Back to Lesson',
              onPressed: onBackToLesson,
              icon: Icons.arrow_back,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            // Review Answers button (only show if there were wrong answers)
            if (score < totalQuestions && onReviewAnswers != null)
              CustomButton(
                text: 'Review Answers',
                onPressed: onReviewAnswers!,
                icon: Icons.list_alt,
                backgroundColor:
                    isDark ? const Color(0xFF42A5F5) : AppColors.info,
              ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.2),

            if (score < totalQuestions && onReviewAnswers != null)
              const SizedBox(height: 12),

            CustomButton(
              text: 'Retry Quiz',
              onPressed: onRetry,
              isOutlined: true,
              icon: Icons.refresh,
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
