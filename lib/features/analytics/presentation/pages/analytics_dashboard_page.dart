import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/features/analytics/controller/analytics_controller.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/productivity_card.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/streak_calendar.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/time_chart_widget.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/study_stats_card.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/insights_card.dart';
import 'package:flutter_mate/features/analytics/presentation/widgets/assessment_analytics_card.dart';

/// Analytics Dashboard Page - Comprehensive view of user learning analytics
///
/// Features:
/// - Study time overview (today, week, month, total)
/// - Streak tracking with calendar
/// - Productivity metrics (focus score, completion rate)
/// - Time distribution charts
/// - Personalized insights
/// - Weekly/monthly reports
class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAnalytics(),
            tooltip: 'Refresh analytics',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'weekly') {
                controller.generateWeeklyReport();
                _showReportDialog(context, 'Weekly Report', controller);
              } else if (value == 'monthly') {
                controller.generateMonthlyReport();
                _showReportDialog(context, 'Monthly Report', controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'weekly',
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_week),
                    SizedBox(width: 8),
                    Text('Weekly Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'monthly',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 8),
                    Text('Monthly Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAnalytics(),
          child: ResponsiveBuilder(
            mobile: _buildAnalyticsContent(context, controller, isDark),
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildAnalyticsContent(context, controller, isDark),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    AnalyticsController controller,
    bool isDark,
  ) {
    return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Study Time Overview
                _buildSectionTitle('Study Time', Icons.schedule),
                const SizedBox(height: 12),
                StudyStatsCard(
                  todayTime: controller.getTodayStudyTime(),
                  weekTime: controller.getWeekStudyTime(),
                  monthTime: controller.getMonthStudyTime(),
                  totalTime: controller.getTotalStudyTime(),
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Streak Calendar
                _buildSectionTitle('Study Streak', Icons.local_fire_department),
                const SizedBox(height: 12),
                StreakCalendar(
                  currentStreak: controller.getCurrentStreak(),
                  longestStreak: controller.getLongestStreak(),
                  dailyStudyTime:
                      controller.timeAnalytics.value?.dailyStudyTime ?? {},
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Productivity Metrics
                _buildSectionTitle('Productivity', Icons.trending_up),
                const SizedBox(height: 12),
                ProductivityCard(
                  focusScore: controller.getFocusScore(),
                  completionRate: controller.getCompletionRate(),
                  averageQuizScore: controller.getAverageQuizScore(),
                  sessionsPerWeek: controller.getSessionsPerWeek(),
                  focusLevel: controller.getFocusLevel(),
                  productivityLevel: controller.getProductivityLevel(),
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Skill Assessment Analytics
                _buildSectionTitle('Skill Assessments', Icons.assessment),
                const SizedBox(height: 12),
                AssessmentAnalyticsCard(isDark: isDark),
                const SizedBox(height: 24),

                // Time Distribution Chart
                _buildSectionTitle('Study Patterns', Icons.bar_chart),
                const SizedBox(height: 12),
                TimeChartWidget(
                  timeAnalytics: controller.timeAnalytics.value,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Personalized Insights
                _buildSectionTitle('Insights', Icons.lightbulb_outline),
                const SizedBox(height: 12),
                InsightsCard(
                  insights: controller.personalizedInsights,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Recent Sessions
                if (controller.recentSessions.isNotEmpty) ...[
                  _buildSectionTitle('Recent Sessions', Icons.history),
                  const SizedBox(height: 12),
                  _buildRecentSessions(controller, isDark),
                  const SizedBox(height: 24),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.info),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions(AnalyticsController controller, bool isDark) {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentSessions.length.clamp(0, 5),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final session = controller.recentSessions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.info.withOpacity(0.1),
              child: Icon(
                session.completed ? Icons.check_circle : Icons.schedule,
                color:
                    session.completed ? AppColors.success : AppColors.warning,
                size: 20,
              ),
            ),
            title: Text(
              session.lessonTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${session.category} • ${_formatSessionTime(session.startTime)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Text(
              '${session.durationInMinutes} min',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatSessionTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showReportDialog(
    BuildContext context,
    String title,
    AnalyticsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final report = title.contains('Weekly')
              ? controller.weeklyReport
              : controller.monthlyReport;

          if (report.isEmpty) {
            return const Text('No data available for this period');
          }

          final data = report['weekData'] ?? report['monthData'] ?? {};
          final prevData =
              report['previousWeekData'] ?? report['previousMonthData'] ?? {};

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportItem(
                  'Study Time',
                  '${data['totalStudyTime'] ?? 0} min',
                  _calculateChange(
                    data['totalStudyTime'],
                    prevData['totalStudyTime'],
                  ),
                ),
                const Divider(),
                _buildReportItem(
                  'Sessions',
                  '${data['sessionCount'] ?? 0}',
                  _calculateChange(
                    data['sessionCount'],
                    prevData['sessionCount'],
                  ),
                ),
                const Divider(),
                _buildReportItem(
                  'Avg Quiz Score',
                  '${(data['averageScore'] ?? 0.0).toStringAsFixed(1)}%',
                  _calculateChange(
                    data['averageScore'],
                    prevData['averageScore'],
                  ),
                ),
                const Divider(),
                _buildReportItem(
                  'Completion Rate',
                  '${(data['completionRate'] ?? 0.0).toStringAsFixed(1)}%',
                  _calculateChange(
                    data['completionRate'],
                    prevData['completionRate'],
                  ),
                ),
                if (data['topCategory'] != null) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.star, color: AppColors.warning),
                    title: const Text('Top Category'),
                    subtitle: Text(data['topCategory']),
                  ),
                ],
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String label, String value, double change) {
    final isPositive = change > 0;
    final isNeutral = change == 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: isNeutral
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? AppColors.success : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive ? AppColors.success : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  double _calculateChange(dynamic current, dynamic previous) {
    if (current == null || previous == null || previous == 0) return 0.0;
    final curr = current is int ? current.toDouble() : current as double;
    final prev = previous is int ? previous.toDouble() : previous as double;
    return ((curr - prev) / prev) * 100;
  }
}
