import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';

/// Middleware to check if user is authenticated
class AuthMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If user is not authenticated, redirect to login
    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// Middleware to check if user is already authenticated
class GuestMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If user is authenticated, redirect to roadmap (home)
    if (authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.roadmap);
    }
    return null;
  }
}
