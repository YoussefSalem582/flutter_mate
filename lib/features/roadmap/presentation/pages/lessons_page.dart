import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/roadmap_stage.dart';
import '../widgets/shared/lesson_app_bar.dart';
import '../widgets/lessons_page/widgets.dart';

/// Lessons page displaying all lessons for a specific roadmap stage.
///
/// **Features:**
/// - Stage-themed collapsible app bar with progress tracking
/// - Advanced mode toggle to unlock all lessons
/// - Pull-to-refresh functionality
/// - Conditional banners (welcome or advanced mode)
/// - Lesson cards with completion status, duration, and difficulty
/// - Navigation to lesson detail pages
///
/// **Architecture**: Widget composition pattern
/// The page acts as a coordinator, delegating rendering to specialized widgets:
/// - LessonAppBar: Shared collapsible header with stage branding
/// - CustomProgressBar: Stage progress indicator in app bar bottom
/// - LessonsListWidget: Main list with loading/empty states
///   - AdvancedModeBanner: Purple banner for unlocked mode
///   - WelcomeBanner: Greeting for first-time users
///   - LessonCard: Individual lesson items with metadata
///
/// **State Management**: GetX with LessonController
/// - Extends GetView<LessonController> for automatic controller access
/// - Controller manages lessons, completion state, and advanced mode
/// - Reactive UI updates using Obx in widgets
///
/// **Navigation Flow:**
/// 1. Receives RoadmapStage as Get.arguments
/// 2. Loads lessons for stage on page open
/// 3. Navigates to lesson detail on card tap
/// 4. Refreshes lesson list on return from detail page
class LessonsPage extends GetView<LessonController> {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = Get.arguments as RoadmapStage;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Load lessons when page opens
    controller.loadLessonsByStage(stage.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadLessonsByStage(stage.id);
          Get.snackbar(
            'Refreshed',
            'Progress updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        },
        child:
            isDesktop ? _buildDesktopLayout(stage) : _buildMobileLayout(stage),
      ),
    );
  }

  Widget _buildMobileLayout(RoadmapStage stage) {
    return CustomScrollView(
      slivers: [
        // Stage header with progress
        _buildStageAppBar(stage),

        // Lessons list with banners and cards
        LessonsListWidget(controller: controller, stage: stage),
      ],
    );
  }

  Widget _buildDesktopLayout(RoadmapStage stage) {
    return CustomScrollView(
      slivers: [
        // Stage header with progress
        _buildStageAppBar(stage),

        // Desktop: Constrain width and center content
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Build the lessons list in a constrained width
                    LessonsListWidget(controller: controller, stage: stage),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build stage app bar with progress indicator
  Widget _buildStageAppBar(RoadmapStage stage) {
    return LessonAppBar(
      title: stage.title,
      backgroundColor: stage.color,
      icon: stage.icon,
      actions: [
        // Advanced mode toggle
        Obx(() {
          final isAdvanced = controller.advancedMode;
          return IconButton(
            icon: Icon(
              isAdvanced ? Icons.rocket_launch : Icons.lock_open,
              color: Colors.white,
            ),
            tooltip: isAdvanced ? 'Advanced Mode ON' : 'Enable Advanced Mode',
            onPressed: () => controller.toggleAdvancedMode(),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: stage.color,
          child: Obx(() {
            final percentage = controller.completionPercentage;
            final completed = controller.completedCount;
            final total = controller.lessons.length;

            return CustomProgressBar(
              label: 'Progress: $completed/$total lessons',
              value: percentage,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.3),
              textColor: Colors.white,
            );
          }),
        ),
      ),
    );
  }
}
