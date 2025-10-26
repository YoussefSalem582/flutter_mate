import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';

/// Roadmap page showing learning path from beginner to advanced
class RoadmapPage extends GetView<RoadmapController> {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map, color: AppColors.info),
            ),
            const SizedBox(width: 12),
            const Text('Learning Roadmap'),
          ],
        ),
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final overallProgress = controller.stages.isEmpty
            ? 0.0
            : controller.stages
                      .map((s) => controller.stageProgress(s.id))
                      .reduce((a, b) => a + b) /
                  controller.stages.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            _buildHeader(
              context,
              isDark,
              overallProgress,
            ).animate().fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 24),

            // Stats Summary
            _buildStatsSummary(
              context,
              isDark,
            ).animate().fadeIn(delay: 200.ms).scale(),

            const SizedBox(height: 32),

            // Stages Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Learning Stages',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${controller.stages.length} Stages',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Stages List
            ...List.generate(controller.stages.length, (index) {
              final stage = controller.stages[index];
              final progress = controller.stageProgress(stage.id);
              return Column(
                children: [
                  _buildEnhancedStageCard(
                        context,
                        stage,
                        progress,
                        isDark,
                        index,
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                      )
                      .slideX(begin: index % 2 == 0 ? -0.2 : 0.2),
                  if (index != controller.stages.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            }),

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
      ).animate().fadeIn(delay: 800.ms).scale(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    double overallProgress,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.progressIntermediateStart,
            AppColors.progressIntermediateEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Learning Journey',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master Flutter step by step',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Progress',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: overallProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Beginner',
            '8 Lessons',
            Icons.school,
            AppColors.success,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Intermediate',
            '9 Lessons',
            Icons.trending_up,
            AppColors.info,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Advanced',
            '5 Lessons',
            Icons.military_tech,
            Colors.purple,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStageCard(
    BuildContext context,
    RoadmapStage stage,
    double progress,
    bool isDark,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stage.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: stage.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/lessons', arguments: stage),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [stage.color, stage.color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: stage.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(stage.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stage.title,
                                  style: AppTextStyles.h3.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stage.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: stage.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage.subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(stage.color),
                  ),
                ),
                const SizedBox(height: 16),
                // Topics
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stage.topics.take(4).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stage.color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: stage.color.withOpacity(0.2)),
                      ),
                      child: Text(
                        topic,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (stage.topics.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${stage.topics.length - 4} more topics',
                      style: AppTextStyles.caption.copyWith(
                        color: stage.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to view lessons',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: stage.color, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assistant),
          label: 'Assistant',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on roadmap
            break;
          case 1:
            Get.toNamed(AppRoutes.progressTracker);
            break;
          case 2:
            Get.toNamed(AppRoutes.assistant);
            break;
          case 3:
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
    );
  }
}
