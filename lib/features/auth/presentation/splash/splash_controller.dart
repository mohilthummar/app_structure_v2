import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/routing/route_names.dart';

/// Decides where the app boots to:
/// - If a session exists in storage → `/home`
/// - Otherwise → `/login`
///
/// Reads `AuthController.checkAuth()` to rehydrate `user` from
/// `LocalStorageService`, then redirects. A small artificial delay keeps
/// the splash visible long enough to be a brand moment, not a flash.
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _decide();
  }

  Future<void> _decide() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final auth = Get.find<AuthController>();
    await auth.checkAuth();
    Get.offAllNamed(auth.isAuthenticated ? RouteNames.home : RouteNames.login);
  }
}
