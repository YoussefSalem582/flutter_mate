import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'achievement_badge_widget.dart';

/// Horizontal scrolling list of achievement badges
class AchievementBadgesSection extends StatelessWidget {
  final bool isDark;

  const AchievementBadgesSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final achievementController = Get.find<AchievementController>();

    return Obx(() {
      final unlocked = achievementController.unlockedAchievements;
      final total = achievementController.achievements.length;
      final isLoading = achievementController.isLoading;
      final textScale = MediaQuery.of(context).textScaleFactor;
      final adjustedScale = textScale.clamp(0.9, 2.4);
      final scaleForSize = adjustedScale < 1.0 ? 1.0 : adjustedScale;
      const baseBadgeHeight = 130.0;
      final badgeHeight = baseBadgeHeight * scaleForSize;

      final displayBadges = unlocked.take(6).toList();

      Widget content;
      if (isLoading && total == 0) {
        content = SizedBox(
          height: badgeHeight,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
          ),
        );
      } else if (displayBadges.isEmpty) {
        content = Container(
          height: badgeHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Keep learning to unlock achievements!',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        content = SizedBox(
          height: badgeHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayBadges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final achievement = displayBadges[index];
              final progress =
                  achievementController.userProgress[achievement.id];
              return AchievementBadgeWidget(
                achievement: achievement,
                progress: progress,
                isDark: isDark,
              );
            },
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.achievements);
                },
                child: Text(
                  total > 0
                      ? 'View All (${unlocked.length}/$total)'
                      : 'View All',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      );
    });
  }
}
