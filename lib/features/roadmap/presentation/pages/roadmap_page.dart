import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';

/// Roadmap page showing learning path from beginner to advanced
class RoadmapPage extends GetView<RoadmapController> {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Roadmap'),
        actions: [
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Your Learning Journey',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Follow this structured path to master Flutter',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 24),
            ...List.generate(controller.stages.length, (index) {
              final stage = controller.stages[index];
              final progress = controller.stageProgress(stage.id);
              return Column(
                children: [
                  _buildStageCard(context, stage, progress)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 300 + (index * 100)),
                      )
                      .slideY(begin: 0.2, end: 0),
                  if (index != controller.stages.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            }),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    RoadmapStage stage,
    double progress,
  ) {
    return Card(
      child: InkWell(
        onTap: () => Get.toNamed('/lessons', arguments: stage),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: stage.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stage.icon, color: stage.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          stage.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(stage.color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              // Topics
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stage.topics.map((topic) {
                  return Chip(
                    label: Text(topic),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Adjust progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Slider(
                value: progress,
                onChanged: (value) =>
                    controller.updateProgress(stage.id, value),
                activeColor: stage.color,
              ),
            ],
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
        }
      },
    );
  }
}
