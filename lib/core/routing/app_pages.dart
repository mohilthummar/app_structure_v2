import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/routing/auth_middleware.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_bindings.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_view.dart';
import 'package:app_structure/features/auth/presentation/login/login_bindings.dart';
import 'package:app_structure/features/auth/presentation/login/login_view.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_bindings.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_view.dart';

/// Single source of truth for every `GetPage`. `GetMaterialApp.getPages`
/// reads this list. Navigate with `Get.toNamed`, `Get.offNamed`,
/// `Get.offAllNamed`, `Get.back`.
///
/// Protected routes list `middlewares: [AuthMiddleware()]`; public routes
/// (splash, login, forgot-password) omit it.
abstract class AppPages {
  static final List<GetPage> pages = [
    // ── Public ─────────────────────────────────────────────────────────
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
      binding: SplashBindings(),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginView(),
      binding: LoginBindings(),
    ),
    GetPage(
      name: RouteNames.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBindings(),
    ),

    // ── Protected ──────────────────────────────────────────────────────
    GetPage(
      name: RouteNames.home,
      // Placeholder home — replace per project. Reads UserModel from
      // AuthController and renders the logged-in user's name.
      page: () => const _PlaceholderHomeView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class _PlaceholderHomeView extends StatelessWidget {
  const _PlaceholderHomeView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
