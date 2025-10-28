import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../../data/models/roadmap_stage.dart';

/// Enhanced stage card widget with progress and topics.
///
/// Features:
/// - Stage icon in gradient container with shadow
/// - Title and subtitle
/// - Progress percentage badge
/// - Progress bar (CustomProgressBar)
/// - Topic tags (up to 4 visible)
/// - "+X more topics" indicator if more than 4
/// - "Tap to view lessons" footer with arrow
/// - Navigation to lessons page on tap
/// - Alternating slide animations
///
/// Visual Design:
/// - Colored border matching stage theme
/// - Rounded corners (20px radius)
/// - Box shadow matching stage color
/// - Dark mode support
/// - InkWell ripple effect on tap
///
/// Layout:
/// - Icon + title/subtitle row
/// - Progress bar
/// - Topic chips (wrap layout)
/// - Footer with action hint
class StageCard extends StatelessWidget {
  final RoadmapStage stage;
  final double progress;
  final bool isDark;
  final int index;

  const StageCard({
    super.key,
    required this.stage,
    required this.progress,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stage.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: stage.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to lessons without auth check
            Get.toNamed('/lessons', arguments: stage);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and title row
                Row(
                  children: [
                    _buildStageIcon(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTitleSection(context)),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress bar
                CustomProgressBar(
                  label: '',
                  value: progress,
                  color: stage.color,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  showPercentage: false,
                  height: 10,
                ),
                const SizedBox(height: 16),

                // Topic chips
                _buildTopicChips(context),
                const SizedBox(height: 16),

                // Footer
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build stage icon with gradient background
  Widget _buildStageIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [stage.color, stage.color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: stage.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(stage.icon, color: Colors.white, size: 32),
    );
  }

  /// Build title and subtitle with progress badge
  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stage.title,
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Progress percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stage.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: stage.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          stage.subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Build topic chips (max 4 visible)
  Widget _buildTopicChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stage.topics.take(4).map((topic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stage.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: stage.color.withOpacity(0.2)),
              ),
              child: Text(
                topic,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),

        // "+X more topics" indicator
        if (stage.topics.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${stage.topics.length - 4} more topics',
              style: AppTextStyles.caption.copyWith(
                color: stage.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Build footer with action hint
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tap to view lessons',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
        Icon(Icons.arrow_forward, color: stage.color, size: 20),
      ],
    );
  }
}
