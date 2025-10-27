import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/presentation/widgets/roadmap_page/widgets.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';

/// Roadmap page showing learning path from beginner to advanced.
///
/// Responsibilities:
/// - Coordinate navigation and app bar
/// - Calculate overall progress
/// - Delegate rendering to specialized widgets
/// - Handle FAB and bottom navigation
///
/// Architecture:
/// - Page acts as coordinator (108 lines)
/// - Visual rendering delegated to widgets:
///   * RoadmapHeader - gradient header with overall progress
///   * StatsSummary - 3 difficulty stat cards
///   * StagesList - list of learning stages with progress
/// - GetX for state management (Obx wrapper)
///
/// Navigation:
/// - Profile button → profile page
/// - Stage cards → lessons page (via StageCard widget)
/// - FAB → Continue learning (snackbar for now)
/// - Bottom nav → Dashboard/Roadmap/Playground/Profile
class RoadmapPage extends GetView<RoadmapController> {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Roadmap',
        icon: Icons.map,
        iconColor: AppColors.info,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Get.snackbar(
                'Filter',
                'Filter options coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stages.isEmpty) {
          return const Center(child: Text('No stages available'));
        }

        final overallProgress = controller.stages.isEmpty
            ? 0.0
            : controller.stages.fold<double>(
                  0.0,
                  (sum, stage) => sum + controller.stageProgress(stage.id),
                ) /
                controller.stages.length;

        return ResponsiveBuilder(
          mobile: _buildMobileLayout(overallProgress, isDark, padding),
          desktop: _buildDesktopLayout(overallProgress, isDark, padding),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar(
            'Quick Start',
            'Continue from where you left off',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Continue Learning'),
        backgroundColor: AppColors.success,
      ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentIndex: 0),
    );
  }

  /// Mobile layout - Vertical scrolling list
  Widget _buildMobileLayout(
      double overallProgress, bool isDark, double padding) {
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        RoadmapHeader(overallProgress: overallProgress),
        const SizedBox(height: 24),
        StatsSummary(isDark: isDark),
        const SizedBox(height: 32),
        StagesList(
          stages: controller.stages,
          isDark: isDark,
          getStageProgress: controller.stageProgress,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Desktop layout - Two column layout with fixed sidebar
  Widget _buildDesktopLayout(
      double overallProgress, bool isDark, double padding) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar with header and stats
        Container(
          width: 350,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoadmapHeader(overallProgress: overallProgress),
              const SizedBox(height: 32),
              StatsSummary(isDark: isDark),
              const SizedBox(height: 32),
              // Desktop navigation
              _buildDesktopNavigation(isDark),
            ],
          ),
        ),

        // Main content area with stages
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(padding * 1.5),
            children: [
              StagesList(
                stages: controller.stages,
                isDark: isDark,
                getStageProgress: controller.stageProgress,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  /// Desktop navigation menu
  Widget _buildDesktopNavigation(bool isDark) {
    final menuItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/roadmap'},
      {
        'icon': Icons.track_changes,
        'label': 'Progress',
        'route': '/progress-tracker'
      },
      {'icon': Icons.code, 'label': 'Playground', 'route': '/code-playground'},
      {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
    ];

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: menuItems.map((item) {
        final isActive = Get.currentRoute == item['route'];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: isActive ? primaryColor : null,
          ),
          title: Text(
            item['label'] as String,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryColor : null,
            ),
          ),
          selected: isActive,
          onTap: () => Get.toNamed(item['route'] as String),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}
