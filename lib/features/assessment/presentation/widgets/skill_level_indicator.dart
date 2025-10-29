import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/skill_level.dart';

class SkillLevelIndicator extends StatelessWidget {
  final SkillLevel skillLevel;
  final double percentage;
  final bool showDetails;

  const SkillLevelIndicator({
    super.key,
    required this.skillLevel,
    required this.percentage,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Emoji and level name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  skillLevel.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skillLevel.displayName,
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      skillLevel.description,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForLevel(skillLevel),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Percentage
            Text(
              '${percentage.toStringAsFixed(1)}% Overall Score',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: _getColorForLevel(skillLevel),
              ),
            ),

            // Details
            if (showDetails) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildLevelBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: SkillLevel.values.map((level) {
        final isActive = skillLevel.index >= level.index;
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? _getColorForLevel(level) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  level.emoji,
                  style: TextStyle(
                    fontSize: 20,
                    color: isActive ? null : Colors.grey[500],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level.displayName,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: isActive ? _getColorForLevel(level) : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForLevel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.red;
      case SkillLevel.elementary:
        return AppColors.warning;
      case SkillLevel.intermediate:
        return AppColors.info;
      case SkillLevel.advanced:
        return Colors.blue;
      case SkillLevel.expert:
        return AppColors.success;
    }
  }
}
