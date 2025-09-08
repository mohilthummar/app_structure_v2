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

/// Small padding for compact layouts (10.h)
///
/// Used when you need tighter spacing, such as in lists, compact cards,
/// or when space is limited.
double get defaultSmallPadding => 10.h;

/// Extra small padding for very compact layouts (6.h)
///
/// Used for minimal spacing requirements, such as between closely related elements
/// or in dense information displays.
double get defaultExtraSmallPadding => 6.h;

/// Large padding for spacious layouts (20.h)
///
/// Used for main content areas, section headers, or when you want to create
/// more breathing room around content.
double get defaultLargePadding => 20.h;

/// Extra large padding for very spacious layouts (32.h)
///
/// Used for main page content, hero sections, or when you want maximum
/// visual separation between major sections.
double get defaultExtraLargePadding => 32.h;

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

/// Extra large border radius for very prominent rounding (24.r)
///
/// Used for hero sections, large containers, or when you want maximum
/// rounded appearance.
double get defaultExtraLargeRadius => 24.r;

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

/// Horizontal padding for content that needs side margins
///
/// Provides consistent horizontal spacing for content that should have
/// left and right margins.
double get defaultHorizontalPadding => defaultPadding;

/// Vertical padding for content that needs top and bottom margins
///
/// Provides consistent vertical spacing for content that should have
/// top and bottom margins.
double get defaultVerticalPadding => defaultPadding;

/// Spacing utilities for common layout patterns
class AppSpacing {
  /// Creates a SizedBox with default padding height
  static Widget get verticalSpace => SizedBox(height: defaultPadding);

  /// Creates a SizedBox with small padding height
  static Widget get verticalSmallSpace => SizedBox(height: defaultSmallPadding);

  /// Creates a SizedBox with large padding height
  static Widget get verticalLargeSpace => SizedBox(height: defaultLargePadding);

  /// Creates a SizedBox with default padding width
  static Widget get horizontalSpace => SizedBox(width: defaultPadding);

  /// Creates a SizedBox with small padding width
  static Widget get horizontalSmallSpace => SizedBox(width: defaultSmallPadding);

  /// Creates a SizedBox with large padding width
  static Widget get horizontalLargeSpace => SizedBox(width: defaultLargePadding);
}

/// Border radius utilities for common component patterns
class AppRadius {
  /// Default border radius for most components
  static BorderRadius get standard => BorderRadius.circular(defaultRadius);

  /// Small border radius for compact components
  static BorderRadius get small => BorderRadius.circular(defaultSmallRadius);

  /// Large border radius for prominent components
  static BorderRadius get large => BorderRadius.circular(defaultLargeRadius);

  /// Extra large border radius for very prominent components
  static BorderRadius get extraLarge => BorderRadius.circular(defaultExtraLargeRadius);

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

  /// Small padding for all sides
  static EdgeInsets get allSmall => EdgeInsets.all(defaultSmallPadding);

  /// Large padding for all sides
  static EdgeInsets get allLarge => EdgeInsets.all(defaultLargePadding);

  /// Horizontal padding only
  static EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: defaultPadding);

  /// Vertical padding only
  static EdgeInsets get vertical => EdgeInsets.symmetric(vertical: defaultPadding);

  /// Small horizontal padding only
  static EdgeInsets get horizontalSmall => EdgeInsets.symmetric(horizontal: defaultSmallPadding);

  /// Small vertical padding only
  static EdgeInsets get verticalSmall => EdgeInsets.symmetric(vertical: defaultSmallPadding);

  /// Large horizontal padding only
  static EdgeInsets get horizontalLarge => EdgeInsets.symmetric(horizontal: defaultLargePadding);

  /// Large vertical padding only
  static EdgeInsets get verticalLarge => EdgeInsets.symmetric(vertical: defaultLargePadding);

  /// Top padding only
  static EdgeInsets get top => EdgeInsets.only(top: defaultPadding);

  /// Bottom padding only
  static EdgeInsets get bottom => EdgeInsets.only(bottom: defaultPadding);

  /// Left padding only
  static EdgeInsets get left => EdgeInsets.only(left: defaultPadding);

  /// Right padding only
  static EdgeInsets get right => EdgeInsets.only(right: defaultPadding);

  /// Top and bottom padding
  static EdgeInsets get topBottom => EdgeInsets.only(
        top: defaultPadding,
        bottom: defaultPadding,
      );

  /// Left and right padding
  static EdgeInsets get leftRight => EdgeInsets.only(
        left: defaultPadding,
        right: defaultPadding,
      );
}
