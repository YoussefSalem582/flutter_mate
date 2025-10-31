import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/routes/app_routes.dart';
import '../../controller/assessment_controller.dart';
import '../../data/models/skill_assessment.dart';

/// Assessment History Page - Shows user's past skill assessments
class AssessmentHistoryPage extends StatelessWidget {
  const AssessmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssessmentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load assessments when page is built (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.assessments.isEmpty && !controller.isLoading.value) {
        controller.loadUserAssessments();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => controller.startAssessment(),
            tooltip: 'Take New Assessment',
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildContent(context, controller, isDark),
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: _buildContent(context, controller, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AssessmentController controller,
    bool isDark,
  ) {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Empty state
      if (controller.assessments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 80,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No Assessments Yet',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              Text(
                'Take your first skill assessment to track your progress',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => controller.startAssessment(),
                icon: const Icon(Icons.assessment),
                label: const Text('Start Assessment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.info,
                ),
              ),
            ],
          ),
        );
      }

      // Display assessments
      return SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(controller, isDark),
            const SizedBox(height: 24),

            // Assessment list
            Text(
              'Assessment History (${controller.assessments.length})',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),

            ...controller.assessments.map((assessment) {
              return _buildAssessmentCard(
                context,
                assessment,
                isDark,
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(AssessmentController controller, bool isDark) {
    final assessments = controller.assessments;
    final totalAssessments = assessments.length;
    final avgScore = assessments.isEmpty
        ? 0.0
        : assessments.map((a) => a.overallPercentage).reduce((a, b) => a + b) /
            totalAssessments;
    final latestSkillLevel =
        assessments.isEmpty ? null : assessments.first.overallSkillLevel;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.info,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Progress Summary',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Tests',
                    totalAssessments.toString(),
                    Icons.quiz,
                    AppColors.info,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Score',
                    '${avgScore.toStringAsFixed(1)}%',
                    Icons.grade,
                    AppColors.warning,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Current Level',
                    latestSkillLevel?.displayName ?? 'N/A',
                    Icons.workspace_premium,
                    AppColors.success,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    SkillAssessment assessment,
    bool isDark,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final percentage = assessment.overallPercentage;
    final skillLevel = assessment.overallSkillLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to detailed results
          Get.toNamed(AppRoutes.assessmentResults, arguments: assessment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Date and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(assessment.completedAt),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(assessment.completedAt),
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skill level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSkillLevelColor(skillLevel).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skillLevel.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          skillLevel.displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getSkillLevelColor(skillLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Score progress bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              '${assessment.totalScore}/${assessment.maxScore} (${percentage.toStringAsFixed(1)}%)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(percentage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _buildStatChip(
                    Icons.check_circle_outline,
                    '${assessment.correctAnswers}/${assessment.questionsAnswered} Correct',
                    AppColors.success,
                    isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.timer_outlined,
                    _formatDuration(assessment.timeTaken),
                    AppColors.info,
                    isDark,
                  ),
                ],
              ),

              // Top categories
              if (assessment.strongAreas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: assessment.strongAreas.take(3).map((category) {
                    return Chip(
                      label: Text(
                        category,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? color.withOpacity(0.9) : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkillLevelColor(dynamic skillLevel) {
    final name = skillLevel.name.toString().toLowerCase();
    if (name.contains('expert') || name.contains('master')) {
      return Colors.purple;
    } else if (name.contains('advanced')) {
      return AppColors.success;
    } else if (name.contains('intermediate')) {
      return AppColors.info;
    } else if (name.contains('beginner')) {
      return AppColors.warning;
    }
    return Colors.grey;
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.info;
    if (percentage >= 40) return AppColors.warning;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
