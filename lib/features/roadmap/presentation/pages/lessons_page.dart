import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../controller/lesson_controller.dart';
import '../../data/models/roadmap_stage.dart';
import '../widgets/lessons_page/widgets.dart';
import '../widgets/lessons_page/advanced_mode_banner.dart';
import '../widgets/lessons_page/welcome_banner.dart';
import '../widgets/lessons_page/lesson_card.dart';

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
    return Obx(() {
      // Loading state
      if (controller.isLoading) {
        return CustomScrollView(
          slivers: [
            _buildStageAppBar(stage),
            SliverFillRemaining(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        );
      }

      // Empty state
      if (controller.lessons.isEmpty) {
        return CustomScrollView(
          slivers: [
            _buildStageAppBar(stage),
            SliverFillRemaining(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: const Text(
                    'No lessons available',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Content state with lessons
      return CustomScrollView(
        slivers: [
          _buildStageAppBar(stage),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            sliver: SliverMainAxisGroup(
              slivers: _buildDesktopLessonsContent(stage),
            ),
          ),
        ],
      );
    });
  }

  /// Build desktop lessons content as list of slivers
  List<Widget> _buildDesktopLessonsContent(RoadmapStage stage) {
    final slivers = <Widget>[];

    // Add Welcome or Advanced Mode Banner
    final isAdvanced = controller.advancedMode;
    final completed = controller.completedCount;

    if (isAdvanced) {
      slivers.add(
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.only(bottom: 24),
              child: AdvancedModeBanner(controller: controller),
            ),
          ),
        ),
      );
    } else if (completed == 0) {
      slivers.add(
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.only(bottom: 24),
              child: const WelcomeBanner(),
            ),
          ),
        ),
      );
    }

    // Add lessons grid
    slivers.add(_buildLessonsGrid(stage));

    return slivers;
  }

  /// Build responsive lessons grid as sliver
  Widget _buildLessonsGrid(RoadmapStage stage) {
    final lessons = controller.lessons.toList();
    final isAdvanced = controller.advancedMode;

    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = lessons[index];
            final isCompleted = controller.isLessonCompleted(lesson.id);
            final canAccess = controller.canAccessLesson(lesson);

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: LessonCard(
                  lesson: lesson,
                  isCompleted: isCompleted,
                  canAccess: canAccess,
                  index: index,
                  stage: stage,
                  isAdvancedMode: isAdvanced,
                  onRefresh: () async {
                    await controller.loadLessonsByStage(stage.id);
                  },
                ),
              ),
            );
          },
          childCount: lessons.length,
        ),
      ),
    );
  }

  /// Build stage app bar with progress indicator
  Widget _buildStageAppBar(RoadmapStage stage) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = ResponsiveUtils.isDesktop(context);

        return SliverAppBar(
          expandedHeight: isDesktop ? 240 : 200,
          floating: false,
          pinned: true,
          backgroundColor: stage.color,
          flexibleSpace: FlexibleSpaceBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(stage.icon, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    stage.title,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stage.color,
                        stage.color.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                // Large background icon
                Positioned(
                  right: -50,
                  bottom: -30,
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(
                      stage.icon,
                      size: 200,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Advanced mode toggle with better desktop styling
            Obx(() {
              final isAdvanced = controller.advancedMode;
              return Padding(
                padding: EdgeInsets.only(right: isDesktop ? 32 : 8),
                child: isDesktop
                    ? _buildDesktopAdvancedModeButton(isAdvanced, stage.color)
                    : IconButton(
                        icon: Icon(
                          isAdvanced ? Icons.rocket_launch : Icons.lock_open,
                          color: Colors.white,
                        ),
                        tooltip: isAdvanced
                            ? 'Advanced Mode ON'
                            : 'Enable Advanced Mode',
                        onPressed: () => controller.toggleAdvancedMode(),
                      ),
              );
            }),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(isDesktop ? 80 : 60),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              color: stage.color,
              child: Obx(() {
                final percentage = controller.completionPercentage;
                final completed = controller.completedCount;
                final total = controller.lessons.length;

                return Column(
                  children: [
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stage Progress',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$completed of $total lessons completed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    CustomProgressBar(
                      label: isDesktop
                          ? ''
                          : 'Progress: $completed/$total lessons',
                      value: percentage,
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      textColor: Colors.white,
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// Build desktop-styled advanced mode button
  Widget _buildDesktopAdvancedModeButton(bool isAdvanced, Color stageColor) {
    return ElevatedButton.icon(
      onPressed: () => controller.toggleAdvancedMode(),
      icon: Icon(
        isAdvanced ? Icons.rocket_launch : Icons.lock_open,
        size: 20,
      ),
      label: Text(
        isAdvanced ? 'Advanced Mode ON' : 'Enable Advanced Mode',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
    );
  }
}
