import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../controller/lesson_controller.dart';
import '../../../data/models/roadmap_stage.dart';
import 'advanced_mode_banner.dart';
import 'welcome_banner.dart';
import 'lesson_card.dart';

/// Lessons list widget with loading/empty states.
///
/// Features:
/// - Loading state with circular progress indicator
/// - Empty state with "No lessons available" message
/// - Lessons list with advanced mode and welcome banners
/// - Staggered entrance animations for lesson cards
///
/// State Management:
/// - Observes controller.isLoading for loading state
/// - Observes controller.lessons for data
/// - Observes controller.advancedMode for banner display
/// - Observes controller.completedCount for welcome banner
///
/// Layout:
/// - SliverPadding with 16px padding
/// - SliverList with builder pattern
/// - Conditional banners at index 0
/// - Animated lesson cards
class LessonsListWidget extends StatelessWidget {
  final LessonController controller;
  final RoadmapStage stage;

  const LessonsListWidget({
    super.key,
    required this.controller,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoading) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Empty state
      if (controller.lessons.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'No lessons available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      }

      // Lessons list
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildListItem(context, index),
            childCount: controller.lessons.length,
          ),
        ),
      );
    });
  }

  /// Build list item with optional banners for first item
  Widget _buildListItem(BuildContext context, int index) {
    final lesson = controller.lessons[index];
    final isCompleted = controller.isLessonCompleted(lesson.id);
    final canAccess = controller.canAccessLesson(lesson);

    // First item with advanced mode banner
    if (index == 0 && controller.advancedMode) {
      return Column(
        children: [
          AdvancedModeBanner(controller: controller),
          _buildAnimatedLessonCard(
            context,
            lesson,
            isCompleted,
            canAccess,
            index,
          ),
        ],
      );
    }

    // First item with welcome banner
    if (index == 0 &&
        controller.completedCount == 0 &&
        !controller.advancedMode) {
      return Column(
        children: [
          const WelcomeBanner(),
          _buildAnimatedLessonCard(
            context,
            lesson,
            isCompleted,
            canAccess,
            index,
            customAnimation: true,
          ),
        ],
      );
    }

    // Regular lesson card
    return _buildAnimatedLessonCard(
      context,
      lesson,
      isCompleted,
      canAccess,
      index,
    );
  }

  /// Build lesson card with staggered entrance animation
  Widget _buildAnimatedLessonCard(
    BuildContext context,
    dynamic lesson,
    bool isCompleted,
    bool canAccess,
    int index, {
    bool customAnimation = false,
  }) {
    final card = LessonCard(
      lesson: lesson,
      isCompleted: isCompleted,
      canAccess: canAccess,
      index: index,
      stage: stage,
      isAdvancedMode: controller.advancedMode,
      onRefresh: () async {
        await controller.loadLessonsByStage(stage.id);
      },
    );

    // Custom animation for welcome banner scenario
    if (customAnimation) {
      return card
          .animate()
          .fadeIn(duration: 300.ms, delay: 100.ms)
          .slideX(begin: 0.2, duration: 300.ms, delay: 100.ms);
    }

    // Regular staggered animation
    return card
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.2, duration: 300.ms, delay: (index * 50).ms);
  }
}
