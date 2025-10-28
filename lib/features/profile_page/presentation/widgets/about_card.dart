import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'settings_tile.dart';

/// About & Support card with app info and help options
class AboutCard extends StatelessWidget {
  final bool isDark;

  const AboutCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          SettingsTile(
            title: 'About FlutterMate',
            subtitle: 'Version 1.0.0',
            icon: Icons.info,
            color: AppColors.info,
            onTap: () {
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
          SettingsTile(
            title: 'Help & Support',
            subtitle: 'Get help and report issues',
            icon: Icons.help,
            color: AppColors.warning,
            onTap: () {
              Get.snackbar(
                'Support',
                'Contact us at support@fluttermate.app',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(height: 1),
          SettingsTile(
            title: 'Rate Us',
            subtitle: 'Share your feedback',
            icon: Icons.star_rate,
            color: Colors.amber,
            onTap: () {
              Get.snackbar(
                'Thank You!',
                'We appreciate your feedback',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(height: 1),
          SettingsTile(
            title: 'Share App',
            subtitle: 'Tell your friends about FlutterMate',
            icon: Icons.share,
            color: AppColors.success,
            onTap: () {
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
}
