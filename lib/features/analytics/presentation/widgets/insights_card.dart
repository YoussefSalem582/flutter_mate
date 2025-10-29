import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';

/// Card displaying personalized insights and recommendations
///
/// Shows:
/// - AI-generated insights based on study patterns
/// - Motivational messages
/// - Action recommendations
/// - Tips for improvement
class InsightsCard extends StatelessWidget {
  final RxList<String> insights;
  final bool isDark;

  const InsightsCard({
    super.key,
    required this.insights,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (insights.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: const Center(
            child: Text(
              'Start learning to get personalized insights!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(
            insights.length,
            (index) {
              final insight = insights[index];
              return Column(
                children: [
                  _buildInsightItem(insight),
                  if (index < insights.length - 1) const Divider(height: 1),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildInsightItem(String insight) {
    // Extract emoji if present
    final emoji = _extractEmoji(insight);
    final text = insight.replaceFirst(emoji, '').trim();
    final color = _getColorFromEmoji(emoji);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emoji.isNotEmpty ? emoji : '💡',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );

    final match = emojiRegex.firstMatch(text);
    return match != null ? match.group(0) ?? '' : '';
  }

  Color _getColorFromEmoji(String emoji) {
    switch (emoji) {
      case '🔥':
        return Colors.orange;
      case '💪':
        return Colors.red;
      case '⏰':
        return AppColors.info;
      case '🌟':
        return Colors.amber;
      case '📚':
        return Colors.purple;
      case '🎯':
        return AppColors.success;
      case '📝':
        return Colors.blue;
      default:
        return AppColors.info;
    }
  }
}
