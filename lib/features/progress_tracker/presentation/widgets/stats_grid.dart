import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/progress_tracker/utils/progress_metrics.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';
import 'package:flutter_mate/shared/widgets/stat_card.dart';

/// Grid of 4 stat cards displaying key metrics.
class StatsGrid extends GetView<ProgressTrackerController> {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 2.5);
    final mainAxisExtent = 150 + (textScale - 1.0) * 110;
    final achievementController = Get.find<AchievementController>();
    final quizService = Get.find<QuizTrackingService>();

    return Obx(() {
      final metrics = ProgressMetrics.fromSources(
        progressController: controller,
        achievementController: achievementController,
        quizService: quizService,
      );

      final stats = [
        {
          'value': metrics.lessonsLabel,
          'label': 'Lessons Completed',
          'icon': Icons.menu_book,
          'color': AppColors.success,
        },
        {
          'value': metrics.achievementsLabel,
          'label': 'Achievements Unlocked',
          'icon': Icons.emoji_events,
          'color': Colors.amber,
        },
        {
          'value': metrics.quizzesCompleted.toString(),
          'label': metrics.quizzesCompleted > 0
              ? 'Avg Score ${metrics.averageQuizScore.toStringAsFixed(0)}%'
              : 'Quizzes Completed',
          'icon': Icons.quiz_rounded,
          'color': AppColors.warning,
        },
        {
          'value': metrics.totalXP.toString(),
          'label': 'Total XP',
          'icon': Icons.stars,
          'color': Colors.purple,
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: mainAxisExtent,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return StatCard(
            title: stat['label'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            color: stat['color'] as Color,
            isDark: isDark,
            showTrend: true,
          );
        },
      );
    });
  }
}
