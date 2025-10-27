import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/lesson.dart';
import '../../../quiz/services/quiz_tracking_service.dart';
import '../widgets/widgets.dart';

/// Lesson detail page showing comprehensive lesson information.
///
/// This page provides:
/// - Study timer to track learning time
/// - Lesson metadata (duration, difficulty)
/// - Step-by-step study guide
/// - Overview and description
/// - Prerequisites list
/// - Learning resources with links
/// - Learning objectives
/// - Video tutorials
/// - Code Playground link
/// - Quiz access
/// - Practice exercises
///
/// The page uses a modular widget composition architecture where
/// each section is a separate, reusable widget for better maintainability.
class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({super.key});

  /// Get lesson controller
  LessonController get controller => Get.find<LessonController>();

  /// Get quiz tracking service
  QuizTrackingService get quizService => Get.find<QuizTrackingService>();

  @override
  Widget build(BuildContext context) {
    // Get lesson from arguments - handle both direct Lesson and Map with lesson
    final arguments = Get.arguments;
    final Lesson? lesson = arguments is Lesson
        ? arguments
        : (arguments is Map && arguments.containsKey('lesson')
            ? arguments['lesson'] as Lesson?
            : null);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Handle null lesson case
    if (lesson == null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsible app bar
          LessonAppBar(title: lesson.title, lesson: lesson),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Study timer with persistent tracking
                  StudyTimerWidget(
                    lessonId: lesson.id,
                    durationMinutes: lesson.duration,
                  ),
                  const SizedBox(height: 16),

                  // Meta info (duration, difficulty)
                  LessonMetaInfo(lesson: lesson),
                  const SizedBox(height: 24),

                  // Study guide
                  StudyGuideWidget(lesson: lesson),
                  const SizedBox(height: 24),

                  // Overview/Description
                  LessonOverviewWidget(lesson: lesson),
                  const SizedBox(height: 24),

                  // Prerequisites
                  PrerequisitesWidget(lesson: lesson, controller: controller),
                  if (lesson.prerequisites.isNotEmpty)
                    const SizedBox(height: 24),

                  // Learning resources
                  LearningResourcesWidget(lesson: lesson),
                  if (lesson.resources.isNotEmpty) const SizedBox(height: 24),

                  // Learning objectives
                  LearningObjectivesWidget(lesson: lesson),
                  const SizedBox(height: 24),

                  // Video tutorials
                  VideoTutorialsWidget(lessonId: lesson.id, isDark: isDark),
                  const SizedBox(height: 24),

                  // Section header - Try It Yourself
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Try It Yourself',
                        style: AppTextStyles.h3.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Exercises card (1st)
                  ExercisesCardWidget(lesson: lesson),
                  const SizedBox(height: 16),

                  // Code Playground (2nd)
                  const CodePlaygroundCardWidget(),
                  const SizedBox(height: 24),

                  // Section header - Test Your Knowledge
                  Row(
                    children: [
                      const Icon(Icons.quiz_rounded, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Test Your Knowledge',
                        style: AppTextStyles.h3.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quiz card (3rd - last)
                  QuizCardWidget(lesson: lesson),
                  const SizedBox(height: 24),

                  // Finish Lesson button (appears after quiz completion with perfect score)
                  Obx(() {
                    final hasPerfectScore =
                        quizService.hasPassedQuizPerfectly(lesson.id);
                    final isLessonCompleted =
                        controller.isLessonCompleted(lesson.id);

                    if (hasPerfectScore && !isLessonCompleted) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Perfect Score! 🎉',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You got all questions correct! Ready to finish this lesson?',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  controller.toggleLessonCompletion(lesson.id),
                              icon: const Icon(Icons.check_circle, size: 28),
                              label: const Text(
                                'Finish Lesson',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button (Mark Complete) - hidden when finish lesson button is shown
      floatingActionButton: Obx(() {
        final isCompleted = controller.isLessonCompleted(lesson.id);
        final hasPerfectScore = quizService.hasPassedQuizPerfectly(lesson.id);

        // Hide FAB if quiz has perfect score but lesson is not completed (show finish lesson button instead)
        if (hasPerfectScore && !isCompleted) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => controller.toggleLessonCompletion(lesson.id),
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.check_circle_outline,
          ),
          label: Text(isCompleted ? 'Completed' : 'Mark Complete'),
          backgroundColor: isCompleted ? AppColors.success : null,
        ).animate(target: isCompleted ? 1 : 0).scale();
      }),
    );
  }

  /// Build error state when lesson is null
  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text('Lesson not found', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Please go back and try again',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
