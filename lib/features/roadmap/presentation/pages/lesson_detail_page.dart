import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/lesson.dart';
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

  @override
  Widget build(BuildContext context) {
    final lesson = Get.arguments as Lesson?;
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
                  // Study timer
                  const StudyTimerWidget(),
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

                  // Code Playground
                  const CodePlaygroundCardWidget(),
                  const SizedBox(height: 24),

                  // Quiz card
                  QuizCardWidget(lesson: lesson),
                  const SizedBox(height: 24),

                  // Exercises card
                  ExercisesCardWidget(lesson: lesson),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button (Mark Complete)
      floatingActionButton: Obx(() {
        final isCompleted = controller.isLessonCompleted(lesson.id);
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
