import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_structure/core/theme/app_dimensions.dart';

/// Backward-compatibility shim over `AppDimensions`.
///
/// New code should use `AppDimensions` directly (e.g. `AppDimensions.spacing14.h`).
/// Existing call sites that consume `defaultPadding`, `defaultRadius`,
/// `AppRadius.standard`, `AppEdgeInsets.all`, etc. continue to work — the
/// values they receive now come from the `AppDimensions` token scale, so
/// changing a token in one place propagates everywhere.

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
