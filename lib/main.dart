import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mate/core/theme/app_theme.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';
import 'package:flutter_mate/core/routes/app_pages.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/firebase_options.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';
import 'package:flutter_mate/features/achievements/data/repositories/achievement_repository.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';

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

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Initialize GetX dependencies
  Get.put(ThemeManager());

  // Initialize Authentication Controller
  Get.put(AuthController());

  // Initialize Quiz Tracking Service
  await Get.putAsync(() => QuizTrackingService().init());

  // Initialize Achievement System
  final achievementRepo = AchievementRepositoryImpl(prefs);
  Get.put<AchievementRepository>(achievementRepo);
  Get.put(AchievementController(achievementRepo));

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
