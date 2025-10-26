import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

/// Progress tracker page to monitor learning achievements
class ProgressTrackerPage extends GetView<ProgressTrackerController> {
  const ProgressTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: controller.overallProgress.value,
                              strokeWidth: 12,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(controller.overallProgress.value * 100).toInt()}%',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Text(
                                'Complete',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          context,
                          '${controller.lessonsCompleted.value}/${controller.totalLessons.value}',
                          'Lessons',
                        ),
                        _buildStat(
                          context,
                          controller.projectsCompleted.value.toString(),
                          'Projects',
                        ),
                        _buildStat(
                          context,
                          controller.dayStreak.value.toString(),
                          'Day Streak',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 16),
            ...List.generate(controller.activity.length, (index) {
              final item = controller.activity[index];
              return Column(
                children: [
                  _buildActivityItem(context, item)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 300 + (index * 100)),
                      )
                      .slideX(begin: -0.2, end: 0),
                  if (index != controller.activity.length - 1)
                    const SizedBox(height: 12),
                ],
              );
            }),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem item) {
    final color = Color(item.colorHex);
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'),
            color: color,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
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
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Get.toNamed(AppRoutes.roadmap);
            break;
          case 1:
            // Already on progress
            break;
          case 2:
            Get.toNamed(AppRoutes.assistant);
            break;
        }
      },
    );
  }
}
