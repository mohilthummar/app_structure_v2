import 'dart:async';

import 'package:app_links/app_links.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// Resolved deep link — opaque to callers, used by a top-level
/// coordinator to navigate. Built only after the incoming URI's path
/// matches [DeepLinkService._allowedPaths] (per `security.md`).
class DeepLinkIntent {
  const DeepLinkIntent({required this.path, required this.queryParameters});

  final String path;
  final Map<String, String> queryParameters;
}

/// Listens for incoming `app_links` URIs (iOS Universal Links + Android
/// App Links + custom-scheme links). Validates each link against a
/// whitelist of allowed paths before pushing it onto [onLink].
///
/// **Important:** this service intentionally does NOT navigate. A
/// top-level coordinator (e.g. the splash controller, or a thin
/// `AppLinkRouter` listening to `onLink`) decides what to do with each
/// intent — that keeps deep-link routing testable and lets callers
/// gate on authentication.
///
/// Registered as a permanent service in `InitialBinding`. Call
/// `init()` from your coordinator AFTER the first paint so cold-start
/// links aren't lost.
///
/// Platform configuration (Android intent filters, iOS Universal Links
/// associated domains) is on you — see the `app_links` README. This
/// class just consumes whatever the platform delivers.
class DeepLinkService {
  DeepLinkService({Set<String>? allowedPaths})
    : _allowedPaths = allowedPaths ?? const {};

  /// Path prefixes the app is willing to act on. Empty set = drop
  /// everything (safe default for a fresh skeleton). Extend by passing
  /// `allowedPaths: { '/dashboard', '/profile', '/order/' }` when
  /// constructing — paths that *start with* one of these strings pass
  /// the gate.
  final Set<String> _allowedPaths;

  final AppLinks _appLinks = AppLinks();
  final _linkController = StreamController<DeepLinkIntent>.broadcast();
  StreamSubscription<Uri>? _subscription;
  bool _initialized = false;

  /// Stream of validated deep-link intents.
  Stream<DeepLinkIntent> get onLink => _linkController.stream;

  /// Idempotent. Subscribes to incoming URIs and processes any cold-start
  /// link that opened the app.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);

      _subscription = _appLinks.uriLinkStream.listen(
        _handle,
        onError: (Object e, StackTrace st) {
          AppLogger.error(
            e.toString(),
            tag: 'DeepLinkService.stream',
            error: e,
            stackTrace: st,
          );
        },
      );
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'DeepLinkService.init',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _linkController.close();
  }

  void _handle(Uri uri) {
    final path = uri.path.isEmpty ? '/' : uri.path;
    if (!_isAllowed(path)) {
      AppLogger.warning(
        'Dropping deep link to non-whitelisted path: $path',
        tag: 'DeepLinkService',
      );
      return;
    }
    _linkController.add(
      DeepLinkIntent(
        path: path,
        queryParameters: Map<String, String>.from(uri.queryParameters),
      ),
    );
  }

  bool _isAllowed(String path) {
    if (_allowedPaths.isEmpty) return false;
    return _allowedPaths.any((prefix) => path == prefix || path.startsWith(prefix));
  }
}
