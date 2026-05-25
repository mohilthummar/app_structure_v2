import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/services/notification_services.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Picks the first route after the brand moment:
/// * Session exists → `RouteNames.home` (DashboardView)
/// * Otherwise      → `RouteNames.login`
///
/// Also fires the one-shot post-boot work that needs to happen exactly
/// once per session and can be deferred past `runApp`:
///
/// * `NotificationService.init()` — fetches the FCM token, wires
///   listeners. Safe to call even if Firebase isn't configured.
///
/// The 600ms delay keeps the splash visible long enough to be a brand
/// moment, not a flash. Remove if your designer doesn't want it.
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _decide();
  }

  Future<void> _decide() async {
    // Kick off side effects in parallel with the brand-moment delay so
    // we don't add their cost on top of it.
    final delay = Future<void>.delayed(const Duration(milliseconds: 600));
    final postBoot = _postBoot();
    await Future.wait([delay, postBoot]);

    final auth = Get.find<AuthController>();
    await auth.checkAuth();
    Get.offAllNamed(auth.isAuthenticated ? RouteNames.home : RouteNames.login);
  }

  Future<void> _postBoot() async {
    try {
      await Get.find<NotificationService>().init();
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'SplashController._postBoot',
        error: e,
        stackTrace: st,
      );
    }
  }
}
