import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/roadmap_stage.dart';
import '../../data/models/lesson.dart';
import '../../controller/roadmap_controller.dart';
import '../../controller/lesson_controller.dart';

/// Detailed stage view showing all topics, progress, and related lessons
class StageDetailPage extends StatelessWidget {
  const StageDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roadmapController = Get.find<RoadmapController>();
    final lessonController = Get.find<LessonController>();

    // Get stage from arguments
    final RoadmapStage stage = Get.arguments as RoadmapStage;
    final progress = roadmapController.stageProgress(stage.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header with stage info
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: stage.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                stage.title,
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      stage.color,
                      stage.color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _GridPatternPainter(),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                stage.icon,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Subtitle
                            Text(
                              stage.subtitle,
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Progress
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      minHeight: 8,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.3),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${progress.toInt()}%',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: stage.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: ResponsiveBuilder(
              mobile: _buildContent(
                context,
                stage,
                lessonController,
                isDark,
                ResponsiveUtils.getResponsivePadding(context),
              ),
              desktop: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _buildContent(
                    context,
                    stage,
                    lessonController,
                    isDark,
                    32.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RoadmapStage stage,
    LessonController lessonController,
    bool isDark,
    double padding,
  ) {
    // Get lessons for this stage
    final stageLessons = lessonController.lessons
        .where((lesson) => lesson.stageId == stage.id)
        .toList();

    // Get stats
    final totalLessons = stageLessons.length;
    final completedLessons = stageLessons.where((lesson) {
      return lessonController.isLessonCompleted(lesson.id);
    }).length;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          _buildStatsRow(
                  totalLessons, completedLessons, stage.topics.length, isDark)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 32),

          // Topics section
          Text(
            'Learning Topics',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Master these key concepts to complete this stage',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Topics grid
          _buildTopicsGrid(stage.topics, stage.color, isDark),

          const SizedBox(height: 32),

          // Lessons section
          if (stageLessons.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Lessons',
                  style: AppTextStyles.h3,
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.lessons, arguments: stage);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLessonsList(
                stageLessons, lessonController, stage.color, isDark),
          ],

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(stage),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    int totalLessons,
    int completedLessons,
    int topicsCount,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.library_books,
            label: 'Lessons',
            value: '$completedLessons/$totalLessons',
            color: AppColors.info,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.topic,
            label: 'Topics',
            value: '$topicsCount',
            color: AppColors.warning,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            label: 'Est. Time',
            value: '${totalLessons * 30}m',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsGrid(List<String> topics, Color stageColor, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildTopicCard(
          topics[index],
          stageColor,
          isDark,
          index,
        ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildTopicCard(
      String topic, Color stageColor, bool isDark, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stageColor.withOpacity(0.1),
            stageColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stageColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stageColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getTopicIcon(index),
              color: stageColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTopicIcon(int index) {
    final icons = [
      Icons.code,
      Icons.widgets,
      Icons.view_quilt,
      Icons.navigation,
      Icons.settings_input_component,
      Icons.api,
      Icons.storage,
      Icons.lock,
      Icons.architecture,
      Icons.bug_report,
      Icons.speed,
      Icons.cloud_upload,
    ];
    return icons[index % icons.length];
  }

  Widget _buildLessonsList(
    List<Lesson> lessons,
    LessonController controller,
    Color stageColor,
    bool isDark,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length > 5 ? 5 : lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isCompleted = controller.isLessonCompleted(lesson.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.5)
                  : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.lessonDetail, arguments: lesson);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lesson number badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : stageColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              '${lesson.order}',
                              style: AppTextStyles.h4.copyWith(
                                color: stageColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.duration} min',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(lesson.difficulty)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lesson.difficulty.toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  color: _getDifficultyColor(lesson.difficulty),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1, end: 0);
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return const Color(0xFFE53935); // Red color for hard difficulty
      default:
        return AppColors.info;
    }
  }

  Widget _buildActionButtons(RoadmapStage stage) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.lessons, arguments: stage);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Learning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: stage.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.skillAssessment);
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Take Assessment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: stage.color,
              side: BorderSide(color: stage.color, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for grid background pattern
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
