/// Single source of truth for every named route. Use these constants for
/// every `Get.toNamed` / `Get.offNamed` / `Get.offAllNamed` call.
abstract class RouteNames {
  // Public
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Protected (require AuthMiddleware)
  static const String home = '/home';
  static const String profile = '/profile';
}
