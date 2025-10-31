import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';

/// Flutter Developer Roadmap Page
///
/// Displays a comprehensive roadmap for becoming a Flutter developer
/// with different learning stages, skills, and resources.
class FlutterDeveloperRoadmapPage extends StatelessWidget {
  const FlutterDeveloperRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Flutter Developer Roadmap',
        icon: Icons.route,
        iconColor: AppColors.info,
        showBackButton: true,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, isDark, padding),
        desktop: _buildDesktopLayout(context, isDark, padding),
      ),
    );
  }

  /// Mobile layout - Full width scrolling
  Widget _buildMobileLayout(BuildContext context, bool isDark, double padding) {
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 32),
        ..._buildAllStages(context, isDark, false),
        const SizedBox(height: 32),
        _buildCareerPaths(isDark, false),
        const SizedBox(height: 32),
        _buildTipsSection(isDark, false),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Desktop layout - Centered with max width
  Widget _buildDesktopLayout(
      BuildContext context, bool isDark, double padding) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView(
          padding: EdgeInsets.all(padding * 1.5),
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 32),
            ..._buildAllStages(context, isDark, true),
            const SizedBox(height: 32),
            _buildCareerPaths(isDark, true),
            const SizedBox(height: 32),
            _buildTipsSection(isDark, true),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Build all roadmap stages
  List<Widget> _buildAllStages(
      BuildContext context, bool isDark, bool isDesktop) {
    final stages = <Widget>[
      _buildRoadmapStage(
        context,
        isDark,
        isDesktop,
        stage: 1,
        title: 'Foundation',
        subtitle: '0-2 Months',
        description:
            'Build a strong foundation in programming and mobile development basics',
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.foundation,
        skills: [
          RoadmapSkill(
            title: 'Programming Basics',
            items: [
              'Dart Language',
              'OOP Concepts',
              'Variables & Data Types',
              'Control Flow',
              'Functions & Methods',
              'Collections (Lists, Maps, Sets)',
            ],
          ),
          RoadmapSkill(
            title: 'Development Tools',
            items: [
              'VS Code / Android Studio',
              'Git & GitHub',
              'Terminal/Command Line',
              'Package Management (pub.dev)',
            ],
          ),
        ],
        resources: [
          'Dart Official Documentation',
          'Flutter.dev Getting Started',
          'Free Dart & Flutter Courses on YouTube',
        ],
      ),
      const SizedBox(height: 24),
      _buildRoadmapStage(
        context,
        isDark,
        isDesktop,
        stage: 2,
        title: 'Flutter Basics',
        subtitle: '2-4 Months',
        description:
            'Master Flutter fundamentals and build your first mobile applications',
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.widgets,
        skills: [
          RoadmapSkill(
            title: 'Core Widgets',
            items: [
              'Stateless & Stateful Widgets',
              'Layout Widgets (Container, Row, Column)',
              'Material & Cupertino Design',
              'Navigation & Routing',
              'Forms & Input Widgets',
            ],
          ),
          RoadmapSkill(
            title: 'State Management',
            items: [
              'setState()',
              'InheritedWidget',
              'Provider (Recommended)',
              'GetX / Riverpod / Bloc',
            ],
          ),
          RoadmapSkill(
            title: 'UI Development',
            items: [
              'Responsive Design',
              'Custom Widgets',
              'Themes & Styling',
              'Animations & Transitions',
            ],
          ),
        ],
        resources: [
          'Flutter Widget of the Week',
          'Flutter Cookbook',
          'Build simple apps: Calculator, Todo List, Weather App',
        ],
      ),
      const SizedBox(height: 24),
      _buildRoadmapStage(
        context,
        isDark,
        isDesktop,
        stage: 3,
        title: 'Intermediate Skills',
        subtitle: '4-8 Months',
        description:
            'Dive deeper into Flutter ecosystem and professional development practices',
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.code,
        skills: [
          RoadmapSkill(
            title: 'Backend Integration',
            items: [
              'REST APIs & HTTP',
              'JSON Parsing',
              'Firebase (Auth, Firestore, Storage)',
              'GraphQL (Optional)',
              'WebSockets',
            ],
          ),
          RoadmapSkill(
            title: 'Local Storage',
            items: [
              'SharedPreferences',
              'Hive / SQFlite',
              'Secure Storage',
              'File System Access',
            ],
          ),
          RoadmapSkill(
            title: 'Advanced Patterns',
            items: [
              'Clean Architecture',
              'Repository Pattern',
              'Dependency Injection',
              'Error Handling',
              'Testing (Unit, Widget, Integration)',
            ],
          ),
        ],
        resources: [
          'Flutter Architecture Samples',
          'Firebase Flutter Codelab',
          'Real-world project: Social Media App, E-commerce App',
        ],
      ),
      const SizedBox(height: 24),
      _buildRoadmapStage(
        context,
        isDark,
        isDesktop,
        stage: 4,
        title: 'Advanced Development',
        subtitle: '8-12 Months',
        description:
            'Master advanced topics and optimize app performance for production',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.rocket_launch,
        skills: [
          RoadmapSkill(
            title: 'Performance Optimization',
            items: [
              'Widget Optimization',
              'Memory Management',
              'Build & Bundle Size',
              'Lazy Loading',
              'Performance Profiling',
            ],
          ),
          RoadmapSkill(
            title: 'Native Integration',
            items: [
              'Platform Channels',
              'Native Code (Kotlin/Swift)',
              'Custom Plugins',
              'Platform-specific UI',
            ],
          ),
          RoadmapSkill(
            title: 'Advanced Features',
            items: [
              'Custom Painters & Canvas',
              'Complex Animations',
              'Camera & Media',
              'Background Services',
              'Push Notifications',
              'In-App Purchases',
            ],
          ),
        ],
        resources: [
          'Flutter Performance Best Practices',
          'Platform Channel Documentation',
          'Contribute to Open Source Flutter Projects',
        ],
      ),
      const SizedBox(height: 24),
      _buildRoadmapStage(
        context,
        isDark,
        isDesktop,
        stage: 5,
        title: 'Professional & Expert',
        subtitle: '12+ Months',
        description:
            'Become a Flutter expert with mastery in all aspects of app development',
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.workspace_premium,
        skills: [
          RoadmapSkill(
            title: 'Production Ready',
            items: [
              'CI/CD Pipelines',
              'App Store Deployment',
              'Code Signing & Certificates',
              'Analytics & Crash Reporting',
              'A/B Testing',
            ],
          ),
          RoadmapSkill(
            title: 'Architecture Mastery',
            items: [
              'Microservices Integration',
              'Multi-platform (Web, Desktop)',
              'Offline-First Architecture',
              'Scalable State Management',
              'Design Systems',
            ],
          ),
          RoadmapSkill(
            title: 'Leadership',
            items: [
              'Code Reviews',
              'Mentoring Junior Developers',
              'Technical Documentation',
              'Project Architecture Design',
              'Contributing to Flutter Framework',
            ],
          ),
        ],
        resources: [
          'Flutter Master Class Courses',
          'Build Complex Production Apps',
          'Speak at Conferences',
          'Write Technical Blogs/Tutorials',
        ],
      ),
    ];

    // Add spacing between stages
    final spacedStages = <Widget>[];
    for (var i = 0; i < stages.length; i++) {
      spacedStages.add(stages[i]);
      if (i < stages.length - 1) {
        spacedStages.add(const SizedBox(height: 24));
      }
    }

    return spacedStages;
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1565C0),
                  const Color(0xFF0D47A1),
                ]
              : [
                  const Color(0xFF2196F3),
                  const Color(0xFF1976D2),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Your Journey to Becoming a Flutter Developer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Follow this comprehensive roadmap to master Flutter development. Each stage builds upon the previous one, taking you from beginner to expert.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatChip(
                  Icons.schedule, 'Timeline: 12+ months', Colors.white),
              const SizedBox(width: 12),
              _buildStatChip(Icons.school, '5 Major Stages', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStage(
    BuildContext context,
    bool isDark,
    bool isDesktop, {
    required int stage,
    required String title,
    required String subtitle,
    required String description,
    required Gradient gradient,
    required IconData icon,
    required List<RoadmapSkill> skills,
    required List<String> resources,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Header with Gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stage $stage',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Skills Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.lightPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Skills to Learn',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...skills.map((skill) => _buildSkillSection(skill, isDark)),
                const SizedBox(height: 24),

                // Resources Section
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.lightPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Learning Resources',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...resources.map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_right,
                          color: isDark
                              ? AppColors.darkSecondary
                              : AppColors.lightPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            resource,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillSection(RoadmapSkill skill, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill.title,
            style: TextStyle(
              color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skill.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkSecondary.withOpacity(0.3)
                        : AppColors.lightPrimary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPaths(bool isDark, bool isDesktop) {
    final careers = [
      CareerPath(
        icon: Icons.smartphone,
        title: 'Mobile Developer',
        description: 'Build native iOS and Android apps',
        color: const Color(0xFF2196F3),
      ),
      CareerPath(
        icon: Icons.web,
        title: 'Full-Stack Developer',
        description: 'Develop web & mobile applications',
        color: const Color(0xFF4CAF50),
      ),
      CareerPath(
        icon: Icons.desktop_mac,
        title: 'Cross-Platform Expert',
        description: 'Master mobile, web, and desktop',
        color: const Color(0xFF9C27B0),
      ),
      CareerPath(
        icon: Icons.architecture,
        title: 'Solution Architect',
        description: 'Design scalable app architectures',
        color: const Color(0xFFFF5722),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color:
                    isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Career Paths',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 0.9 : 1.0,
            ),
            itemCount: careers.length,
            itemBuilder: (context, index) {
              final career = careers[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      career.color.withOpacity(0.8),
                      career.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(career.icon, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        career.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        career.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(bool isDark, bool isDesktop) {
    final tips = [
      LearningTip(
        icon: Icons.schedule,
        title: 'Practice Daily',
        description: 'Code at least 1-2 hours every day to build muscle memory',
      ),
      LearningTip(
        icon: Icons.build,
        title: 'Build Projects',
        description: 'Create real apps to apply what you learn',
      ),
      LearningTip(
        icon: Icons.people,
        title: 'Join Community',
        description:
            'Engage with Flutter developers on Discord, Reddit, Twitter',
      ),
      LearningTip(
        icon: Icons.code,
        title: 'Read Code',
        description: 'Study open-source Flutter projects and packages',
      ),
      LearningTip(
        icon: Icons.videocam,
        title: 'Watch Tutorials',
        description: 'Follow YouTube channels and online courses',
      ),
      LearningTip(
        icon: Icons.favorite,
        title: 'Stay Consistent',
        description: 'Learning takes time, be patient and persistent',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.success.withOpacity(0.2),
                  AppColors.info.withOpacity(0.2),
                ]
              : [
                  AppColors.success.withOpacity(0.1),
                  AppColors.info.withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.success.withOpacity(0.3)
              : AppColors.success.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: isDark ? AppColors.warning : AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Pro Tips for Success',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 1.4 : 1.3,
            ),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tip.icon,
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.lightPrimary,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        tip.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Flexible(
                      child: Text(
                        tip.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 10,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Data Models
class RoadmapSkill {
  final String title;
  final List<String> items;

  RoadmapSkill({required this.title, required this.items});
}

class CareerPath {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  CareerPath({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class LearningTip {
  final IconData icon;
  final String title;
  final String description;

  LearningTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}
