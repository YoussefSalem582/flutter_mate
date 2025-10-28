import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';

/// Learning preferences card with theme toggle and settings
class PreferencesCard extends StatelessWidget {
  final bool isDark;

  const PreferencesCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();

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
}
