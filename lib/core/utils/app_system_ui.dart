import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thin wrappers around `SystemChrome` and friends for the chrome bits a
/// Flutter app touches most: status bar style, system nav bar colour,
/// orientation lock, on-screen keyboard, and platform identity.
///
/// Boot-time calls live in `bootstrap.dart`. Reach for these from a
/// screen when you need to *change* the chrome mid-session — e.g. a dark
/// status bar over a photo-viewer hero, or unlocking to landscape inside
/// a video player.
///
/// Usage:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   AppSystemUi.darkStatusBar();
/// }
///
/// @override
/// void dispose() {
///   AppSystemUi.lightStatusBar();
///   super.dispose();
/// }
/// ```
abstract class AppSystemUi {
  // ── Status / system nav bar ──────────────────────────────────────────────
  static void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );
  }

  // ── Orientation ──────────────────────────────────────────────────────────
  /// `bootstrap.dart` already locks portrait on boot — reach for this
  /// again only when a screen has temporarily unlocked all orientations.
  static Future<void> lockPortrait() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Pair with [lockPortrait] in `dispose()` to restore the global lock.
  static Future<void> unlockAllOrientations() {
    return SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  // ── Keyboard ─────────────────────────────────────────────────────────────
  /// Dismiss the on-screen keyboard. Safe to call without a `BuildContext`
  /// (works from controllers and async callbacks where `FocusScope.of` is
  /// unavailable).
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  // ── Platform identity ────────────────────────────────────────────────────
  /// Short platform label — `'Android'` or `'iOS'`. For richer device
  /// info (model, OS version, hardware id) use `DeviceInfoService`.
  static String get deviceType => Platform.isAndroid ? 'Android' : 'iOS';
}
