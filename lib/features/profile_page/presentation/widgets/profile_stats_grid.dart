import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/shared/widgets/widgets.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

/// Profile statistics grid using shared StatCard widget
class ProfileStatsGrid extends StatelessWidget {
  final bool isDark;

  const ProfileStatsGrid({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    ProgressTrackerController? controller;

    try {
      controller = Get.find<ProgressTrackerController>();
      // Refresh stats when widget builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller?.refreshStats();
      });
    } catch (e) {
      print('ProgressTrackerController not found: $e');
    }

    return Obx(() {
      final completedLessons = controller?.lessonsCompleted.value ?? 0;
      final totalLessons = controller?.totalLessons.value ?? 0;
      final projects = controller?.projectsCompleted.value ?? 0;
      final streak = controller?.dayStreak.value ?? 0;
      final xp = controller?.xpPoints.value ?? 0;

      final stats = [
        {
          'value': totalLessons > 0
              ? '$completedLessons/$totalLessons'
              : '$completedLessons',
          'label': 'Lessons Completed',
          'icon': Icons.menu_book,
          'color': AppColors.info,
        },
        {
          'value': projects.toString(),
          'label': 'Projects Built',
          'icon': Icons.construction,
          'color': AppColors.success,
        },
        {
          'value': streak == 1 ? '1 day' : '$streak days',
          'label': 'Learning Streak',
          'icon': Icons.local_fire_department,
          'color': Colors.orange,
        },
        {
          'value': xp.toString(),
          'label': 'Total XP',
          'icon': Icons.stars,
          'color': Colors.purple,
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return StatCard(
            value: stat['value'] as String,
            title: stat['label'] as String,
            icon: stat['icon'] as IconData,
            color: stat['color'] as Color,
            isDark: isDark,
            showTrend: false,
          );
        },
      );
    });
  }
}
