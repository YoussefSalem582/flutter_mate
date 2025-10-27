import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable info chip widget for displaying metadata with an icon.
///
/// Used across multiple screens to show:
/// - Lesson duration (clock icon)
/// - Stage info (various icons)
/// - Any labeled metadata with icon
///
/// Features:
/// - Icon + label layout
/// - Color-themed background
/// - Rounded corners with border
/// - Compact sizing
class InfoChip extends StatelessWidget {
  /// Icon to display on the left
  final IconData icon;

  /// Text label to display
  final String label;

  /// Theme color for icon, text, and background
  final Color color;

  /// Optional custom padding
  final EdgeInsets? padding;

  /// Optional custom icon size
  final double iconSize;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.padding,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
