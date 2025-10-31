import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../controller/assessment_controller.dart';
import '../widgets/assessment_question_card.dart';

class SkillAssessmentPage extends StatefulWidget {
  const SkillAssessmentPage({super.key});

  @override
  State<SkillAssessmentPage> createState() => _SkillAssessmentPageState();
}

class _SkillAssessmentPageState extends State<SkillAssessmentPage> {
  @override
  void initState() {
    super.initState();
    // Initialize assessment when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<AssessmentController>();
      // Only start if not already active
      if (!controller.isAssessmentActive.value) {
        controller.startAssessment(navigateToPage: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssessmentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        controller.cancelAssessment();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skill Assessment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.cancelAssessment(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: Obx(
              () => LinearProgressIndicator(
                value: controller.progressPercentage / 100,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
          ),
        ),
        body: Obx(
          () {
            // Show loading state with better UI
            if (controller.isLoading.value ||
                controller.selectedQuestions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Preparing your assessment...',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading questions',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final question = controller.currentQuestion;
            if (question == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No questions available',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Progress and XP indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : AppColors.lightSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Question counter
                          Text(
                            'Question ${controller.currentQuestionIndex.value + 1}/${controller.selectedQuestions.length}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          // XP Score display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${controller.score.value} XP',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Difficulty and correct answers badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Difficulty badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(question.difficulty)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getDifficultyIcon(question.difficulty),
                                  size: 16,
                                  color: _getDifficultyColor(question.difficulty),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  question.difficulty.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: _getDifficultyColor(question.difficulty),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Correct answers counter
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${controller.correctAnswers.value}/${controller.currentQuestionIndex.value} correct',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Question card
                Expanded(
                  child: ResponsiveBuilder(
                    mobile: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: AssessmentQuestionCard(
                        question: question,
                        onAnswer: (index) => controller.answerQuestion(index),
                        selectedAnswer: controller.getUserAnswer(question.id),
                      ),
                    ),
                    desktop: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: AssessmentQuestionCard(
                            question: question,
                            onAnswer: (index) =>
                                controller.answerQuestion(index),
                            selectedAnswer:
                                controller.getUserAnswer(question.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Previous button
                      if (controller.currentQuestionIndex.value > 0)
                        OutlinedButton(
                          onPressed: () => controller.previousQuestion(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 8),
                              Text('Previous'),
                            ],
                          ),
                        ),
                      const Spacer(),

                      // Skip button or Stats (show skip only if not answered)
                      if (!controller.isQuestionAnswered(question.id)) ...[
                        TextButton(
                          onPressed: () => controller.skipQuestion(),
                          child: const Text('Skip'),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Stats
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 18,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${controller.score.value} pts',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Next button (show only if answered)
                      if (controller.isQuestionAnswered(question.id)) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => controller.nextQuestion(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            backgroundColor: AppColors.info,
                          ),
                          child: Row(
                            children: [
                              Text(
                                controller.currentQuestionIndex.value ==
                                        controller.selectedQuestions.length - 1
                                    ? 'Finish'
                                    : 'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.lightBackground
                                      : AppColors.lightOnBackground,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: isDark
                                    ? AppColors.lightBackground
                                    : AppColors.lightOnBackground,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.info;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.whatshot;
      default:
        return Icons.help_outline;
    }
  }
}
