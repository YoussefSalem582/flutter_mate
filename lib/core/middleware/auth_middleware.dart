import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';

/// Middleware to check authentication status before navigating to protected routes
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      // If user is not authenticated, redirect to login
      if (!authController.isAuthenticated.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      // User is authenticated, allow navigation
      return null;
    } catch (e) {
      // Auth controller not initialized, redirect to splash
      return const RouteSettings(name: AppRoutes.splash);
    }
  }
}

/// Middleware to redirect authenticated users away from auth pages
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      // If user is already authenticated, redirect to home
      if (authController.isAuthenticated.value) {
        return const RouteSettings(name: AppRoutes.roadmap);
      }

      // User is not authenticated, allow navigation to auth pages
      return null;
    } catch (e) {
      // Auth controller not initialized, allow navigation
      return null;
    }
  }
}
