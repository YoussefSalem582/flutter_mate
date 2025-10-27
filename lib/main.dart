import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mate/core/theme/app_theme.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';
import 'package:flutter_mate/core/routes/app_pages.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';
import 'package:flutter_mate/features/achievements/data/repositories/achievement_repository.dart';
import 'package:flutter_mate/features/achievements/controller/achievement_controller.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Initialize GetX dependencies
  Get.put(ThemeManager());

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
