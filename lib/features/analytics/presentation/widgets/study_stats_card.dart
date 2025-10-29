import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';

/// Card displaying key study time statistics
///
/// Shows:
/// - Today's study time
/// - This week's study time
/// - This month's study time
/// - Total study time
class StudyStatsCard extends StatelessWidget {
  final String todayTime;
  final String weekTime;
  final String monthTime;
  final String totalTime;
  final bool isDark;

  const StudyStatsCard({
    super.key,
    required this.todayTime,
    required this.weekTime,
    required this.monthTime,
    required this.totalTime,
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
      child: Column(
        children: [
          _buildStatRow(
            'Today',
            todayTime,
            Icons.today,
            AppColors.info,
          ),
          const Divider(height: 1),
          _buildStatRow(
            'This Week',
            weekTime,
            Icons.calendar_view_week,
            AppColors.success,
          ),
          const Divider(height: 1),
          _buildStatRow(
            'This Month',
            monthTime,
            Icons.calendar_month,
            AppColors.warning,
          ),
          const Divider(height: 1),
          _buildStatRow(
            'Total',
            totalTime,
            Icons.all_inclusive,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
