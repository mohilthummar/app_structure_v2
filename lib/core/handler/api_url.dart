import 'app_environment.dart';

class ApiUrls {
  ApiUrls._();

  ///* =-=-=-=-=-=-= BASE URL =-=-=-=-=-=-=-=-=-=-=>>
  static String baseUrl({bool ignoreVersion = false, String? versionCode}) => AppEnvironment.getBaseURL(ignoreVersion: ignoreVersion);

  ///* =-=-=-=-=-=-= COMMONS =-=-=-=-=-=-=-=--=>>
  static String getNewFeatureDetails = "new-feature/details";

  ///* =-=-=-=-=-=-= AUTH ENDPOINTS =-=-=-=-=-=-=-=--=>>
  static String signUp = "auth/signup";
  static String signIn = "auth/signin";
  static String validateSignUpOtp = "auth/validate-signup-otp";
  static String validateSignInOtp = "auth/validate-signin-otp";
  static String resendOtp = "auth/resend-otp";
  
}
