import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/progress_tracker/utils/progress_metrics.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';

/// Card displaying XP progress and current level.
class XPProgressCard extends GetView<ProgressTrackerController> {
  const XPProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 2.5);
    final cardPadding = EdgeInsets.all(20 + (textScale - 1.0) * 8);
    final chipSpacing = 12 + (textScale - 1.0) * 6;
    final achievementController = Get.find<AchievementController>();
    final quizService = Get.find<QuizTrackingService>();

    return Obx(() {
      final metrics = ProgressMetrics.fromSources(
        progressController: controller,
        achievementController: achievementController,
        quizService: quizService,
      );

      return Container(
        padding: cardPadding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.military_tech,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Level ${metrics.currentLevel}',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${metrics.totalXP} XP',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 + (textScale - 1.0) * 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: metrics.xpProgressToNextLevel,
                minHeight: 12,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber.shade600,
                ),
              ),
            ),
            SizedBox(height: 8 + (textScale - 1.0) * 4),
            Text(
              '${(metrics.xpProgressToNextLevel * 100).toInt()}% to Level ${metrics.currentLevel + 1}',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 16 + (textScale - 1.0) * 8),
            Wrap(
              spacing: chipSpacing,
              runSpacing: chipSpacing,
              children: [
                _XPBreakdownChip(
                  label: 'Achievements XP',
                  value: metrics.achievementsXP,
                  color: Colors.deepPurple,
                ),
                _XPBreakdownChip(
                  label: 'Quiz XP',
                  value: metrics.quizXP,
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _XPBreakdownChip extends StatelessWidget {
  const _XPBreakdownChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 2.5);
    final horizontalPadding = 12 + (textScale - 1.0) * 6;
    final verticalPadding = 8 + (textScale - 1.0) * 4;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value XP',
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
