import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AppStyle provides responsive spacing and sizing utilities for the TredPlus application
///
/// This class contains predefined spacing values that automatically adapt to different
/// screen sizes using flutter_screenutil. All values are responsive and will scale
/// appropriately across different devices.
///
/// Usage:
/// ```dart
/// Container(
///   padding: EdgeInsets.all(defaultPadding),
///   margin: EdgeInsets.symmetric(vertical: defaultSmallPadding),
///   child: Text('Content'),
/// )
/// ```

/// Default padding used throughout the app (14.h)
///
/// This is the standard padding used for most containers, cards, and content areas.
/// It provides comfortable spacing that works well across different screen sizes.
double get defaultPadding => 14.h;

/// Default border radius used throughout the app (10.r)
///
/// This is the standard border radius used for cards, buttons, input fields,
/// and other rounded components. It provides a modern, consistent look.
double get defaultRadius => 10.r;

/// Small border radius for subtle rounding (6.r)
///
/// Used for small elements like badges, chips, or when you want a more
/// subtle rounded appearance.
double get defaultSmallRadius => 6.r;

/// Large border radius for prominent rounding (16.r)
///
/// Used for large cards, containers, or when you want a more prominent
/// rounded appearance.
double get defaultLargeRadius => 16.r;

/// Top padding that accounts for status bar height
///
/// This automatically adjusts for different devices and their status bar heights.
/// Useful for content that needs to be positioned below the status bar.
double get defaultTopPadding => ScreenUtil().statusBarHeight + defaultPadding;

/// Bottom padding that accounts for safe area and bottom bar
///
/// This automatically adjusts for devices with home indicators, navigation bars,
/// or other bottom UI elements. Ensures content is not obscured by system UI.
double get defaultBottomPadding => ScreenUtil().bottomBarHeight == 0.0 ? defaultPadding : (ScreenUtil().bottomBarHeight + 6.h);


/// Border radius utilities for common component patterns
class AppRadius {
  /// Default border radius for most components
  static BorderRadius get standard => BorderRadius.circular(defaultRadius);

  /// Small border radius for compact components
  static BorderRadius get small => BorderRadius.circular(defaultSmallRadius);

  /// Large border radius for prominent components
  static BorderRadius get large => BorderRadius.circular(defaultLargeRadius);

  /// Top-only border radius for bottom sheets and modals
  static BorderRadius get topOnly => BorderRadius.vertical(
        top: Radius.circular(defaultLargeRadius),
      );

  /// Bottom-only border radius for top sheets and modals
  static BorderRadius get bottomOnly => BorderRadius.vertical(
        bottom: Radius.circular(defaultLargeRadius),
      );
}

/// Edge insets utilities for common padding patterns
class AppEdgeInsets {
  /// Default padding for all sides
  static EdgeInsets get all => EdgeInsets.all(defaultPadding);

  /// Horizontal padding only
  static EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: defaultPadding);

  /// Vertical padding only
  static EdgeInsets get vertical => EdgeInsets.symmetric(vertical: defaultPadding);

  /// Top padding only
  static EdgeInsets get top => EdgeInsets.only(top: defaultPadding);

  /// Bottom padding only
  static EdgeInsets get bottom => EdgeInsets.only(bottom: defaultPadding);

  /// Left padding only
  static EdgeInsets get left => EdgeInsets.only(left: defaultPadding);

  /// Right padding only
  static EdgeInsets get right => EdgeInsets.only(right: defaultPadding);

}
