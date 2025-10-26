import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';

/// Onboarding page to introduce app features
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.map,
      title: 'Structured Roadmap',
      description:
          'Follow a clear path from beginner to advanced Flutter developer',
      color: Colors.blue,
    ),
    OnboardingItem(
      icon: Icons.track_changes,
      title: 'Track Your Progress',
      description: 'Monitor your learning journey and celebrate milestones',
      color: Colors.green,
    ),
    OnboardingItem(
      icon: Icons.assistant,
      title: 'AI Assistant',
      description: 'Get personalized guidance and tips as you learn',
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToRoadmap() {
    Get.offAllNamed(AppRoutes.roadmap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _navigateToRoadmap,
                child: const Text('Skip'),
              ),
            ).animate().fadeIn(),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 24),
            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _items.length - 1) {
                      _navigateToRoadmap();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 120, color: item.color)
              .animate()
              .scale(
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(duration: const Duration(milliseconds: 800)),
          const SizedBox(height: 48),
          Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 300))
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 500))
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
