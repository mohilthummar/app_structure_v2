import 'package:app_structure/core/config/app_environment.dart';

/// Convenience class for API URL construction.
///
/// All endpoint paths are read from `.env` via `EP_*` keys (so the same
/// build can swap endpoints across environments). API version constants
/// are defined here for use with `ApiClient.version: ApiUrls.apiV2`.
///
/// Usage:
///   apiClient.get(ApiUrls.userDetails);                          // default v1
///   apiClient.get(ApiUrls.someEndpoint, version: ApiUrls.apiV2); // v2
class ApiUrls {
  ApiUrls._();

  static final AppEnvironment _env = AppEnvironment.instance;

  /// ── API Versions ──
  static const String apiV1 = 'v1';
  static const String apiV2 = 'v2';

  /// ── Auth ──
  static String get login => _env.getEnvValue('EP_LOGIN');
  static String get logout => _env.getEnvValue('EP_LOGOUT');
  static String get refreshToken => _env.getEnvValue('EP_REFRESH_TOKEN');
  static String get forgotPassword => _env.getEnvValue('EP_FORGOT_PASSWORD');
  static String get verifyToken => _env.getEnvValue('EP_VERIFY_TOKEN');

  /// ── Common ──
  static String get userDetails => _env.getEnvValue('EP_USER_DETAILS');
  static String get newFeatureDetails => _env.getEnvValue('EP_NEW_FEATURE_DETAILS');

  /// ── Legacy v2 template endpoints (kept for backwards compat with any
  /// projects that already use them; safe to remove if unused). ──
  static String get signUp => _env.getEnvValue('EP_SIGN_UP');
  static String get signIn => _env.getEnvValue('EP_SIGN_IN');
  static String get validateSignUpOtp => _env.getEnvValue('EP_VALIDATE_SIGN_UP_OTP');
  static String get validateSignInOtp => _env.getEnvValue('EP_VALIDATE_SIGN_IN_OTP');
  static String get resendOtp => _env.getEnvValue('EP_RESEND_OTP');
}
