import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/theme/app_dimensions.dart';

/// Convenience layer over `AppDimensions`. Both APIs are valid:
///
/// * `AppDimensions.spacing14.h` — fine-grained token, use when you need
///   a specific scale step (e.g. `spacing4`, `spacing20`).
/// * `defaultPadding` / `AppRadius.standard` / `AppEdgeInsets.all` —
///   shortcut for the most common values across the app. All resolve to
///   `AppDimensions.*` internally, so a single edit there propagates.
///
/// Pick whichever reads more naturally at the call site — there is no
/// "old vs new" split. Add a new shortcut only when ≥3 places use the
/// same value.

double get defaultPadding => AppDimensions.spacing14.h;
double get defaultRadius => AppDimensions.radius10.r;
double get defaultSmallRadius => AppDimensions.radius6.r;
double get defaultLargeRadius => AppDimensions.radius16.r;

double get defaultTopPadding => ScreenUtil().statusBarHeight + defaultPadding;

double get defaultBottomPadding => ScreenUtil().bottomBarHeight == 0.0 ? defaultPadding : (ScreenUtil().bottomBarHeight + AppDimensions.spacing6.h);

/// Border radius utilities for common component patterns.
class AppRadius {
  AppRadius._();

  static BorderRadius get standard => BorderRadius.circular(defaultRadius);
  static BorderRadius get small => BorderRadius.circular(defaultSmallRadius);
  static BorderRadius get large => BorderRadius.circular(defaultLargeRadius);

  static BorderRadius get topOnly => BorderRadius.vertical(
    top: Radius.circular(defaultLargeRadius),
  );

  static BorderRadius get bottomOnly => BorderRadius.vertical(
    bottom: Radius.circular(defaultLargeRadius),
  );
}

/// Edge insets utilities for common padding patterns.
class AppEdgeInsets {
  AppEdgeInsets._();

  static EdgeInsets get all => EdgeInsets.all(defaultPadding);
  static EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: defaultPadding);
  static EdgeInsets get vertical => EdgeInsets.symmetric(vertical: defaultPadding);
  static EdgeInsets get top => EdgeInsets.only(top: defaultPadding);
  static EdgeInsets get bottom => EdgeInsets.only(bottom: defaultPadding);
  static EdgeInsets get left => EdgeInsets.only(left: defaultPadding);
  static EdgeInsets get right => EdgeInsets.only(right: defaultPadding);
}
