import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
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
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

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
            await Future.delayed(const Duration(seconds: 1));
            Get.snackbar(
              'Refreshed',
              'Stats updated successfully',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
          child: ResponsiveBuilder(
            mobile: _buildMobileLayout(context, padding),
            desktop: _buildDesktopLayout(context, padding),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.roadmap),
        icon: const Icon(Icons.school),
        label: const Text('Continue Learning'),
        backgroundColor: AppColors.info,
      ).animate().fadeIn(delay: 800.ms).scale(),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentIndex: 1),
    );
  }

  /// Mobile layout - Single column vertical scroll
  Widget _buildMobileLayout(BuildContext context, double padding) {
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        _buildWelcomeBanner(context),
        const SizedBox(height: 20),
        const OverallProgressCard().animate().fadeIn().scale(duration: 600.ms),
        const SizedBox(height: 20),
        const StatsGrid().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),
        const QuizStatsCard()
            .animate()
            .fadeIn(delay: 250.ms)
            .slideX(begin: -0.2),
        const SizedBox(height: 24),
        const XPProgressCard()
            .animate()
            .fadeIn(delay: 300.ms)
            .slideX(begin: -0.2),
        const SizedBox(height: 24),
        const WeeklyActivityChart()
            .animate()
            .fadeIn(delay: 400.ms)
            .slideX(begin: 0.2),
        const SizedBox(height: 24),
        _buildRecentActivity(context),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Desktop layout - Two column grid
  Widget _buildDesktopLayout(BuildContext context, double padding) {
    return ListView(
      padding: EdgeInsets.all(padding * 1.5),
      children: [
        _buildWelcomeBanner(context),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const OverallProgressCard()
                      .animate()
                      .fadeIn()
                      .scale(duration: 600.ms),
                  const SizedBox(height: 24),
                  const QuizStatsCard()
                      .animate()
                      .fadeIn(delay: 250.ms)
                      .slideX(begin: -0.2),
                  const SizedBox(height: 24),
                  const XPProgressCard()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideX(begin: -0.2),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right column
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const StatsGrid()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: 24),
                  const WeeklyActivityChart()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideX(begin: 0.2),
                  const SizedBox(height: 24),
                  _buildRecentActivity(context),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Recent activity section (shared between layouts)
  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ...List.generate(controller.activity.length, (index) {
          final item = controller.activity[index];
          return ActivityItemCard(item: item)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
              .slideX(begin: -0.2);
        }),
      ],
    );
  }

  /// Welcome banner with personalized greeting
  Widget _buildWelcomeBanner(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final isGuest = authController.isGuest;

    String greeting = 'Welcome to Your Progress';
    if (user != null && !isGuest) {
      final name = user.displayName ?? user.email.split('@')[0];
      greeting = 'Welcome back, $name!';
    } else if (isGuest) {
      greeting = 'Welcome, Guest!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.7),
            AppColors.info.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your learning journey',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }
}
