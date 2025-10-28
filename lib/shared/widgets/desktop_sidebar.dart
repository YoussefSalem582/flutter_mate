import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';

/// Fixed/Sticky sidebar navigation for desktop screens.
///
/// This widget provides a consistent navigation experience across all pages
/// on desktop devices. The sidebar stays fixed while the main content scrolls.
class DesktopSidebar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom top content (e.g., progress header, profile info)
            if (topContent != null) ...[
              topContent!,
              const SizedBox(height: 32),
            ],

            // Navigation menu
            _buildNavigationMenu(isDark),

            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationMenu(bool isDark) {
    final menuItems = [
      {
        'icon': Icons.dashboard,
        'label': 'Dashboard',
        'route': AppRoutes.roadmap,
      },
      {
        'icon': Icons.track_changes,
        'label': 'Progress',
        'route': AppRoutes.progressTracker,
      },
      {
        'icon': Icons.code,
        'label': 'Playground',
        'route': AppRoutes.codePlayground,
      },
      {
        'icon': Icons.person,
        'label': 'Profile',
        'route': AppRoutes.profile,
      },
    ];

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Navigation',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Menu items
        ...menuItems.map((item) {
          final isActive = Get.currentRoute == item['route'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: isActive
                    ? primaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
                size: 24,
              ),
              title: Text(
                item['label'] as String,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? primaryColor
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                ),
              ),
              selected: isActive,
              selectedTileColor: primaryColor.withOpacity(0.1),
              onTap: () => Get.toNamed(item['route'] as String),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
