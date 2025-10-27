import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header with overall progress
            RoadmapHeader(overallProgress: overallProgress),
            const SizedBox(height: 24),

            // Stats summary (Beginner/Intermediate/Advanced)
            StatsSummary(isDark: isDark),
            const SizedBox(height: 32),

            // Learning stages list
            StagesList(
              stages: controller.stages,
              isDark: isDark,
              getStageProgress: controller.stageProgress,
            ),

            const SizedBox(height: 100), // Bottom padding
          ],
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
