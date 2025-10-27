import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/lesson.dart';

/// Exercise bottom sheet showing practice tasks for the lesson.
///
/// Features:
/// - Scrollable bottom sheet
/// - Gradient header
/// - Exercise cards with tips
/// - Study tips section
/// - Lesson-specific exercises
class ExerciseBottomSheet {
  /// Show the exercise bottom sheet
  static void show(BuildContext context, Lesson lesson) {
    final exercises = _getExercisesForLesson(lesson.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practice Exercises',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lesson.title,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Exercise cards
                    ...exercises.map((exercise) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    exercise['icon'] as IconData,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercise['title'] as String,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exercise['description'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            if (exercise.containsKey('tip')) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_rounded,
                                      color: AppColors.info,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        exercise['tip'] as String,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.info,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),

                    // Study tips section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tips_and_updates_rounded,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Study Tips',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip(
                            'Open your code editor and try each exercise',
                          ),
                          _buildTip(
                            'Don\'t worry about mistakes - they help you learn',
                          ),
                          _buildTip('Experiment with different solutions'),
                          _buildTip(
                            'Review the lesson content if you get stuck',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a single tip row
  static Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Get exercises based on lesson ID
  static List<Map<String, dynamic>> _getExercisesForLesson(String lessonId) {
    switch (lessonId) {
      case 'b1': // What is Flutter
        return [
          {
            'icon': Icons.search_rounded,
            'title': 'Research Flutter',
            'description':
                'Visit flutter.dev and explore the official documentation. Read about Flutter\'s features and benefits.',
            'tip': 'Take notes on key Flutter features you discover',
          },
          {
            'icon': Icons.compare_arrows_rounded,
            'title': 'Compare with Others',
            'description':
                'Research how Flutter compares to other frameworks like React Native or native development.',
            'tip': 'Make a list of pros and cons',
          },
          {
            'icon': Icons.devices_rounded,
            'title': 'Check Platform Support',
            'description':
                'Explore which platforms Flutter supports and see examples of apps built with Flutter.',
            'tip': 'Look for apps you already use that are built with Flutter',
          },
        ];
      case 'b2': // Setup Development Environment
        return [
          {
            'icon': Icons.download_rounded,
            'title': 'Install Flutter SDK',
            'description':
                'Download and install the Flutter SDK for your operating system following the official guide.',
            'tip': 'Make sure to add Flutter to your PATH',
          },
          {
            'icon': Icons.terminal_rounded,
            'title': 'Run Flutter Doctor',
            'description':
                'Open a terminal and run "flutter doctor" to check your installation and fix any issues.',
            'tip': 'Green checkmarks mean everything is setup correctly',
          },
          {
            'icon': Icons.code_rounded,
            'title': 'Setup Your IDE',
            'description':
                'Install either VS Code or Android Studio and add the Flutter and Dart plugins.',
            'tip': 'VS Code is lighter, Android Studio has more tools',
          },
        ];
      default:
        return [
          {
            'icon': Icons.code_rounded,
            'title': 'Practice Coding',
            'description':
                'Apply the concepts from this lesson by writing your own code examples.',
            'tip': 'Start small and build up complexity',
          },
          {
            'icon': Icons.build_rounded,
            'title': 'Build Something',
            'description':
                'Create a small project that uses what you\'ve learned in this lesson.',
            'tip': 'Don\'t aim for perfection, aim for completion',
          },
          {
            'icon': Icons.share_rounded,
            'title': 'Share Your Work',
            'description':
                'Show your code to others or explain what you\'ve learned to reinforce your knowledge.',
            'tip': 'Teaching others is the best way to learn',
          },
        ];
    }
  }
}
