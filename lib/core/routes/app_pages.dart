import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/routes/custom_page_transitions.dart';
import 'package:flutter_mate/core/middleware/auth_middleware.dart';
import 'package:flutter_mate/features/onboarding/pages/splash_page.dart';
import 'package:flutter_mate/features/onboarding/pages/onboarding_page.dart';
import 'package:flutter_mate/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_mate/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter_mate/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_mate/features/auth/presentation/pages/email_verification_page.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_binding.dart';
import 'package:flutter_mate/features/roadmap/controller/lesson_binding.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/roadmap_page.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/lessons_page.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/lesson_detail_page.dart';
import 'package:flutter_mate/features/roadmap/presentation/pages/stage_detail_page.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_binding.dart';
import 'package:flutter_mate/features/progress_tracker/presentation/pages/progress_tracker_page.dart';
import 'package:flutter_mate/features/assistant/controller/assistant_binding.dart';
import 'package:flutter_mate/features/assistant/presentation/pages/assistant_page.dart';
import 'package:flutter_mate/features/profile_page/presentation/pages/profile_page.dart';
import 'package:flutter_mate/features/quiz/controller/quiz_binding.dart';
import 'package:flutter_mate/features/quiz/presentation/pages/quiz_page.dart';
import 'package:flutter_mate/features/achievements/presentation/pages/achievements_page.dart';
import 'package:flutter_mate/features/code_playground/presentation/pages/code_playground_page.dart';
import 'package:flutter_mate/features/code_playground/controller/code_playground_binding.dart';
import 'package:flutter_mate/features/analytics/controller/analytics_binding.dart';
import 'package:flutter_mate/features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'package:flutter_mate/features/assessment/controller/assessment_binding.dart';
import 'package:flutter_mate/features/assessment/presentation/pages/skill_assessment_page.dart';
import 'package:flutter_mate/features/assessment/presentation/pages/assessment_results_page.dart';
import 'package:flutter_mate/features/assessment/presentation/pages/assessment_history_page.dart';

/// App pages and routes configuration
class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 400),
      middlewares: [GuestMiddleware()],
    ),

    // Authentication routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpPage(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Feature routes
    GetPage(
      name: AppRoutes.roadmap,
      page: () => const RoadmapPage(),
      binding: RoadmapBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.progressTracker,
      page: () => const ProgressTrackerPage(),
      binding: ProgressTrackerBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.assistant,
      page: () => const AssistantPage(),
      binding: AssistantBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProgressTrackerBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.stageDetail,
      page: () => const StageDetailPage(),
      binding: RoadmapBinding(),
      middlewares: [AuthMiddleware()],
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.lessons,
      page: () => const LessonsPage(),
      binding: LessonBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.lessonDetail,
      page: () => const LessonDetailPage(),
      binding: LessonBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: '/quiz',
      page: () => const QuizPage(),
      binding: QuizBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.achievements,
      page: () => const AchievementsPage(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.codePlayground,
      page: () => const CodePlaygroundPage(),
      binding: CodePlaygroundBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.analyticsDashboard,
      page: () => const AnalyticsDashboardPage(),
      binding: AnalyticsBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.skillAssessment,
      page: () => const SkillAssessmentPage(),
      binding: AssessmentBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.assessmentResults,
      page: () => const AssessmentResultsPage(),
      binding: AssessmentBinding(),
      customTransition: SmoothFadeTransition(),
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.assessmentHistory,
      page: () => const AssessmentHistoryPage(),
      binding: AssessmentBinding(),
      customTransition: SmoothPageTransition(),
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
