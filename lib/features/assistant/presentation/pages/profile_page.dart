import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';

/// Profile page showing user stats and settings
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Flutter Developer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learning since October 2025',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          // Stats
          Text(
            'Statistics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    _buildStatCard(
                          context,
                          '15',
                          'Lessons Completed',
                          Icons.school,
                          Colors.blue,
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 300))
                        .scale(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    _buildStatCard(
                          context,
                          '5',
                          'Projects Built',
                          Icons.code,
                          Colors.green,
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400))
                        .scale(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    _buildStatCard(
                          context,
                          '8',
                          'Day Streak',
                          Icons.local_fire_department,
                          Colors.orange,
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 500))
                        .scale(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    _buildStatCard(
                          context,
                          '350',
                          'XP Points',
                          Icons.star,
                          Colors.amber,
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 600))
                        .scale(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Settings
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark/light theme'),
                    value: themeManager.isDarkMode,
                    onChanged: (_) => themeManager.toggleTheme(),
                    secondary: Icon(
                      themeManager.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage notification settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to language settings
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
          const SizedBox(height: 16),
          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About FlutterMate'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'FlutterMate',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.flutter_dash),
                  children: [
                    const Text(
                      'Your personal Flutter learning companion. Built with ❤️ using Flutter.',
                    ),
                  ],
                );
              },
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
