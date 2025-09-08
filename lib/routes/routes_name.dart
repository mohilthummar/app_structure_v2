// -----------------------------------------------------------------------------
// TredPlus App Route Names
// -----------------------------------------------------------------------------
// This file defines all route name constants for the TredPlus application.
// Use these static strings throughout the app to avoid typos and ensure
// consistency in navigation.
//
// Usage Example:
//   Navigator.pushNamed(context, RoutesName.signInView);
//   Get.toNamed(RoutesName.profileDetailsView);
//
// To add a new route, simply add a new static String below and use it in
// your route configuration and navigation calls.
// -----------------------------------------------------------------------------

/// All route name constants for the TredPlus app, organized by flow/feature.
class RoutesName {
  // ---------------------- Auth Flow Routes ----------------------
  static String splashView = '/';
  static String signInView = '/sign-in';
  static String signUpView = '/sign-up';
  static String signUpSteps = '/sign-up-steps';

  // ---------------------- Forgot Password Flow ----------------------
  static String forgotPasswordView = '/forgot-password';
  static String otpVerificationView = '/OTP-verification';
  static String enterNewPasswordView = '/enter-new-password';
}
