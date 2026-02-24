import 'package:app_structure/core/config/app_environment.dart';

/// Convenience class for API URL construction.
class ApiUrls {
  ApiUrls._();

  static final AppEnvironment _appEnvironment = AppEnvironment.instance;

  /// ── API Versions ──
  static const String apiV1 = 'v1'; // Default API Version.
  static const String apiV2 = 'v2';

  /// ── Auth ──
  static String get signUp => _appEnvironment.getEnvValue('EP_SIGN_UP');
  static String get signIn => _appEnvironment.getEnvValue('EP_SIGN_IN');
  static String get validateSignUpOtp => _appEnvironment.getEnvValue('EP_VALIDATE_SIGN_UP_OTP');
  static String get validateSignInOtp => _appEnvironment.getEnvValue('EP_VALIDATE_SIGN_IN_OTP');
  static String get resendOtp => _appEnvironment.getEnvValue('EP_RESEND_OTP');

  /// ── Common ──
  static String get newFeatureDetails => _appEnvironment.getEnvValue('EP_NEW_FEATURE_DETAILS');
}
