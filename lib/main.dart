import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mate/core/theme/app_theme.dart';
import 'package:flutter_mate/core/theme/theme_manager.dart';
import 'package:flutter_mate/core/routes/app_pages.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/quiz/services/quiz_tracking_service.dart';

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
