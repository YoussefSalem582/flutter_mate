import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/lesson.dart';

class LessonDetailPage extends GetView<LessonController> {
  const LessonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lesson = Get.arguments as Lesson;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, lesson, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaInfo(context, lesson, isDark),
                  const SizedBox(height: 24),
                  _buildDescription(context, lesson),
                  const SizedBox(height: 24),
                  if (lesson.prerequisites.isNotEmpty) ...[
                    _buildPrerequisites(context, lesson),
                    const SizedBox(height: 24),
                  ],
                  if (lesson.resources.isNotEmpty) ...[
                    _buildResources(context, lesson, isDark),
                    const SizedBox(height: 24),
                  ],
                  _buildLearningObjectives(context, lesson, isDark),
                  const SizedBox(height: 24),
                  _buildExercises(context, lesson, isDark),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildAppBar(BuildContext context, Lesson lesson, bool isDark) {
    Color difficultyColor;
    switch (lesson.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: difficultyColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          lesson.title,
          style: AppTextStyles.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [difficultyColor, difficultyColor.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.school_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context, Lesson lesson, bool isDark) {
    Color difficultyColor;
    switch (lesson.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Row(
      children: [
        _buildInfoChip(
          context,
          Icons.schedule_rounded,
          '${lesson.duration} min',
          AppColors.info,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: difficultyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: difficultyColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed_rounded, size: 18, color: difficultyColor),
              const SizedBox(width: 6),
              Text(
                lesson.difficulty.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: difficultyColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildPrerequisites(BuildContext context, Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Prerequisites',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Complete these lessons first to unlock this content.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        ...lesson.prerequisites.map((prereqId) {
          return Obx(() {
            final isCompleted = controller.isLessonCompleted(prereqId);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.3)
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? AppColors.success : null,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lesson: $prereqId',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        }),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildResources(BuildContext context, Lesson lesson, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Learning Resources',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...lesson.resources.map((resource) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.info.withOpacity(0.1),
                child: const Icon(
                  Icons.link_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              title: Text(
                resource,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
              onTap: () {
                Get.snackbar(
                  'Resource',
                  'Would open: $resource',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildLearningObjectives(
    BuildContext context,
    Lesson lesson,
    bool isDark,
  ) {
    final objectives = [
      'Understand the core concepts',
      'Apply knowledge through practical examples',
      'Build confidence with hands-on practice',
      'Prepare for the next lesson in the series',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Learning Objectives',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...objectives.map((objective) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    objective,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildExercises(BuildContext context, Lesson lesson, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.code_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Practice Exercises',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Challenge',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Try building a simple Flutter app using the concepts from this lesson. Experiment with different approaches and see what works best!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Interactive code playground will be available soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Exercise'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }
}
