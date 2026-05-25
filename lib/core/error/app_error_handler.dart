import 'package:flutter/foundation.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// Centralised error sink. Wires the three places Flutter surfaces unhandled
/// errors:
///
/// * `FlutterError.onError` — synchronous framework errors (build, layout,
///   paint).
/// * `PlatformDispatcher.instance.onError` — async errors that bubble up
///   from platform channels and the engine.
/// * `runZonedGuarded(zoneOnError:)` — anything thrown inside the zone that
///   wraps `runApp` (handler in [onZoneError]).
///
/// All three forward to `AppLogger.error`, which in turn calls
/// `AppLogger.errorReportHook` — `CrashlyticsService.init` sets that hook
/// to `FirebaseCrashlytics.recordError`. Net effect: every uncaught error
/// reaches Crashlytics when it's wired, console only otherwise.
class AppErrorHandler {
  AppErrorHandler._();

  static bool _initialized = false;

  /// Install the framework + platform hooks. Idempotent.
  static void init() {
    if (_initialized) return;
    _initialized = true;

    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        details.exceptionAsString(),
        tag: 'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
      // Preserve default red-screen behaviour in debug.
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.error(
        error.toString(),
        tag: 'PlatformDispatcher',
        error: error,
        stackTrace: stack,
      );
      return true; // tell the engine the error was handled
    };
  }

  /// Pass this as the `zoneOnError` argument to `runZonedGuarded`.
  static void onZoneError(Object error, StackTrace stack) {
    AppLogger.error(
      error.toString(),
      tag: 'Zone',
      error: error,
      stackTrace: stack,
    );
  }
}
