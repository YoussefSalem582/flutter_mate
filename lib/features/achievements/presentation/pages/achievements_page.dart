import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/core/utils/auth_utils.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import '../../controller/achievement_controller.dart';
import '../../data/models/achievement.dart';

class AchievementsPage extends GetView<AchievementController> {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Check authentication status (without showing dialog during build)
    final isAuth = AuthUtils.isAuthenticated();

    if (!isAuth) {
      // Show auth dialog after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!AuthUtils.isAuthenticated()) {
          AuthUtils.requireAuth(
            title: 'Achievements Locked',
            message:
                'Create an account to unlock achievements, earn XP, and track your learning milestones.',
          );
        }
      });

      // Return a placeholder screen for guests
      return Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to earn badges and track XP',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
      body: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildContent(),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // XP Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.amber.shade400],
              ),
            ),
            child: Column(
              children: [
                // Personalized greeting
                Builder(
                  builder: (context) {
                    final authController = Get.find<AuthController>();
                    final user = authController.currentUser.value;

                    String greeting = 'Your Achievements';
                    if (user != null) {
                      final name = user.displayName ?? user.email.split('@')[0];
                      greeting = "$name's Achievements";
                    }

                    return Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Total XP',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.totalXP}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.unlockedAchievements.length}/${controller.achievements.length} Unlocked',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2, duration: 400.ms),

          // Category Tabs
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.amber.shade700,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.amber.shade700,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: '🎓 Lessons'),
                      Tab(text: '🎯 Quizzes'),
                      Tab(text: '🔥 Streaks'),
                      Tab(text: '⭐ Special'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAchievementList(controller.achievements),
                        _buildAchievementList(_filterByCategory('lessons')),
                        _buildAchievementList(_filterByCategory('quizzes')),
                        _buildAchievementList(_filterByCategory('streak')),
                        _buildAchievementList(_filterByCategory('special')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  List<Achievement> _filterByCategory(String category) {
    return controller.achievements
        .where((a) => a.category == category)
        .toList();
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(child: Text('No achievements in this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final progress = controller.userProgress[achievement.id];
        final isUnlocked = progress?.isUnlocked ?? false;

        return _AchievementCard(
          achievement: achievement,
          progress: progress,
          isUnlocked: isUnlocked,
          progressPercentage: controller.getProgressPercentage(achievement.id),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress? progress;
  final bool isUnlocked;
  final double progressPercentage;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
    required this.isUnlocked,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnlocked ? 4 : 1,
      color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isUnlocked ? Colors.amber.shade400 : Colors.grey.shade300,
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: isUnlocked ? 2000.ms : 0.ms,
                  color: Colors.white.withOpacity(0.5),
                ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  if (!isUnlocked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress?.currentProgress ?? 0}/${achievement.requiredProgress}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                  // Unlocked info
                  if (isUnlocked)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
