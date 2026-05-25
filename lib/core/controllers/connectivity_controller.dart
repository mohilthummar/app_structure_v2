import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// Reactive wrapper around `connectivity_plus`. Subscribes once at
/// startup; views just `Obx` on `isOnline` to react to changes.
///
/// Registered as a permanent service in `InitialBinding` so the
/// subscription lasts the entire app lifetime. Logout teardown
/// (`Get.deleteAll(force: false)`) skips permanent services, so
/// connectivity tracking survives.
///
/// Usage:
/// ```dart
/// final connectivity = Get.find<ConnectivityController>();
/// Obx(() => connectivity.isOnline.value ? const SizedBox.shrink() : const OfflineBanner())
/// ```
class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  /// True when the device reports any non-`none` connection. Reactive.
  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onChanged,
      onError: (Object e, StackTrace st) {
        AppLogger.error(
          e.toString(),
          tag: 'ConnectivityController.stream',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onChanged(results);
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'ConnectivityController.bootstrap',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _onChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (isOnline.value != online) {
      isOnline.value = online;
    }
  }
}
