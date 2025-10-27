import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';

/// Shared AppBar widget for all main screens
///
/// This widget provides a consistent AppBar design across the app.
/// It supports customizable title, icon, and actions.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// The title text to display
  final String title;

  /// The icon to display before the title
  final IconData icon;

  /// The color of the icon
  final Color iconColor;

  /// Optional action buttons on the right side
  final List<Widget>? actions;

  /// Whether to show the back button
  final bool showBackButton;

  const AppBarWidget({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor = AppColors.info,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
