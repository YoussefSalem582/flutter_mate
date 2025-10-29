import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';

/// Card displaying productivity metrics and performance indicators
///
/// Shows:
/// - Focus score (session completion rate)
/// - Completion rate (lessons finished)
/// - Average quiz score
/// - Sessions per week
/// - Productivity and focus level descriptions
class ProductivityCard extends StatelessWidget {
  final double focusScore;
  final double completionRate;
  final double averageQuizScore;
  final int sessionsPerWeek;
  final String focusLevel;
  final String productivityLevel;
  final bool isDark;

  const ProductivityCard({
    super.key,
    required this.focusScore,
    required this.completionRate,
    required this.averageQuizScore,
    required this.sessionsPerWeek,
    required this.focusLevel,
    required this.productivityLevel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus Score
          _buildMetricRow(
            'Focus Score',
            focusScore,
            focusLevel,
            _getFocusColor(focusScore),
          ),
          const SizedBox(height: 16),

          // Completion Rate
          _buildMetricRow(
            'Completion Rate',
            completionRate,
            '${completionRate.toStringAsFixed(1)}%',
            _getCompletionColor(completionRate),
          ),
          const SizedBox(height: 16),

          // Average Quiz Score
          _buildMetricRow(
            'Quiz Performance',
            averageQuizScore,
            '${averageQuizScore.toStringAsFixed(1)}%',
            _getQuizColor(averageQuizScore),
          ),
          const SizedBox(height: 16),

          // Sessions Per Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sessions/Week',
                style: TextStyle(fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    '$sessionsPerWeek',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      productivityLevel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    double value,
    String subtitle,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getFocusColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.info;
    if (score >= 40) return AppColors.warning;
    return Colors.red;
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.info;
    if (rate >= 40) return AppColors.warning;
    return Colors.red;
  }

  Color _getQuizColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.info;
    if (score >= 50) return AppColors.warning;
    return Colors.red;
  }
}
