import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App-wide design tokens — spacing, radius, components, shadows, plus
/// the screen-aware shortcuts every widget reaches for.
///
/// **Rule:** never inline a literal in feature/shared code. If the value
/// you need isn't here, add it.
///
/// Three layers — pick whichever fits the call site:
///
/// 1. **Scale tokens** (`spacing*`, `radius*`) — plain `double`s. Append
///    `.h` / `.w` / `.r` from `flutter_screenutil` at the call site for
///    responsive scaling.
/// 2. **Pre-built helpers** (`borderRadius*`, `*Shadow`) — `BorderRadius`
///    / `BoxShadow` objects ready to drop into a `BoxDecoration`.
/// 3. **Convenience shortcuts** (`defaultPadding`, `defaultRadius`,
///    [AppRadius], [AppEdgeInsets]) — the values 80% of widgets use.
///    Already screen-scaled.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(defaultPadding), child: ...);
/// SizedBox(height: AppDimensions.spacing16.h);
/// Container(
///   padding: AppEdgeInsets.all,
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.standard,
///     boxShadow: AppDimensions.dropdownShadow,
///   ),
/// );
/// ```
abstract class AppDimensions {
  // ── Spacing scale ────────────────────────────────────────────────────────
  static const double spacing0 = 0;
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
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

  // ── Radius scale ─────────────────────────────────────────────────────────
  static const double radius4 = 4;
  static const double radius6 = 6;
  static const double radius8 = 8;
  static const double radius10 = 10;
  static const double radius12 = 12;
  static const double radius14 = 14;
  static const double radius16 = 16;
  static const double radius20 = 20;

  /// Fully-rounded pill / capsule.
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

  /// Symmetric padding applied to every button via [`AppTheme`].
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: buttonPaddingVertical,
    horizontal: buttonPaddingHorizontal,
  );

  /// Symmetric padding applied to every input decoration via [`AppTheme`].
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    vertical: spacing10,
    horizontal: spacing16,
  );

  /// Max width clamp for modals / dialogs on tablets and desktop.
  static const double modalMaxWidth = 500;

  /// Standard side-drawer / nav-rail width.
  static const double drawerWidth = 440;

  /// Outer padding around modal / dialog content.
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

// ════════════════════════════════════════════════════════════════════════════
// Screen-aware shortcuts
// ════════════════════════════════════════════════════════════════════════════

/// Default page content padding (14 logical px, screen-height scaled).
double get defaultPadding => AppDimensions.spacing14.h;

/// Default corner radius (10 logical px, scaled). Used by cards, inputs,
/// buttons, and dialogs unless they explicitly need a sharper / rounder shape.
double get defaultRadius => AppDimensions.radius10.r;

/// Smaller corner radius — chips, badges, small cards.
double get defaultSmallRadius => AppDimensions.radius6.r;

/// Larger corner radius — bottom sheets, modals, hero cards.
double get defaultLargeRadius => AppDimensions.radius16.r;

/// Top padding that respects the device's status bar / notch.
double get defaultTopPadding => ScreenUtil().statusBarHeight + defaultPadding;

/// Bottom padding that respects the device's home-indicator / nav bar.
/// Falls back to [defaultPadding] when there is no system bottom inset.
double get defaultBottomPadding => ScreenUtil().bottomBarHeight == 0.0 ? defaultPadding : (ScreenUtil().bottomBarHeight + AppDimensions.spacing6.h);

/// Pre-built [BorderRadius] objects for common component patterns.
abstract class AppRadius {
  static BorderRadius get standard => BorderRadius.circular(defaultRadius);
  static BorderRadius get small => BorderRadius.circular(defaultSmallRadius);
  static BorderRadius get large => BorderRadius.circular(defaultLargeRadius);

  /// Round only the top corners — bottom sheets / app bars.
  static BorderRadius get topOnly => BorderRadius.vertical(
    top: Radius.circular(defaultLargeRadius),
  );

  /// Round only the bottom corners — sticky headers.
  static BorderRadius get bottomOnly => BorderRadius.vertical(
    bottom: Radius.circular(defaultLargeRadius),
  );
}

/// Pre-built [EdgeInsets] objects for common padding patterns. All
/// resolve to [defaultPadding] so they scale with the screen.
abstract class AppEdgeInsets {
  static EdgeInsets get all => EdgeInsets.all(defaultPadding);
  static EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: defaultPadding);
  static EdgeInsets get vertical => EdgeInsets.symmetric(vertical: defaultPadding);
  static EdgeInsets get top => EdgeInsets.only(top: defaultPadding);
  static EdgeInsets get bottom => EdgeInsets.only(bottom: defaultPadding);
  static EdgeInsets get left => EdgeInsets.only(left: defaultPadding);
  static EdgeInsets get right => EdgeInsets.only(right: defaultPadding);
}
