import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/routing/route_names.dart';

/// Synchronous auth gate. Every protected `GetPage` lists
/// `middlewares: [AuthMiddleware()]`. Public pages (splash, login,
/// forgot-password) omit it.
///
/// Reads `AuthController.isAuthenticated` — a synchronous bool backed by
/// the in-memory `user` state (populated on login + boot rehydration).
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) return null;
    if (Get.find<AuthController>().isAuthenticated) return null;
    return const RouteSettings(name: RouteNames.login);
  }
}
