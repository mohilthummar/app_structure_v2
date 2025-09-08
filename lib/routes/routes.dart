// -----------------------------------------------------------------------------
// TredPlus App Routing Configuration
// -----------------------------------------------------------------------------
// This file defines all the routes for the TredPlus application using GetX.
// It organizes the navigation structure for all flows (auth, profile, deals, etc.)
// and provides a single source of truth for route management.
//
// Usage Example:
//   Get.toNamed(RoutesName.signInView);
//
// All routes are defined in the [pages] list below, using the [getPage] helper.
// -----------------------------------------------------------------------------

import 'package:get/get.dart';

// -----------------------------------------------------------------------------
// Helper Function: getPage
// -----------------------------------------------------------------------------
/// Helper to create a GetPage with optional binding and children.
///
/// Example:
///   getPage(name: '/login', page: () => LoginView(), binding: LoginBinding())
GetPage getPage({String? name, GetPageBuilder? page, Bindings? binding, List<GetPage<dynamic>>? children}) {
  return GetPage(name: name!, page: page!, binding: binding, children: children ?? []);
}

// -----------------------------------------------------------------------------
// Main Route List: pages
// -----------------------------------------------------------------------------
/// List of all routes in the app, organized by flow/feature.
///
/// To add a new route, use the [getPage] helper and add it to this list.
List<GetPage> pages = [
  // ---------------------- Auth Flow Routes ----------------------
  // getPage(name: RoutesName.signInView, page: () => const SignInView(), binding: SignInBindings()),
  // getPage(name: RoutesName.signUpView, page: () => const SignUpView()),
  // getPage(name: RoutesName.signUpSteps, page: () => const SignUpStepsView(), binding: SignUpStepsBindings()),

  // ---------------------- Forgot Password Flow ----------------------
  // getPage(name: RoutesName.forgotPasswordView, page: () => const ForgotPasswordView(), binding: ForgotPasswordBindings()),
  // getPage(name: RoutesName.otpVerificationView, page: () => const OTPVerificationView()),
  // getPage(name: RoutesName.enterNewPasswordView, page: () => const EnterNewPasswordView()),
];
