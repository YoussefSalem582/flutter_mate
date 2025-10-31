import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../controller/assessment_controller.dart';
import '../../data/models/skill_assessment.dart';
import '../widgets/skill_level_indicator.dart';
import '../widgets/skill_radar_chart.dart';

class AssessmentResultsPage extends StatelessWidget {
  const AssessmentResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SkillAssessment assessment = Get.arguments as SkillAssessment;
    final controller = Get.find<AssessmentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildResultsContent(context, assessment, controller, isDark),
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child:
                _buildResultsContent(context, assessment, controller, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent(
    BuildContext context,
    SkillAssessment assessment,
    AssessmentController controller,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Congratulations card
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.info, AppColors.info.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Assessment Complete!',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You earned ${assessment.totalScore} out of ${assessment.maxScore} XP',
                    style:
                        AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overall stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Accuracy',
                  '${assessment.accuracy.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Questions',
                  '${assessment.correctAnswers}/${assessment.questionsAnswered}',
                  Icons.quiz,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Time Taken',
                  _formatDuration(assessment.timeTaken),
                  Icons.timer,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Skill Level',
                  assessment.overallSkillLevel.displayName,
                  Icons.workspace_premium,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Overall skill level
          Text('Overall Skill Level', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          SkillLevelIndicator(
            skillLevel: assessment.overallSkillLevel,
            percentage: assessment.overallPercentage,
            showDetails: true,
          ),
          const SizedBox(height: 32),

          // Skill radar chart
          Text('Skills Overview', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          SkillRadarChart(assessment: assessment),
          const SizedBox(height: 32),

          // Category breakdown
          Text('Category Performance', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ...assessment.skills.entries.map(
            (entry) => _buildCategoryRow(
              entry.key,
              entry.value,
              assessment.getCategoryPercentage(entry.key),
            ),
          ),
          const SizedBox(height: 32),

          // Weak areas
          if (assessment.weakAreas.isNotEmpty) ...[
            Text('Areas for Improvement', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Card(
              color: isDark
                  ? Colors.orange[900]!.withOpacity(0.3)
                  : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color:
                              isDark ? Colors.orange[300] : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Focus on these topics:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.orange[300]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...assessment.weakAreas.map(
                      (area) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_right, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              area,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Strong areas
          if (assessment.strongAreas.isNotEmpty) ...[
            Text('Your Strengths', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Card(
              color: isDark
                  ? Colors.green[900]!.withOpacity(0.3)
                  : Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: isDark ? Colors.green[300] : Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You excel in:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.green[300] : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...assessment.strongAreas.map(
                      (area) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                size: 20, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              area,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.retakeAssessment(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    // TODO: Navigate to personalized learning path
                  },
                  icon: const Icon(Icons.route),
                  label: const Text('View Path'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // History button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Get.toNamed(AppRoutes.assessmentHistory);
              },
              icon: const Icon(Icons.history),
              label: const Text('View Assessment History'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(
      String category, dynamic skillLevel, double percentage) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category, style: AppTextStyles.bodyMedium),
                  Row(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        skillLevel.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForPercentage(percentage),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 71) return AppColors.success;
    if (percentage >= 51) return AppColors.info;
    if (percentage >= 31) return AppColors.warning;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
