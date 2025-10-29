import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';

/// Calendar widget showing study streak and daily activity
///
/// Features:
/// - Current streak counter
/// - Longest streak display
/// - 7-week calendar grid (GitHub-style)
/// - Color-coded study intensity
/// - Today indicator
class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final Map<DateTime, Duration> dailyStudyTime;
  final bool isDark;

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyStudyTime,
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
          // Streak Stats
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  'Current Streak',
                  '$currentStreak',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakStat(
                  'Longest Streak',
                  '$longestStreak',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calendar Grid
          const Text(
            'Last 49 Days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCalendarGrid(),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Less', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 4),
              _buildLegendBox(Colors.grey[300]!),
              const SizedBox(width: 2),
              _buildLegendBox(AppColors.success.withOpacity(0.3)),
              const SizedBox(width: 2),
              _buildLegendBox(AppColors.success.withOpacity(0.6)),
              const SizedBox(width: 2),
              _buildLegendBox(AppColors.success),
              const SizedBox(width: 4),
              const Text('More', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 48));

    // Find max study time for scaling
    int maxMinutes = 1;
    dailyStudyTime.forEach((date, duration) {
      if (duration.inMinutes > maxMinutes) {
        maxMinutes = duration.inMinutes;
      }
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final studyTime = dailyStudyTime[normalizedDate] ?? Duration.zero;
        final isToday = normalizedDate.isAtSameMomentAs(today);

        return _buildDayBox(
          studyTime.inMinutes,
          maxMinutes,
          isToday,
        );
      },
    );
  }

  Widget _buildDayBox(int minutes, int maxMinutes, bool isToday) {
    Color color;

    if (minutes == 0) {
      color = Colors.grey[300]!;
    } else {
      final intensity = (minutes / maxMinutes).clamp(0.0, 1.0);
      if (intensity > 0.75) {
        color = AppColors.success;
      } else if (intensity > 0.5) {
        color = AppColors.success.withOpacity(0.6);
      } else if (intensity > 0.25) {
        color = AppColors.success.withOpacity(0.3);
      } else {
        color = AppColors.success.withOpacity(0.15);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: isToday ? Border.all(color: AppColors.info, width: 2) : null,
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
