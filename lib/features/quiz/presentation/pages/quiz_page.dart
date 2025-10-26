import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import '../../controller/quiz_controller.dart';

/// Interactive quiz page for testing knowledge
class QuizPage extends GetView<QuizController> {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Restart Quiz?'),
                  content: const Text(
                    'Are you sure you want to restart? Your progress will be lost.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.restartQuiz();
                        Get.back();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Restart Quiz',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isCompleted.value) {
          return _buildResultsScreen(context, isDark);
        }

        if (controller.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildProgressHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuestionCard(context, isDark)
                        .animate(
                          key: ValueKey(controller.currentQuestionIndex.value),
                        )
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.2),
                    const SizedBox(height: 24),
                    _buildOptionsGrid(context, isDark),
                    const SizedBox(height: 24),
                    if (controller.showExplanation.value)
                      _buildExplanation(
                        context,
                        isDark,
                      ).animate().fadeIn().slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(context, isDark),
          ],
        );
      }),
    );
  }

  Widget _buildProgressHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentQuestionIndex.value + 1}/${controller.totalQuestions}',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.warning, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.score.value} XP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, bool isDark) {
    final question = controller.currentQuestion;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${question.points} XP',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, bool isDark) {
    final question = controller.currentQuestion;
    final userAnswer = controller.getUserAnswer(
      controller.currentQuestionIndex.value,
    );

    return Column(
      children: List.generate(question.options.length, (index) {
        final isSelected = userAnswer == index;
        final isCorrect = index == question.correctAnswerIndex;
        final showResult = controller.showExplanation.value;

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
          borderColor = isSelected
              ? AppColors.info
              : Theme.of(context).dividerColor;
          textColor =
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
        }

        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showResult
                      ? null
                      : () => controller.selectAnswer(index),
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
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
      }),
    );
  }

  Widget _buildExplanation(BuildContext context, bool isDark) {
    final question = controller.currentQuestion;
    final isCorrect = controller.isAnswerCorrect(
      controller.currentQuestionIndex.value,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
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
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Correct!' : 'Not quite!',
                style: AppTextStyles.h3.copyWith(
                  color: isCorrect ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.hasPreviousQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          if (controller.hasPreviousQuestion) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: controller.showExplanation.value
                  ? controller.nextQuestion
                  : null,
              icon: Icon(
                controller.hasNextQuestion ? Icons.arrow_forward : Icons.check,
              ),
              label: Text(
                controller.hasNextQuestion ? 'Next Question' : 'Finish Quiz',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, bool isDark) {
    final percentage = controller.scorePercentage;
    final isPassed = percentage >= 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isPassed ? AppColors.success : AppColors.warning,
                  (isPassed ? AppColors.success : AppColors.warning)
                      .withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isPassed ? AppColors.success : AppColors.warning)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isPassed ? Icons.emoji_events : Icons.refresh,
                  size: 80,
                  color: Colors.white,
                ).animate().scale(duration: 600.ms),
                const SizedBox(height: 16),
                Text(
                  isPassed ? 'Congratulations!' : 'Keep Learning!',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  isPassed ? 'You passed the quiz!' : 'Practice makes perfect!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultStat(
                      'Score',
                      '${percentage.toStringAsFixed(0)}%',
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildResultStat(
                      'Correct',
                      '${controller.correctAnswersCount}/${controller.totalQuestions}',
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildResultStat('XP Earned', '${controller.score.value}'),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.restartQuiz();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.home),
                  label: const Text('Back Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
