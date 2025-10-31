import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

/// Profile header card with avatar, user info, and stats
class ProfileHeaderWidget extends StatelessWidget {
  final bool isDark;

  const ProfileHeaderWidget({
    super.key,
    required this.isDark,
  });

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Joined today';
    } else if (difference.inDays == 1) {
      return 'Joined yesterday';
    } else if (difference.inDays < 7) {
      return 'Joined ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Joined $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Joined $months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return 'Learning since ${date.year}';
    }
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Safely get controllers with fallback
    AchievementController? achievementController;
    ProgressTrackerController? progressController;

    try {
      achievementController = Get.find<AchievementController>();
    } catch (e) {
      print('AchievementController not found: $e');
    }

    try {
      progressController = Get.find<ProgressTrackerController>();
      // Refresh stats when widget builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progressController?.refreshStats();
      });
    } catch (e) {
      print('ProgressTrackerController not found: $e');
    }

    const xpToNextLevel = 1000;

    return Obx(() {
      final user = authController.currentUser.value;
      final displayName = user?.displayName ??
          user?.username ??
          (user != null ? user.email.split('@').first : 'Flutter Developer');
      final userEmail = user?.email ?? 'learning@fluttermate.app';
      final joinedDate = user != null
          ? _formatJoinDate(user.createdAt)
          : 'Learning since October 2025';

      final currentXP = progressController?.xpPoints.value ?? 0;
      final currentLevel = (currentXP / xpToNextLevel).floor() + 1;
      final unlockedAchievements =
          achievementController?.unlockedAchievements.length ?? 0;
      final totalAchievements = achievementController?.achievements.length ?? 0;
      final achievementsLabel =
          (achievementController?.isLoading == true && totalAchievements == 0)
              ? 'Loading'
              : totalAchievements > 0
                  ? '$unlockedAchievements/$totalAchievements'
                  : unlockedAchievements.toString();

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.info, AppColors.info.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.info.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.info,
                            )
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      joinedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Level Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderStat(
                      'Level',
                      '$currentLevel',
                      Icons.military_tech,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildHeaderStat(
                      'Achievements',
                      achievementsLabel,
                      Icons.emoji_events,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildHeaderStat('XP', '$currentXP', Icons.stars),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
