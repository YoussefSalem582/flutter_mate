import 'package:flutter/material.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'onboarding_item.dart';

/// Provides the onboarding content data.
class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      icon: Icons.map_outlined,
      title: 'Structured Roadmap',
      description:
          'Follow a clear path from beginner to advanced Flutter developer with curated lessons and hands-on projects.',
      color: AppColors.lightPrimary,
      callout: '',
      highlights: [
        'Curated phases covering UI, state management, testing, and deployment',
        'Hands-on projects and checkpoints to keep you accountable',
        'Smart reminders help you maintain a steady learning streak',
      ],
      badges: ['Phase-based learning', 'Real projects', 'Progress insights'],
    ),
    OnboardingItem(
      icon: Icons.trending_up_rounded,
      title: 'Track Your Progress',
      description:
          'Monitor your learning journey with detailed stats, achievements, and visual progress indicators.',
      color: AppColors.lightPrimary,
      callout: '',
      highlights: [
        'Earn XP and level up as you complete lessons and quizzes',
        'Track weekly activity and maintain learning streaks',
        'Unlock achievements and celebrate your milestones',
      ],
      badges: ['XP & Levels', 'Activity tracking', 'Achievements'],
    ),
    OnboardingItem(
      icon: Icons.psychology_rounded,
      title: 'AI Assistant',
      description:
          'Get instant help, personalized tips, and curated resources to accelerate your Flutter learning.',
      color: AppColors.lightPrimary,
      callout: '',
      highlights: [
        'Ask questions and get instant answers about Flutter concepts',
        'Receive personalized recommendations based on your progress',
        'Access curated resources and learning materials',
      ],
      badges: ['Instant help', 'Smart tips', 'Curated resources'],
    ),
  ];
}
