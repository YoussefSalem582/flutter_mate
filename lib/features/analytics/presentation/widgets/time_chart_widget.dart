import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/features/analytics/data/models/time_analytics.dart';

/// Widget displaying study time distribution charts
///
/// Shows:
/// - Bar chart of study hours (24-hour distribution)
/// - Bar chart of study days (weekly distribution)
/// - Category breakdown pie chart
class TimeChartWidget extends StatelessWidget {
  final TimeAnalytics? timeAnalytics;
  final bool isDark;

  const TimeChartWidget({
    super.key,
    required this.timeAnalytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (timeAnalytics == null || timeAnalytics!.totalSessions == 0) {
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
            'No study data yet.\nStart learning to see your patterns!',
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Hours Distribution
          const Text(
            'Study Hours (24h)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: _buildHoursChart(),
          ),
          const SizedBox(height: 24),

          // Study Days Distribution
          const Text(
            'Study Days (Week)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: _buildDaysChart(),
          ),
          const SizedBox(height: 16),

          // Peak Times
          _buildPeakTimeInfo(),
        ],
      ),
    );
  }

  Widget _buildHoursChart() {
    final hours = timeAnalytics!.studyHoursDistribution;
    final maxValue = hours.reduce((a, b) => a > b ? a : b).toDouble();

    if (maxValue == 0) {
      return const Center(child: Text('No hourly data yet'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();
                if (hour % 6 == 0) {
                  return Text(
                    '${hour}h',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          24,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hours[index].toDouble(),
                color: _getHourColor(index),
                width: 6,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysChart() {
    final days = timeAnalytics!.studyDaysDistribution;
    final maxValue = days.reduce((a, b) => a > b ? a : b).toDouble();

    if (maxValue == 0) {
      return const Center(child: Text('No daily data yet'));
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dayNames.length) {
                  return Text(
                    dayNames[index],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          7,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: days[index].toDouble(),
                color: AppColors.success,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeakTimeInfo() {
    final peakHour = timeAnalytics!.getMostProductiveHour();
    final peakDay = timeAnalytics!.getMostProductiveDay();
    const dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppColors.info, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Peak: ${dayNames[peakDay]} at $peakHour:00',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHourColor(int hour) {
    if (hour >= 6 && hour < 12) {
      return Colors.amber; // Morning
    } else if (hour >= 12 && hour < 18) {
      return AppColors.info; // Afternoon
    } else if (hour >= 18 && hour < 22) {
      return Colors.purple; // Evening
    } else {
      return Colors.indigo; // Night
    }
  }
}
