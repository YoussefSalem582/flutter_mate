import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

/// Individual activity item card in the recent activity list.
class ActivityItemCard extends StatelessWidget {
  final ActivityItem item;

  const ActivityItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = item.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.3),
        ),
      ),
    );
  }
}
