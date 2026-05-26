import 'package:get/get.dart';

import 'package:app_structure/core/routing/auth_middleware.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_bindings.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_view.dart';
import 'package:app_structure/features/auth/presentation/login/login_bindings.dart';
import 'package:app_structure/features/auth/presentation/login/login_view.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_bindings.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_view.dart';
import 'package:app_structure/features/home/presentation/dashboard/dashboard_bindings.dart';
import 'package:app_structure/features/home/presentation/dashboard/dashboard_view.dart';
import 'package:app_structure/features/home/presentation/profile/profile_bindings.dart';
import 'package:app_structure/features/home/presentation/profile/profile_view.dart';
import 'package:app_structure/features/showcase/presentation/showcase_bindings.dart';
import 'package:app_structure/features/showcase/presentation/showcase_view.dart';

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
    GetPage(
      name: RouteNames.showcase,
      page: () => const ShowcaseView(),
      binding: ShowcaseBindings(),
    ),

    // ── Protected ──────────────────────────────────────────────────────
    GetPage(
      name: RouteNames.home,
      page: () => const DashboardView(),
      binding: DashboardBindings(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteNames.profile,
      page: () => const ProfileView(),
      binding: ProfileBindings(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
