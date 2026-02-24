// -----------------------------------------------------------------------------
// Flutter App Routing Configuration
// -----------------------------------------------------------------------------
// This file defines all the routes for the Flutter application using GetX.
// It organizes the navigation structure for all flows (auth, profile, deals, etc.)
// and provides a single source of truth for route management.
//
// Usage Example:
//   Get.toNamed(RoutesName.signInView);
//
// All routes are defined in the [pages] list below, using the [getPage] helper.
// -----------------------------------------------------------------------------

import 'package:app_structure/features/auth/presentation/sign_in/sign_in_bindings.dart';
import 'package:app_structure/features/auth/presentation/sign_in/sign_in_view.dart';
import 'package:app_structure/features/auth/presentation/sign_up/sign_up_bindings.dart';
import 'package:app_structure/features/auth/presentation/sign_up/sign_up_view.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_bindings.dart';
import 'package:app_structure/features/auth/presentation/splash/splash_view.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:get/get.dart';

// -----------------------------------------------------------------------------
// Helper Function: getPage
// -----------------------------------------------------------------------------
/// Helper to create a GetPage with optional binding and children.
///
/// Example:
///   getPage(name: '/login', page: () => LoginView(), binding: LoginBinding())
GetPage getPage({
  String? name,
  GetPageBuilder? page,
  Bindings? binding,
  List<GetPage<dynamic>>? children,
}) {
  return GetPage(
    name: name!,
    page: page!,
    binding: binding,
    children: children ?? [],
  );
}

// -----------------------------------------------------------------------------
// Main Route List: pages
// -----------------------------------------------------------------------------
/// List of all routes in the app, organized by flow/feature.
///
/// To add a new route, use the [getPage] helper and add it to this list.
List<GetPage> pages = [
  // ---------------------- Auth Flow Routes ----------------------
  getPage(name: RoutesName.splashView, page: () => const SplashView(), binding: SplashBindings()),
  getPage(name: RoutesName.signInView, page: () => const SignInView(), binding: SignInBindings()),
  getPage(name: RoutesName.signUpView, page: () => const SignUpView(), binding: SignUpBindings()),

  // ---------------------- Forgot Password Flow ----------------------
  // getPage(name: RoutesName.forgotPasswordView, page: () => const ForgotPasswordView(), binding: ForgotPasswordBindings()),
  // getPage(name: RoutesName.otpVerificationView, page: () => const OTPVerificationView()),
  // getPage(name: RoutesName.enterNewPasswordView, page: () => const EnterNewPasswordView()),
];
