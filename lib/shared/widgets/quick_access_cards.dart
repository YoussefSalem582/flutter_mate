import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';

/// Quick access cards for Analytics and Assessment features
///
/// This widget provides a consistent way to display quick access cards
/// across different pages (Roadmap, Profile, Desktop Sidebar).
///
/// Features:
/// - Two cards: Analytics and Assessment
/// - Beautiful gradient backgrounds
/// - Smooth tap animations
/// - Responsive sizing
/// - Optional title customization
class QuickAccessCards extends StatelessWidget {
  /// Whether to show the "Quick Access" title
  final bool showTitle;

  /// Card height (default: 100)
  final double cardHeight;

  /// Whether it's dark theme
  final bool isDark;

  /// Optional custom title text
  final String? titleText;

  const QuickAccessCards({
    super.key,
    this.showTitle = true,
    this.cardHeight = 100,
    this.isDark = false,
    this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            titleText ?? 'Quick Access',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: QuickAccessCard(
                title: 'Analytics',
                subtitle: 'Track progress',
                icon: Icons.analytics_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                onTap: () => Get.toNamed(AppRoutes.analyticsDashboard),
                height: cardHeight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickAccessCard(
                title: 'Assessment',
                subtitle: 'Test skills',
                icon: Icons.assessment_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
                onTap: () => Get.toNamed(AppRoutes.skillAssessment),
                height: cardHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual quick access card
///
/// A tappable card with gradient background, icon, title, and subtitle.
/// Used within [QuickAccessCards] but can also be used standalone.
class QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final double height;

  const QuickAccessCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
