import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/roadmap_stage.dart';
import 'stage_card.dart';

/// Stages list widget displaying all learning stages.
///
/// Features:
/// - Section title with count
/// - List of stage cards
/// - Alternating slide-in animations (left/right)
/// - Progress passed from controller
/// - Dark mode support
///
/// Animation Pattern:
/// - Even indices: slide from left
/// - Odd indices: slide from right
/// - Staggered delays (300ms * index)
/// - Fade-in effect combined with slide
///
/// Layout:
/// - Title with icon and count
/// - Vertical list of stage cards
/// - 16px spacing between cards
/// - Responsive to screen width
class StagesList extends StatelessWidget {
  final List<RoadmapStage> stages;
  final bool isDark;
  final double Function(String stageId) getStageProgress;

  const StagesList({
    super.key,
    required this.stages,
    required this.isDark,
    required this.getStageProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            const Icon(Icons.explore, color: AppColors.info, size: 24),
            const SizedBox(width: 8),
            Text(
              'Learning Stages',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),

            // Stage count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${stages.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stages list
        ...stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final progress = getStageProgress(stage.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
                StageCard(
                      stage: stage,
                      progress: progress,
                      isDark: isDark,
                      index: index,
                    )
                    .animate()
                    .fadeIn(delay: (300 * index).ms)
                    .slideX(
                      begin: index.isEven ? -0.2 : 0.2,
                      delay: (300 * index).ms,
                    ),
          );
        }),
      ],
    );
  }
}
