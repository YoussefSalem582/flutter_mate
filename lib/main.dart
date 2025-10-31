import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_mate/core/theme/app_theme.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';
import 'package:flutter_mate/core/routes/app_pages.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/firebase_options.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';
import 'package:flutter_mate/features/achievements/data/repositories/achievement_repository.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:flutter_mate/features/roadmap/data/repositories/lesson_repository.dart';
import 'package:flutter_mate/features/roadmap/data/services/progress_sync_service.dart';
import 'package:flutter_mate/features/roadmap/controller/roadmap_controller.dart';
import 'package:flutter_mate/features/roadmap/controller/lesson_controller.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only if not already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized, this is fine during hot reload
      debugPrint('Firebase already initialized');
    } else {
      // Re-throw other errors
      rethrow;
    }
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Open all Hive boxes
  await Hive.openBox('progress'); // For lesson progress and sync
  await Hive.openBox('roadmap'); // For roadmap stage progress
  await Hive.openBox('quiz'); // For quiz tracking and results
  await Hive.openBox('study_timer'); // For study timer persistence

  // Initialize GetX dependencies
  Get.put(ThemeManager());

  // Initialize Authentication Controller
  Get.put(AuthController());

  // Initialize Quiz Tracking Service
  await Get.putAsync(() => QuizTrackingService().init());

  // Initialize Achievement System (now uses Hive)
  final achievementRepo = AchievementRepositoryImpl();
  Get.put<AchievementRepository>(achievementRepo);
  Get.put(AchievementController(achievementRepo));

  // Initialize Progress Tracker dependencies (for Profile page)
  // These need to be available early since Profile page uses them
  if (!Get.isRegistered<RoadmapRepository>()) {
    Get.lazyPut<RoadmapRepository>(() => RoadmapRepositoryImpl());
  }

  if (!Get.isRegistered<ProgressSyncService>()) {
    Get.lazyPut<ProgressSyncService>(() => ProgressSyncService());
  }

  if (!Get.isRegistered<LessonRepository>()) {
    Get.lazyPut<LessonRepository>(
      () => LessonRepositoryImpl(Get.find<ProgressSyncService>()),
    );
  }

  if (!Get.isRegistered<RoadmapController>()) {
    Get.lazyPut<RoadmapController>(
      () => RoadmapController(repository: Get.find<RoadmapRepository>()),
      fenix: true, // Keep alive even after page disposal
    );
  }

  if (!Get.isRegistered<LessonController>()) {
    Get.lazyPut<LessonController>(
      () => LessonController(Get.find<LessonRepository>()),
      fenix: true, // Keep alive even after page disposal
    );
  }

  if (!Get.isRegistered<ProgressTrackerController>()) {
    Get.lazyPut<ProgressTrackerController>(
      () => ProgressTrackerController(
        roadmapController: Get.find<RoadmapController>(),
        lessonController: Get.find<LessonController>(),
      ),
      fenix: true, // Keep alive for profile page access
    );
  }

  runApp(const FlutterMateApp());
}

class FlutterMateApp extends StatelessWidget {
  const FlutterMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FlutterMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      getPages: AppPages.routes,
      initialRoute: AppRoutes.splash,
    );
  }
}
