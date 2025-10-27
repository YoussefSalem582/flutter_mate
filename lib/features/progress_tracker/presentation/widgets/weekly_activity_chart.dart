import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';

/// Card displaying weekly activity bar chart.
class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quizService = Get.find<QuizTrackingService>();

    return Obx(() {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final days = List.generate(
        7,
        (index) => startOfDay.subtract(Duration(days: 6 - index)),
      );
      final quizResults = quizService.quizResults.values.toList();

      final dailyCounts = List.generate(7, (index) {
        final dayStart = days[index];
        final dayEnd = dayStart.add(const Duration(days: 1));
        return quizResults.where((result) {
          final timestamp = result.timestamp;
          final isOnOrAfterStart = !timestamp.isBefore(dayStart);
          final isBeforeEnd = timestamp.isBefore(dayEnd);
          return isOnOrAfterStart && isBeforeEnd;
        }).length;
      });

      final maxCount = dailyCounts.fold<int>(
        0,
        (max, value) => value > max ? value : max,
      );

      final activity = dailyCounts
          .map((count) => maxCount == 0 ? 0.0 : count / maxCount)
          .toList();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Weekly Activity',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on quiz completions from the last 7 days',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            if (maxCount == 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Complete a quiz to start building your activity streak.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final weekdayIndex = days[index].weekday % 7;
                  const weekdayLabels = [
                    'Sun',
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                  ];
                  final dayLabel = weekdayLabels[weekdayIndex];
                  final count = dailyCounts[index];
                  return Column(
                    children: [
                      Container(
                            width: 32,
                            height: 80 * activity[index],
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.info,
                                  AppColors.info.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                          .animate(delay: Duration(milliseconds: index * 50))
                          .scaleY(begin: 0, duration: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        dayLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
          ],
        ),
      );
    });
  }
}
