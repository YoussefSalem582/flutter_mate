import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/roadmap_stage.dart';

class LessonsPage extends GetView<LessonController> {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = Get.arguments as RoadmapStage;

    // Load lessons when page opens
    controller.loadLessonsByStage(stage.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [_buildAppBar(context, stage), _buildLessonsList(context)],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RoadmapStage stage) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: stage.color,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          stage.title,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [stage.color, stage.color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(stage.icon, size: 64, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: stage.color,
          child: Obx(() {
            final percentage = controller.completionPercentage;
            final completed = controller.completedCount;
            final total = controller.lessons.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: $completed/$total lessons',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLessonsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.lessons.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'No lessons available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final lesson = controller.lessons[index];
            final isCompleted = controller.isLessonCompleted(lesson.id);
            final canAccess = controller.canAccessLesson(lesson);

            return _buildLessonCard(
                  context,
                  lesson,
                  isCompleted,
                  canAccess,
                  index,
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                .slideX(begin: 0.2, duration: 300.ms, delay: (index * 50).ms);
          }, childCount: controller.lessons.length),
        ),
      );
    });
  }

  Widget _buildLessonCard(
    BuildContext context,
    lesson,
    bool isCompleted,
    bool canAccess,
    int index,
  ) {
    final stage = Get.arguments as RoadmapStage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? stage.color.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canAccess
              ? () => Get.toNamed('/lesson-detail', arguments: lesson)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Lesson number badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? stage.color
                            : stage.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              )
                            : Text(
                                '${index + 1}',
                                style: AppTextStyles.h3.copyWith(
                                  color: stage.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: AppTextStyles.h3.copyWith(
                              color: canAccess
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoChip(
                                context,
                                Icons.schedule_rounded,
                                '${lesson.duration} min',
                                stage.color,
                              ),
                              const SizedBox(width: 8),
                              _buildDifficultyChip(context, lesson.difficulty),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!canAccess)
                      Icon(
                        Icons.lock_rounded,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.3),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color
                        ?.withOpacity(canAccess ? 0.8 : 0.5),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson.prerequisites.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                      Text(
                        '${lesson.prerequisites.length} prerequisite${lesson.prerequisites.length > 1 ? 's' : ''}',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
