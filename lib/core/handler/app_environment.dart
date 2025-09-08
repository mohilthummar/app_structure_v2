import 'package:app_structure/core/enums/common_enums.dart';

import '../utils/utils.dart';

/// A utility class to manage the application's API environment configuration.
class AppEnvironment {
  AppEnvironment._();

  /// Environment type.
  // static EnvironmentType envType = EnvironmentType.development;
  static late EnvironmentType envType;

  /// Set Environment, set in `main.dart`
  static void setEnvironment(EnvironmentType env) {
    envType = env;
    printData(type: "Set APP Environment", text: env.slug);
  }

  // Initial Version.
  static const String initialVersionCode = "v1";

  /// Returns the base URL for the current environment, appending the version code if necessary.
  static String getBaseURL({bool ignoreVersion = false}) {
    printData(type: "APP Environment", text: envType.name);

    final String url = _getBaseURLByEnvironment(envType);
    return ignoreVersion ? url : "$url/";
  }

  /// Determines the base URL based on the environment type.
  static String _getBaseURLByEnvironment(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.production:
        return "https://api.com";

      case EnvironmentType.staging:
        return "http://api_staging.com";

      case EnvironmentType.development:
        return "https://api_development.com";

      case EnvironmentType.local:
        return "http://api_local.com";
    }
  }
}
