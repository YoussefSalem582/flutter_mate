import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/widgets.dart';
import '../../../data/models/lesson.dart';

/// Custom app bar with collapsible design - works in multiple contexts.
///
/// Features:
/// - Expandable/collapsible header (customizable height)
/// - Color-coded by difficulty or custom color
/// - Customizable icon and background
/// - Gradient overlay effect
/// - Optional bottom widget (e.g., progress bar)
///
/// Usage:
/// - Lesson detail page (with lesson difficulty color)
/// - Lessons page (with stage color and progress)
/// - Any page requiring a themed SliverAppBar
class LessonAppBar extends StatelessWidget {
  /// Title to display
  final String title;
  
  /// Optional subtitle
  final String? subtitle;
  
  /// Expanded height (default: 200)
  final double expandedHeight;
  
  /// Background color (if null, uses difficulty color from lesson)
  final Color? backgroundColor;
  
  /// Icon to display in background
  final IconData icon;
  
  /// Optional lesson object (for difficulty color coding)
  final Lesson? lesson;
  
  /// Optional bottom widget (e.g., progress indicator)
  final PreferredSizeWidget? bottom;
  
  /// Optional actions in app bar
  final List<Widget>? actions;

  const LessonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 200,
    this.backgroundColor,
    this.icon = Icons.school_rounded,
    this.lesson,
    this.bottom,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color: use backgroundColor if provided, otherwise lesson difficulty color
    Color appBarColor = backgroundColor ?? 
        (lesson != null ? DifficultyChip.getDifficultyColor(lesson!.difficulty) : Colors.blue);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: appBarColor,
      foregroundColor: Colors.white,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [appBarColor, appBarColor.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                icon,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
      bottom: bottom,
    );
  }
}
