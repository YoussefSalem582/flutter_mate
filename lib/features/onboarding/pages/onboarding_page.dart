import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
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
    final progressBox = Hive.box('progress');
    progressBox.put('hasSeenOnboarding', true);

    // Navigate to login page
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentItem = OnboardingData.items[_currentPage];
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 24,
                    16,
                    isDesktop ? 32 : 16,
                    16,
                  ),
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
                          foregroundColor:
                              theme.colorScheme.onSurface.withOpacity(
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
                        isWide: isDesktop,
                        availableHeight: 0,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Column(
                    children: [
                      PageIndicator(
                        activeIndex: _currentPage,
                        itemCount: OnboardingData.items.length,
                        accent: currentItem.color,
                      ),
                      SizedBox(height: isDesktop ? 32 : 24),
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
        ),
      ),
    );
  }
}
