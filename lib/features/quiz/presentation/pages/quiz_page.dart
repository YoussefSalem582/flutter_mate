import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/quiz_controller.dart';
import '../widgets/widgets.dart';

/// Interactive quiz page for testing knowledge
class QuizPage extends GetView<QuizController> {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get lessonId from arguments to display
    final args = Get.arguments;
    final String? lessonId = args is Map && args.containsKey('lessonId')
        ? args['lessonId'] as String?
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            lessonId != null ? 'Quiz: Lesson $lessonId' : 'Knowledge Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _showRestartDialog(),
            tooltip: 'Restart Quiz',
          ),
        ],
      ),
      body: Obx(() {
        // Show results screen when quiz is completed
        if (controller.isCompleted.value) {
          // Only award XP if user got all answers correct
          final isPerfectScore =
              controller.correctAnswersCount == controller.totalQuestions;
          final xpEarned = isPerfectScore ? controller.score.value : 0;

          return QuizResultsScreen(
            score: controller.correctAnswersCount,
            totalQuestions: controller.totalQuestions,
            totalXP: xpEarned,
            onRetry: () {
              controller.restartQuiz();
            },
            onBackToLesson: () => Get.back(),
            onReviewAnswers: () {
              _showReviewScreen(context);
            },
          );
        }

        // Show loading state
        if (controller.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show quiz interface
        return Column(
          children: [
            // Progress header
            Obx(() => QuizProgressHeader(
                  currentQuestion: controller.currentQuestionIndex.value + 1,
                  totalQuestions: controller.totalQuestions,
                  score: controller.score.value,
                  progress: controller.progress,
                  isDark: isDark,
                )),

            // Question and options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final question = controller.currentQuestion;
                  final userAnswer = controller.getUserAnswer(
                    controller.currentQuestionIndex.value,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question card
                      QuizQuestionCard(
                        question: question.question,
                        points: question.points,
                      )
                          .animate(
                            key: ValueKey(
                              controller.currentQuestionIndex.value,
                            ),
                          )
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.2),

                      const SizedBox(height: 24),

                      // Answer options
                      QuizAnswerOptions(
                        question: question,
                        userAnswer: userAnswer,
                        showResult: controller.showExplanation.value,
                        isDark: isDark,
                        onSelectAnswer: (index) =>
                            controller.selectAnswer(index),
                      ),

                      const SizedBox(height: 24),

                      // Explanation (shown after answering)
                      if (controller.showExplanation.value)
                        QuizExplanation(
                          explanation: question.explanation,
                          isCorrect: userAnswer == question.correctAnswerIndex,
                          isDark: isDark,
                        ),
                    ],
                  );
                }),
              ),
            ),

            // Navigation buttons
            Obx(() => Padding(
                  padding: const EdgeInsets.all(16),
                  child: QuizNavigationBar(
                    currentQuestionIndex: controller.currentQuestionIndex.value,
                    totalQuestions: controller.totalQuestions,
                    hasAnswered: controller.getUserAnswer(
                          controller.currentQuestionIndex.value,
                        ) !=
                        null,
                    onPrevious: () => controller.previousQuestion(),
                    onNext: () {
                      if (controller.currentQuestionIndex.value >=
                          controller.totalQuestions - 1) {
                        controller.completeQuiz();
                      } else {
                        controller.nextQuestion();
                      }
                    },
                  ),
                )),
          ],
        );
      }),
    );
  }

  /// Show restart confirmation dialog
  void _showRestartDialog() {
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
  }

  /// Show review screen with all answers and explanations
  void _showReviewScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizReviewScreen(
          questions: controller.questions,
          userAnswers: controller.userAnswers,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
