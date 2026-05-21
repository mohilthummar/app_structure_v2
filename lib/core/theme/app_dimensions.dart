import 'package:flutter/material.dart';

import 'package:app_structure/core/constants/app_colors.dart';

/// App-wide spacing, radius, sizing, and shadow tokens.
///
/// **Rule:** never inline a literal in feature/shared code. If the value
/// you need isn't here, add it. Tokens are plain doubles — consumers add
/// `.h` / `.w` / `.r` from `flutter_screenutil` at the call site.
abstract class AppDimensions {
  // ── Spacing scale ────────────────────────────────────────────────────────
  static const double spacing0 = 0;
  static const double spacing1 = 1;
  static const double spacing2 = 2;
  static const double spacing3 = 3;
  static const double spacing4 = 4;
  static const double spacing5 = 5;
  static const double spacing6 = 6;
  static const double spacing7 = 7;
  static const double spacing8 = 8;
  static const double spacing10 = 10;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing18 = 18;
  static const double spacing20 = 20;
  static const double spacing22 = 22;
  static const double spacing24 = 24;
  static const double spacing28 = 28;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing56 = 56;
  static const double spacing64 = 64;
  static const double spacing72 = 72;
  static const double spacing90 = 90;
  static const double spacing100 = 100;
  static const double spacing120 = 120;
  static const double spacing160 = 160;
  static const double spacing240 = 240;
  static const double spacing400 = 400;

  // ── Border radius scale ──────────────────────────────────────────────────
  static const double radius2 = 2;
  static const double radius4 = 4;
  static const double radius6 = 6;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius14 = 14;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radiusFull = 999;

  static BorderRadius get borderRadius4 => BorderRadius.circular(radius4);
  static BorderRadius get borderRadius6 => BorderRadius.circular(radius6);
  static BorderRadius get borderRadius8 => BorderRadius.circular(radius8);
  static BorderRadius get borderRadius10 => BorderRadius.circular(radius10);
  static BorderRadius get borderRadius12 => BorderRadius.circular(radius12);
  static BorderRadius get borderRadius16 => BorderRadius.circular(radius16);
  static BorderRadius get borderRadius20 => BorderRadius.circular(radius20);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ── Component constants ──────────────────────────────────────────────────
  static const double inputHeight = 42;
  static const double buttonPaddingVertical = spacing12;
  static const double buttonPaddingHorizontal = 36;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: buttonPaddingVertical,
    horizontal: buttonPaddingHorizontal,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    vertical: spacing10,
    horizontal: spacing16,
  );

  static const double modalMaxWidth = 500;
  static const double drawerWidth = 440;
  static const double modalPadding = 30;

  // ── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get modalShadow => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 4),
      blurRadius: 24,
    ),
  ];

  static List<BoxShadow> get dropdownShadow => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.1),
      blurRadius: 6,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get bottomBarShadow => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.06),
      offset: const Offset(0, -2),
      blurRadius: 8,
    ),
  ];
}
