import 'package:flutter/material.dart';

/// Text-style tokens for the OpenSans family bundled in `pubspec.yaml`.
///
/// Used by [`AppTheme.textTheme`](app_theme.dart), the [`AppText`] widget,
/// and any direct `Text(..., style: AppTypography.smMedium)` call. Sizes
/// are plain doubles — `.sp` scaling from `flutter_screenutil` is applied
/// at the call site so tokens stay usable in non-ScreenUtil contexts too.
///
/// Three layers — pick whichever fits the call site:
///
/// 1. **Size tokens** (`xxs` … `text2xl`) — base font size + line height.
/// 2. **Weight helpers** (`regular` / `medium` / `semibold` / `bold`) —
///    wrap any size token to apply a weight.
/// 3. **Common presets** (`smMedium`, `mdSemibold`, …) — shortcuts for
///    the size+weight combinations used most often.
///
/// Usage:
/// ```dart
/// Text('Body',  style: AppTypography.smMedium);
/// Text('Title', style: AppTypography.mdSemibold);
/// Text('Hero',  style: AppTypography.bold(AppTypography.text2xl));
/// ```
abstract class AppTypography {
  static TextStyle _open({
    required double fontSize,
    required double height,
    FontWeight fontWeight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'OpenSans',
    fontSize: fontSize,
    height: height / fontSize,
    fontWeight: fontWeight,
  );

  // ── Size tokens ──────────────────────────────────────────────────────────
  static TextStyle get xxs => _open(fontSize: 10, height: 18);
  static TextStyle get xs => _open(fontSize: 12, height: 18);
  static TextStyle get sm => _open(fontSize: 14, height: 20);
  static TextStyle get md => _open(fontSize: 16, height: 24);
  static TextStyle get base => _open(fontSize: 18, height: 28);
  static TextStyle get lg => _open(fontSize: 20, height: 30);
  static TextStyle get xl => _open(fontSize: 24, height: 32);
  static TextStyle get text2xl => _open(fontSize: 30, height: 38);

  // ── Weight helpers ───────────────────────────────────────────────────────
  static TextStyle regular(TextStyle s) => s.copyWith(fontWeight: FontWeight.w400);
  static TextStyle medium(TextStyle s) => s.copyWith(fontWeight: FontWeight.w500);
  static TextStyle semibold(TextStyle s) => s.copyWith(fontWeight: FontWeight.w600);
  static TextStyle bold(TextStyle s) => s.copyWith(fontWeight: FontWeight.w700);

  // ── Common presets ───────────────────────────────────────────────────────
  static TextStyle get xsMedium => medium(xs);
  static TextStyle get xsSemibold => semibold(xs);
  static TextStyle get smMedium => medium(sm);
  static TextStyle get smSemibold => semibold(sm);
  static TextStyle get mdMedium => medium(md);
  static TextStyle get mdSemibold => semibold(md);
  static TextStyle get lgSemibold => semibold(lg);
  static TextStyle get xlSemibold => semibold(xl);
  static TextStyle get text2xlSemibold => semibold(text2xl);
}
