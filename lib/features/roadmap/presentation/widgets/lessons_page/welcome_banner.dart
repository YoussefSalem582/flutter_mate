import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../features/auth/controller/auth_controller.dart';

/// Welcome banner shown to first-time users.
///
/// Features:
/// - Gradient background (info to success colors)
/// - Rocket icon with colored container
/// - Welcome message with title and description
/// - Border with info color
/// - Fade-in and slide-down animation
///
/// Displayed when:
/// - Controller.completedCount == 0 (no lessons completed)
/// - Controller.advancedMode is false
/// - Shown only for the first item (index == 0)
class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final isGuest = authController.isGuest;

    String greeting = 'Start Your Journey! 🚀';
    String subtitle = 'Tap the first lesson below to begin learning Flutter';

    if (user != null && !isGuest) {
      final name = user.displayName ?? user.email.split('@')[0];
      greeting = 'Welcome, $name! 🚀';
      subtitle = 'Ready to master Flutter? Start with your first lesson below';
    } else if (isGuest) {
      greeting = 'Welcome, Guest! 🚀';
      subtitle = 'Sign up to save your progress as you learn';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.success.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: AppColors.info,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Welcome message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }
}
