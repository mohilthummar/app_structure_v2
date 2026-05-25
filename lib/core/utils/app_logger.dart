import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:app_structure/core/config/app_environment.dart';

/// Centralised logger. Same surface as the old `AppPrint` (debug / info /
/// success / warning / error / data) plus an optional error-reporting hook
/// for Crashlytics.
///
/// Gating: logs print when `kDebugMode` is true OR `enableLogging` is `true`
/// in `.env`. In release builds with logging off, every method is a no-op —
/// safe to leave calls in production code.
///
/// Error reporting: `AppLogger.error(...)` calls `errorReportHook` (if set)
/// regardless of the print gate, so production crashes still reach
/// Crashlytics even when console logging is off. Phase 3 wires this up
/// inside `CrashlyticsService`.
class AppLogger {
  AppLogger._();

  /// Set by `CrashlyticsService` to forward errors. Left null when
  /// Crashlytics isn't configured / `enableCrashlytics` is false.
  static void Function(Object error, StackTrace? stackTrace, {String? tag})? errorReportHook;

  // ── Public API ───────────────────────────────────────────────────────────

  static void debug(Object? message, {String? tag}) => _emit('🐛', '\x1B[95m', message, tag: tag);

  static void info(Object? message, {String? tag}) => _emit('ℹ️', '\x1B[94m', message, tag: tag);

  static void success(Object? message, {String? tag}) => _emit('✅', '\x1B[92m', message, tag: tag);

  static void warning(Object? message, {String? tag}) => _emit('⚠️', '\x1B[93m', message, tag: tag);

  /// Errors are also forwarded to `errorReportHook` (when set) regardless
  /// of whether console logging is enabled. Pass `error` + `stackTrace` so
  /// Crashlytics has the full picture.
  static void error(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit('❌', '\x1B[91m', message, tag: tag);
    final reportable = error ?? message;
    if (reportable != null) {
      errorReportHook?.call(reportable, stackTrace, tag: tag);
    }
  }

  static void data(Object? message, {String? tag}) => _emit('📊', '\x1B[96m', message, tag: tag);

  // ── Internals ────────────────────────────────────────────────────────────

  static bool get _shouldPrint {
    if (kDebugMode) return true;
    try {
      return AppEnvironment.enableLogging;
    } catch (_) {
      // AppEnvironment.setEnvironment hasn't run yet (very early boot).
      return false;
    }
  }

  static void _emit(String emoji, String colorCode, Object? message, {String? tag}) {
    if (!_shouldPrint) return;
    final body = tag == null ? '$emoji $message' : '$emoji $tag: $message';
    if (Platform.isAndroid) {
      debugPrint('$colorCode$body\x1B[0m', wrapWidth: 99999);
    } else {
      debugPrint(body, wrapWidth: 99999);
    }
  }
}
