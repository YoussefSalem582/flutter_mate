import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';
import '../widgets/widgets.dart';

/// Progress tracker page to monitor learning achievements.
///
/// Refactored into smaller, reusable widgets:
/// - OverallProgressCard: Large circular progress indicator
/// - StatsGrid: 2x2 grid of stat cards
/// - QuizStatsCard: Quiz performance metrics
/// - XPProgressCard: Level and XP progress
/// - WeeklyActivityChart: Bar chart of weekly activity
/// - ActivityItemCard: Individual activity entries
class ProgressTrackerPage extends GetView<ProgressTrackerController> {
  const ProgressTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'My Progress',
        icon: Icons.track_changes,
        iconColor: AppColors.success,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Calendar view will show your learning schedule',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Calendar',
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            // Refresh stats
            await Future.delayed(const Duration(seconds: 1));
            Get.snackbar(
              'Refreshed',
              'Stats updated successfully',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall Progress Card
              const OverallProgressCard().animate().fadeIn().scale(
                duration: 600.ms,
              ),

              const SizedBox(height: 20),

              // Stats Grid
              const StatsGrid()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 20),

              // Quiz Stats Card
              const QuizStatsCard()
                  .animate()
                  .fadeIn(delay: 250.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 24),

              // XP Progress
              const XPProgressCard()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 24),

              // Weekly Activity Chart
              const WeeklyActivityChart()
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideX(begin: 0.2),

              const SizedBox(height: 24),

              // Recent Activity Header
              Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Activity',
                    style: AppTextStyles.h3.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 16),

              // Activity Items List
              ...List.generate(controller.activity.length, (index) {
                final item = controller.activity[index];
                return ActivityItemCard(item: item)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
                    .slideX(begin: -0.2);
              }),

              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.roadmap),
        icon: const Icon(Icons.school),
        label: const Text('Continue Learning'),
        backgroundColor: AppColors.info,
      ).animate().fadeIn(delay: 800.ms).scale(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
