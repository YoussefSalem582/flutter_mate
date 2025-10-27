import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../controller/lesson_controller.dart';

/// Advanced mode active banner shown at the top of lessons list.
///
/// Features:
/// - Purple gradient background
/// - Rocket icon with semi-transparent container
/// - Title and description text
/// - Close button to disable advanced mode
/// - Fade-in and slide animations with shimmer effect
///
/// Displayed when:
/// - Controller.advancedMode is true
/// - Shown only for the first item (index == 0)
class AdvancedModeBanner extends StatelessWidget {
  final LessonController controller;

  const AdvancedModeBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with semi-transparent background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Mode Active 🚀',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All lessons unlocked! Jump to any topic you want.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => controller.toggleAdvancedMode(),
            tooltip: 'Disable Advanced Mode',
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2).shimmer(delay: 500.ms);
  }
}
