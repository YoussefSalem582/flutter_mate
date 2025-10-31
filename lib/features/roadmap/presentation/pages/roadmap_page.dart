import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/presentation/widgets/roadmap_page/widgets.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';
import 'package:flutter_mate/shared/widgets/desktop_sidebar.dart';
import 'package:flutter_mate/shared/widgets/quick_access_cards.dart';

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
    final authController = Get.find<AuthController>();

    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        // Guest user banner
        Obx(() {
          if (authController.isGuest) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGuestBanner(isDark),
            );
          }
          return const SizedBox.shrink();
        }),
        RoadmapHeader(overallProgress: overallProgress),
        const SizedBox(height: 24),
        StatsSummary(isDark: isDark),
        const SizedBox(height: 24),

        // Quick Access Cards
        QuickAccessCards(
          showTitle: true,
          cardHeight: 100,
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        // Flutter Developer Roadmap Banner
        _buildRoadmapGuideBanner(isDark),
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
    final authController = Get.find<AuthController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed sidebar with navigation
        DesktopSidebar(
          isDark: isDark,
          topContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest user banner
              Obx(() {
                if (authController.isGuest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildGuestBanner(isDark),
                  );
                }
                return const SizedBox.shrink();
              }),
              RoadmapHeader(overallProgress: overallProgress),
              const SizedBox(height: 32),
              StatsSummary(isDark: isDark),
            ],
          ),
        ),

        // Main content area with stages
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(padding * 1.5),
            children: [
              // Flutter Developer Roadmap Banner
              _buildRoadmapGuideBanner(isDark),
              const SizedBox(height: 24),

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

  /// Flutter Developer Roadmap guide banner
  Widget _buildRoadmapGuideBanner(bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.flutterDeveloperRoadmap),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.route,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How to Become a Flutter Developer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore the complete roadmap from beginner to expert',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Guest user banner prompting to create an account
  Widget _buildGuestBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.8),
            AppColors.warning,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guest Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create an account to save your progress',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.onboarding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.warning,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
