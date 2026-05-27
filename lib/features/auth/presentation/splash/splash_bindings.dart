import 'package:get/get.dart';

import 'package:app_structure/features/auth/presentation/splash/splash_controller.dart';

/// Splash is the **one screen** where `Get.put` (eager) is correct and
/// `Get.lazyPut` would be a bug. The rule in `.claude/rules/architecture.md`
/// — "use `Get.lazyPut` in screen bindings" — assumes the controller is
/// driven by view interaction (`controller.onLogin()` etc.); `GetView<T>`
/// instantiates the controller only when `build()` references `controller`.
///
/// `SplashView.build()` never reads `controller` (it just renders the logo
/// + app name), so under `lazyPut` the controller is never constructed,
/// `onReady` never fires, `_decide()` never runs, and the splash hangs
/// forever. Use `Get.put` here to force eager construction — GetX still
/// disposes it when the route is popped via `Get.offAllNamed`.
class SplashBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
