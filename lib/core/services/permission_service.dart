import 'package:permission_handler/permission_handler.dart';

import 'package:app_structure/core/utils/app_logger.dart';

/// User-friendly outcome of a permission request. Lets callers branch
/// without importing `permission_handler` themselves.
enum PermissionOutcome {
  /// User said yes.
  granted,

  /// User said no but can be asked again.
  denied,

  /// User said no with "don't ask again" — need to open OS settings.
  permanentlyDenied,

  /// Restricted by OS policy (parental controls, MDM, etc.).
  restricted,
}

/// Thin, opinionated wrapper around `permission_handler`. Three reasons
/// it exists:
///
/// * Callers stop importing `permission_handler` everywhere — one place
///   to update if the package changes.
/// * Permissions are requested at the point of use (per `security.md` —
///   "request the narrowest permission needed and only at the point of
///   use"). No "request everything on launch" anti-pattern.
/// * Returns a typed [PermissionOutcome] instead of `PermissionStatus`
///   so consumers can `switch` exhaustively.
///
/// Registered lazy + fenix in `InitialBinding`.
class PermissionService {
  PermissionService();

  // ── Helpers consumers should reach for ────────────────────────────────────

  Future<PermissionOutcome> notification() => _ensure(Permission.notification);

  Future<PermissionOutcome> camera() => _ensure(Permission.camera);

  Future<PermissionOutcome> photos() => _ensure(Permission.photos);

  Future<PermissionOutcome> microphone() => _ensure(Permission.microphone);

  Future<PermissionOutcome> locationWhenInUse() => _ensure(Permission.locationWhenInUse);

  Future<PermissionOutcome> storage() => _ensure(Permission.storage);

  /// Open the OS-level app settings page so the user can manually
  /// re-grant a `permanentlyDenied` permission.
  Future<bool> openSettings() => openAppSettings();

  // ── Internals ────────────────────────────────────────────────────────────

  Future<PermissionOutcome> _ensure(Permission permission) async {
    try {
      var status = await permission.status;
      if (status.isGranted) return PermissionOutcome.granted;
      if (status.isPermanentlyDenied) return PermissionOutcome.permanentlyDenied;
      if (status.isRestricted) return PermissionOutcome.restricted;

      status = await permission.request();
      return _map(status);
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'PermissionService.${permission.toString()}',
        error: e,
        stackTrace: st,
      );
      return PermissionOutcome.denied;
    }
  }

  PermissionOutcome _map(PermissionStatus status) {
    if (status.isGranted) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied) return PermissionOutcome.permanentlyDenied;
    if (status.isRestricted) return PermissionOutcome.restricted;
    return PermissionOutcome.denied;
  }
}
