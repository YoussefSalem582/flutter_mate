import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/achievements/data/models/achievement.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

/// Profile page showing user stats and settings
class ProfilePage extends GetView<ProgressTrackerController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievementController = Get.find<AchievementController>();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Profile & Settings',
        icon: Icons.person,
        iconColor: AppColors.info,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Profile editing will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header with Gradient
          Obx(() {
            final header = _buildProfileHeader(
              context,
              isDark,
              achievementController,
            );
            return header.animate().fadeIn().scale(duration: 600.ms);
          }),

          const SizedBox(height: 24),

          // Achievement Badges
          Obx(() {
            final badges = _buildAchievementBadges(
              context,
              isDark,
              achievementController,
            );
            return badges.animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
          }),

          const SizedBox(height: 24),

          // Quick Stats
          Text(
            'Statistics',
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          Obx(() {
            final stats = _buildStatsGrid(context, isDark);
            return stats.animate().fadeIn(delay: 400.ms).slideX(begin: -0.2);
          }),

          const SizedBox(height: 24),

          // Learning Preferences
          _buildSectionHeader(
            context,
            'Learning Preferences',
            Icons.tune,
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 16),

          _buildPreferencesCard(
            context,
            isDark,
            themeManager,
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),

          const SizedBox(height: 24),

          // Account Settings
          _buildSectionHeader(
            context,
            'Account Settings',
            Icons.settings,
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 16),

          _buildSettingsCard(
            context,
            isDark,
          ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),

          const SizedBox(height: 24),

          // About & Support
          _buildSectionHeader(
            context,
            'About & Support',
            Icons.help_outline,
          ).animate().fadeIn(delay: 900.ms),

          const SizedBox(height: 16),

          _buildAboutCard(
            context,
            isDark,
          ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    AchievementController achievementController,
  ) {
    const xpToNextLevel = 1000;
    final currentXP = controller.xpPoints.value;
    final currentLevel = (currentXP / xpToNextLevel).floor() + 1;
    final unlockedAchievements =
        achievementController.unlockedAchievements.length;
    final totalAchievements = achievementController.achievements.length;
    final achievementsLabel =
        (achievementController.isLoading && totalAchievements == 0)
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
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: AppColors.info),
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
              'Flutter Developer',
              style: AppTextStyles.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Learning since October 2025',
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

  Widget _buildAchievementBadges(
    BuildContext context,
    bool isDark,
    AchievementController achievementController,
  ) {
    final unlocked = achievementController.unlockedAchievements;
    final total = achievementController.achievements.length;
    final isLoading = achievementController.isLoading;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final adjustedScale = textScale.clamp(0.9, 2.4);
    final scaleForSize = adjustedScale < 1.0 ? 1.0 : adjustedScale;
    final baseBadgeHeight = 130.0;
    final badgeHeight = baseBadgeHeight * scaleForSize;

    final displayBadges = unlocked.take(6).toList();

    Widget content;
    if (isLoading && total == 0) {
      content = SizedBox(
        height: badgeHeight,
        child: Center(
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
            final progress = achievementController.userProgress[achievement.id];
            return _buildAchievementBadge(
              context,
              achievement,
              progress,
              isDark,
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
                total > 0 ? 'View All (${unlocked.length}/$total)' : 'View All',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context,
    Achievement achievement,
    AchievementProgress? progress,
    bool isDark,
  ) {
    final unlocked = progress?.isUnlocked ?? false;
    final color = _badgeColor(achievement.category);
    final textScale = MediaQuery.textScaleFactorOf(context).clamp(0.9, 2.4);
    final baseCardWidth = 120.0;
    final scaleForWidth = textScale < 1.0 ? 1.0 : textScale;
    final cardWidth = baseCardWidth * scaleForWidth;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? color.withOpacity(0.4)
              : Theme.of(context).dividerColor.withOpacity(0.2),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(unlocked ? 0.2 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '+${achievement.xpReward} XP',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String category) {
    switch (category) {
      case 'lessons':
        return AppColors.info;
      case 'quizzes':
        return Colors.purple;
      case 'streak':
        return Colors.orange;
      case 'special':
        return AppColors.success;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    final completedLessons = controller.lessonsCompleted.value;
    final totalLessons = controller.totalLessons.value;
    final projects = controller.projectsCompleted.value;
    final streak = controller.dayStreak.value;
    final xp = controller.xpPoints.value;

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
        return _buildStatCard(
          context,
          stat['value'] as String,
          stat['label'] as String,
          stat['icon'] as IconData,
          stat['color'] as Color,
          isDark,
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    bool isDark,
    ThemeManager themeManager,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeManager.isDarkMode,
              onChanged: (_) => themeManager.toggleTheme(),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.info,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get reminded to practice'),
            value: true,
            onChanged: (value) {
              Get.snackbar(
                'Coming Soon',
                'Notification preferences will be available soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.warning,
              ),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds for achievements'),
            value: false,
            onChanged: (value) {},
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.volume_up, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            'Language',
            'English',
            Icons.language,
            AppColors.info,
            () {},
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Privacy & Security',
            'Manage your data',
            Icons.security,
            AppColors.success,
            () {},
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Data & Storage',
            'Clear cache and data',
            Icons.storage,
            Colors.orange,
            () {},
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Account',
            'Manage your account',
            Icons.account_circle,
            Colors.purple,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            'About FlutterMate',
            'Version 1.0.0',
            Icons.info,
            AppColors.info,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'FlutterMate',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  const Text(
                    'Your personal Flutter learning companion. Built with ❤️ using Flutter.',
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Help & Support',
            'Get help and report issues',
            Icons.help,
            AppColors.warning,
            () {
              Get.snackbar(
                'Support',
                'Contact us at support@fluttermate.app',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Rate Us',
            'Share your feedback',
            Icons.star_rate,
            Colors.amber,
            () {
              Get.snackbar(
                'Thank You!',
                'We appreciate your feedback',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context,
            'Share App',
            'Tell your friends about FlutterMate',
            Icons.share,
            AppColors.success,
            () {
              Get.snackbar(
                'Share',
                'Share FlutterMate with your friends',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}
