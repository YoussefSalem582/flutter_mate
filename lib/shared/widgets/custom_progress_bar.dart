import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable custom progress bar with label and percentage.
///
/// Features:
/// - Progress label with completion stats
/// - Percentage display
/// - Colored progress indicator
/// - Customizable colors and styling
///
/// Used in:
/// - Lesson pages (stage progress)
/// - Roadmap pages (overall progress)
/// - Stage cards
class CustomProgressBar extends StatelessWidget {
  /// Label text (e.g., "Progress: 5/10 lessons")
  final String label;

  /// Progress value (0.0 to 1.0)
  final double value;

  /// Theme color for the progress bar
  final Color color;

  /// Background color (defaults to white with opacity)
  final Color? backgroundColor;

  /// Height of the progress bar
  final double height;

  /// Whether to show percentage text
  final bool showPercentage;

  /// Text color for label and percentage
  final Color? textColor;

  /// Optional subtitle text
  final String? subtitle;

  const CustomProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.height = 8,
    this.showPercentage = true,
    this.textColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: defaultTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showPercentage)
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.h3.copyWith(
                  color: defaultTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall.copyWith(
              color: defaultTextColor.withOpacity(0.8),
            ),
          ),
        ],
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
