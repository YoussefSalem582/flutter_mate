import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../data/models/roadmap_stage.dart';

/// Individual lesson card widget.
///
/// Features:
/// - Adaptive styling based on completion status
/// - Lesson number badge (or checkmark if completed)
/// - Title, duration, and difficulty chips
/// - Description with ellipsis
/// - Prerequisites count
/// - Lock/unlock status indicators
/// - Navigation to lesson detail page
///
/// Visual States:
/// - Completed: Colored border, checkmark badge
/// - Accessible: Full opacity, clickable
/// - Locked: Reduced opacity, lock icon, snackbar on tap
/// - Advanced unlocked: Special "Unlocked" badge
class LessonCard extends StatelessWidget {
  final dynamic lesson;
  final bool isCompleted;
  final bool canAccess;
  final int index;
  final RoadmapStage stage;
  final bool isAdvancedMode;
  final VoidCallback onRefresh;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCompleted,
    required this.canAccess,
    required this.index,
    required this.stage,
    required this.isAdvancedMode,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCompleted ? stage.color.withOpacity(0.5) : Colors.transparent,
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
          onTap: canAccess ? _handleTap : _handleLockedTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Lesson number badge
                    _buildLessonBadge(),
                    const SizedBox(width: 12),

                    // Title and metadata
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
                              InfoChip(
                                icon: Icons.schedule_rounded,
                                label: '${lesson.duration} min',
                                color: stage.color,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                iconSize: 14,
                              ),
                              const SizedBox(width: 8),
                              DifficultyChip(
                                difficulty: lesson.difficulty,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                iconSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status badge (lock/unlock/advanced)
                    _buildStatusBadge(context),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  lesson.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(canAccess ? 0.8 : 0.5),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Prerequisites count
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

  /// Build lesson number badge or checkmark
  Widget _buildLessonBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted ? stage.color : stage.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
            : Text(
                '${index + 1}',
                style: AppTextStyles.h3.copyWith(
                  color: stage.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Build status badge (lock/unlock/advanced)
  Widget _buildStatusBadge(BuildContext context) {
    // Locked lesson in normal mode
    if (!canAccess && !isAdvancedMode) {
      return Icon(
        Icons.lock_rounded,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
      );
    }

    // Advanced mode unlocked badge
    if (isAdvancedMode && !isCompleted && lesson.prerequisites.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Unlocked',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Handle tap on accessible lesson
  Future<void> _handleTap() async {
    await Get.toNamed('/lesson-detail', arguments: lesson);
    // Refresh lessons after returning from detail page
    onRefresh();
  }

  /// Handle tap on locked lesson
  void _handleLockedTap() {
    Get.snackbar(
      'Locked',
      'Complete the prerequisite lessons first',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
