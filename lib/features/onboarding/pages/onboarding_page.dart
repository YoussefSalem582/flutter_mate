import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import '../data/onboarding_data.dart';
import '../widgets/widgets.dart';

/// Main onboarding page with PageView and modular widgets.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  void _nextPage() {
    if (_currentPage < OnboardingData.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as completed
    final prefs = Get.find<SharedPreferences>();
    prefs.setBool('hasSeenOnboarding', true);

    // Navigate to login page
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentItem = OnboardingData.items[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: StepHeader(
                      step: _currentPage + 1,
                      total: OnboardingData.items.length,
                      accent: currentItem.color,
                    ),
                  ),
                  TextButton(
                    onPressed: _skipToEnd,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withOpacity(
                        0.6,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingData.items.length,
                itemBuilder: (context, index) {
                  final item = OnboardingData.items[index];
                  return OnboardingContentCard(
                    item: item,
                    isWide: false,
                    availableHeight: 0,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PageIndicator(
                    activeIndex: _currentPage,
                    itemCount: OnboardingData.items.length,
                    accent: currentItem.color,
                  ),
                  const SizedBox(height: 24),
                  OnboardingNavigationButtons(
                    currentPage: _currentPage,
                    totalPages: OnboardingData.items.length,
                    accentColor: currentItem.color,
                    onPrevious: _previousPage,
                    onNext: _nextPage,
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
