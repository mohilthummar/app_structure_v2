import 'package:package_info_plus/package_info_plus.dart';

/// Caches build metadata (app name, package, version, build number) after
/// the first read so every subsequent caller is synchronous.
///
/// Registered lazy + fenix in `InitialBinding`. Call `.load()` once during
/// boot (or from the first screen that needs it) — the future resolves
/// quickly because `PackageInfo.fromPlatform()` reads compile-time
/// constants on Android/iOS.
///
/// Usage:
/// ```dart
/// final info = Get.find<AppInfoService>();
/// await info.load();
/// print('${info.appName} v${info.version}+${info.buildNumber}');
/// ```
class AppInfoService {
  AppInfoService();

  PackageInfo? _info;

  /// True once `load()` has populated the cache.
  bool get isReady => _info != null;

  /// Application display name (Android: app label; iOS: CFBundleDisplayName).
  String get appName => _info?.appName ?? '';

  /// Bundle identifier (Android: package name; iOS: bundle id).
  String get packageName => _info?.packageName ?? '';

  /// Semver from `pubspec.yaml` (e.g. `1.0.0`).
  String get version => _info?.version ?? '';

  /// Build number from `pubspec.yaml` after `+` (e.g. `1`).
  String get buildNumber => _info?.buildNumber ?? '';

  /// `version+buildNumber` — handy for displaying in settings/about screens.
  String get fullVersion => version.isEmpty ? '' : '$version+$buildNumber';

  /// Loads platform info. Safe to call multiple times — only the first
  /// call actually hits the platform channel.
  Future<void> load() async {
    if (_info != null) return;
    _info = await PackageInfo.fromPlatform();
  }
}
