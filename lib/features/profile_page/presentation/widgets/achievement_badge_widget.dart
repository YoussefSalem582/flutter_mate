import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/achievements/data/models/achievement.dart';

/// Single achievement badge widget
class AchievementBadgeWidget extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress? progress;
  final bool isDark;

  const AchievementBadgeWidget({
    super.key,
    required this.achievement,
    this.progress,
    required this.isDark,
  });

  Color _badgeColor(String category) {
    switch (category) {
      case 'lessons':
        return AppColors.info;
      case 'quizzes':
        return Colors.purple;
      case 'streak':
        return Colors.orange;
      case 'special':
        return AppColors.success;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = progress?.isUnlocked ?? false;
    final color = _badgeColor(achievement.category);
    final textScale = MediaQuery.textScaleFactorOf(context).clamp(0.9, 2.4);
    const baseCardWidth = 120.0;
    final scaleForWidth = textScale < 1.0 ? 1.0 : textScale;
    final cardWidth = baseCardWidth * scaleForWidth;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? color.withOpacity(0.4)
              : Theme.of(context).dividerColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(unlocked ? 0.2 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '+${achievement.xpReward} XP',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
