import 'app_environment.dart';

class ApiUrls {
  ApiUrls._();

  ///* =-=-=-=-=-=-= BASE URL =-=-=-=-=-=-=-=-=-=-=>>
  static String baseUrl({bool ignoreVersion = false, String? versionCode}) => AppEnvironment.getBaseURL(ignoreVersion: ignoreVersion);

  ///* =-=-=-=-=-=-= COMMONS =-=-=-=-=-=-=-=--=>>
  static String getNewFeatureDetails = "new-feature/details";
}
