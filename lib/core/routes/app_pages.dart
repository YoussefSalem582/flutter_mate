import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/onboarding/presentation/pages/splash_page.dart';
import 'package:flutter_mate/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_binding.dart';
import 'package:flutter_mate/features/roadmap/controller/lesson_binding.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/roadmap_page.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/lessons_page.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/lesson_detail_page.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_binding.dart';
import 'package:flutter_mate/features/progress_tracker/presentation/pages/progress_tracker_page.dart';
import 'package:flutter_mate/features/assistant/controller/assistant_binding.dart';
import 'package:flutter_mate/features/assistant/presentation/pages/assistant_page.dart';
import 'package:flutter_mate/features/assistant/presentation/pages/profile_page.dart';
import 'package:flutter_mate/features/quiz/controller/quiz_binding.dart';
import 'package:flutter_mate/features/quiz/presentation/pages/quiz_page.dart';

/// App pages and routes configuration
class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.roadmap,
      page: () => const RoadmapPage(),
      binding: RoadmapBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.progressTracker,
      page: () => const ProgressTrackerPage(),
      binding: ProgressTrackerBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.assistant,
      page: () => const AssistantPage(),
      binding: AssistantBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/lessons',
      page: () => const LessonsPage(),
      binding: LessonBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/lesson-detail',
      page: () => const LessonDetailPage(),
      binding: LessonBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/quiz',
      page: () => const QuizPage(),
      binding: QuizBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
