import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/shared/widgets/quick_access_cards.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';

/// Enhanced fixed/sticky sidebar navigation for desktop screens.
///
/// Features:
/// - User profile section with avatar and level
/// - XP progress bar
/// - Organized navigation with categories
/// - Learning streak indicator
/// - Quick stats overview
/// - Theme toggle
/// - Sign out button
class DesktopSidebar extends StatefulWidget {
  final Widget? topContent;
  final bool isDark;
  final double width;

  const DesktopSidebar({
    super.key,
    this.topContent,
    this.isDark = false,
    this.width = 350,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  bool _isMainExpanded = true;
  bool _isLearningExpanded = true;
  bool _isToolsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Profile Header
          _buildProfileHeader(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP Progress Section
                  _buildXPProgress(),

                  const SizedBox(height: 20),

                  // Quick Stats
                  _buildQuickStats(),

                  const SizedBox(height: 24),

                  // Main Navigation
                  _buildNavigationSection(
                    'Main',
                    Icons.home,
                    _isMainExpanded,
                    () => setState(() => _isMainExpanded = !_isMainExpanded),
                    _getMainMenuItems(),
                  ),

                  const SizedBox(height: 16),

                  // Learning Navigation
                  _buildNavigationSection(
                    'Learning',
                    Icons.school,
                    _isLearningExpanded,
                    () => setState(
                        () => _isLearningExpanded = !_isLearningExpanded),
                    _getLearningMenuItems(),
                  ),

                  const SizedBox(height: 16),

                  // Tools Navigation
                  _buildNavigationSection(
                    'Tools',
                    Icons.build,
                    _isToolsExpanded,
                    () => setState(() => _isToolsExpanded = !_isToolsExpanded),
                    _getToolsMenuItems(),
                  ),

                  const SizedBox(height: 24),

                  // Quick Access Cards
                  _buildQuickAccessSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer Actions
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.currentUser.value;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [
                      AppColors.darkPrimary,
                      AppColors.darkPrimary.withOpacity(0.7)
                    ]
                  : [
                      AppColors.lightPrimary,
                      AppColors.lightPrimary.withOpacity(0.7)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary)
                    .withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with Level Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: user?.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 40,
                                  color: widget.isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: widget.isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                    ),
                  ),
                  // Level Badge
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: GetBuilder<ProgressTrackerController>(
                      builder: (controller) {
                        final level =
                            (controller.xpPoints.value / 1000).floor() + 1;
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '$level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // User Name
              Text(
                user?.displayName ?? user?.username ?? 'Flutter Learner',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (user?.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  user!.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildXPProgress() {
    return GetBuilder<ProgressTrackerController>(
      builder: (controller) {
        final currentXP = controller.xpPoints.value;
        final level = (currentXP / 1000).floor() + 1;
        final xpInCurrentLevel = currentXP % 1000;
        final progress = xpInCurrentLevel / 1000;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (widget.isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary)
                  .withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Level $level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$xpInCurrentLevel / 1000 XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor:
                      widget.isDark ? Colors.grey[800] : Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return GetBuilder<ProgressTrackerController>(
      builder: (progressController) {
        return GetBuilder<AchievementController>(
          builder: (achievementController) {
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.local_fire_department,
                    '${progressController.dayStreak.value}',
                    'Day Streak',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    Icons.emoji_events,
                    '${achievementController.unlockedAchievements.length}',
                    'Achievements',
                    Colors.amber,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(
    String title,
    IconData icon,
    bool isExpanded,
    VoidCallback onToggle,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: widget.isDark ? Colors.white54 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...items.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final isActive = Get.currentRoute == item['route'];
    final primaryColor =
        widget.isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final hasBadge = item['badge'] as bool? ?? false;
    final badgeCount = item['badgeCount'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                isActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            dense: true,
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isActive
                      ? primaryColor
                      : (widget.isDark ? Colors.white70 : Colors.black87),
                  size: 22,
                ),
                if (hasBadge && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? primaryColor
                    : (widget.isDark ? Colors.white : Colors.black87),
                fontSize: 14,
              ),
            ),
            onTap: () => Get.toNamed(item['route'] as String),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMainMenuItems() {
    return [
      {
        'icon': Icons.dashboard_outlined,
        'label': 'Dashboard',
        'route': AppRoutes.roadmap,
      },
      {
        'icon': Icons.track_changes,
        'label': 'Progress',
        'route': AppRoutes.progressTracker,
      },
      {
        'icon': Icons.analytics_outlined,
        'label': 'Analytics',
        'route': AppRoutes.analyticsDashboard,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'Achievements',
        'route': AppRoutes.achievements,
      },
    ];
  }

  List<Map<String, dynamic>> _getLearningMenuItems() {
    return [
      {
        'icon': Icons.book_outlined,
        'label': 'Roadmap',
        'route': AppRoutes.flutterDeveloperRoadmap,
      },
      {
        'icon': Icons.assessment_outlined,
        'label': 'Skill Assessment',
        'route': AppRoutes.skillAssessment,
      },
      {
        'icon': Icons.history,
        'label': 'Assessment History',
        'route': AppRoutes.assessmentHistory,
      },
    ];
  }

  List<Map<String, dynamic>> _getToolsMenuItems() {
    return [
      {
        'icon': Icons.code,
        'label': 'Code Playground',
        'route': AppRoutes.codePlayground,
      },
      {
        'icon': Icons.assistant_outlined,
        'label': 'AI Assistant',
        'route': AppRoutes.assistant,
        'badge': true,
        'badgeCount': 0, // Can be dynamically updated
      },
    ];
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.bolt,
                size: 18,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        QuickAccessCards(
          showTitle: false,
          cardHeight: 90,
          isDark: widget.isDark,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[900] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Theme Toggle
          _buildFooterButton(
            icon: widget.isDark ? Icons.light_mode : Icons.dark_mode,
            label: widget.isDark ? 'Light Mode' : 'Dark Mode',
            onTap: () {
              // Toggle theme
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),

          const SizedBox(height: 8),

          // Profile Link
          _buildFooterButton(
            icon: Icons.person_outline,
            label: 'Profile & Settings',
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),

          const SizedBox(height: 8),

          // Sign Out
          _buildFooterButton(
            icon: Icons.logout,
            label: 'Sign Out',
            onTap: () => _showSignOutDialog(Get.find<AuthController>()),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    color ?? (widget.isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
