/// Route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  // Authentication routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // Feature routes
  static const String roadmap = '/roadmap';
  static const String progressTracker = '/progress-tracker';
  static const String assistant = '/assistant';
  static const String profile = '/profile';
  static const String achievements = '/achievements';
  static const String codePlayground = '/code-playground';

  // Analytics & Assessment routes
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String skillAssessment = '/skill-assessment';
  static const String assessmentResults = '/assessment-results';
  static const String assessmentHistory = '/assessment-history';

  // Roadmap detail routes
  static const String stageDetail = '/stage-detail';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson-detail';
  static const String flutterDeveloperRoadmap = '/flutter-developer-roadmap';
}
