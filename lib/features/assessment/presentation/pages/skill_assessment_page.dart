import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
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
                backgroundColor: Colors.grey[300],
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
                        color: Colors.grey[600],
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
                      color: Colors.grey[400],
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
                        color: Colors.grey[600],
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
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.lightSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${controller.currentQuestionIndex.value + 1}/${controller.selectedQuestions.length}',
                        style: AppTextStyles.bodyMedium,
                      ),
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
                    ],
                  ),
                ),

                // Question card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AssessmentQuestionCard(
                      question: question,
                      onAnswer: (index) => controller.answerQuestion(index),
                      selectedAnswer: controller.getUserAnswer(question.id),
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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

                      // Skip button
                      TextButton(
                        onPressed: () => controller.skipQuestion(),
                        child: const Text('Skip'),
                      ),
                      const SizedBox(width: 12),

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
