import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_structure/core/constants/app_colors.dart';

/// AppTheme class provides comprehensive theming for the Flutter application
///
/// This class manages both light and dark themes with consistent styling across
/// the application. It includes typography, colors, component themes, and
/// responsive design considerations.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.light, // or ThemeMode.dark
/// )
/// ```
class AppTheme {
  /// Light theme configuration for the application
  ///
  /// Provides a clean, modern light theme with consistent styling
  /// for all components including text, buttons, cards, and navigation.
  static ThemeData get lightTheme => ThemeData.light().copyWith(
    /// Core Theme Properties
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    disabledColor: AppColors.disableColor,
    hoverColor: const Color(0x80C5C2C2),
    splashColor: const Color(0x66C8C8C8),

    /// Gesture and Interaction Properties
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    highlightColor: Colors.transparent,

    /// AppBar Theme Configuration
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryColor),
      titleTextStyle: TextStyle(color: AppColors.primaryTextColor, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'OpenSans'),
    ),

    /// Text Theme Configuration
    textTheme: buildTextTheme(ThemeData.light().textTheme),
    primaryTextTheme: buildTextTheme(ThemeData.light().textTheme),

    /// Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),

    /// Card Theme Configuration
    cardTheme: CardThemeData(
      color: AppColors.containerFillColor,
      elevation: 2,
      shadowColor: AppColors.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    /// Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.containerFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    /// Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteTextColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Icon Theme
    iconTheme: const IconThemeData(color: AppColors.primaryColor, size: 24),

    /// Divider Theme
    dividerTheme: const DividerThemeData(color: AppColors.dividerAndBorderColor, thickness: 1, space: 1),

    /// Color Scheme Configuration
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.light().copyWith(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      surface: AppColors.backgroundColor,
      onPrimary: AppColors.whiteTextColor,
      onSurface: AppColors.primaryTextColor,
      error: AppColors.red,
      onError: AppColors.whiteTextColor, //
    ),
    tabBarTheme: const TabBarThemeData(indicatorColor: AppColors.primaryColor),
  );

  /// Dark theme configuration for the application
  ///
  /// Provides a sophisticated dark theme with proper contrast ratios
  /// and accessibility considerations for all components.
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    /// Core Theme Properties
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    disabledColor: AppColors.disableColor,
    hoverColor: const Color(0xC7C9C0C0),
    splashColor: const Color(0xBEF3EFEF),

    /// Gesture and Interaction Properties
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    highlightColor: Colors.transparent,

    /// AppBar Theme Configuration
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.primaryColor),
      titleTextStyle: TextStyle(color: AppColors.primaryTextColor, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'OpenSans'),
    ),

    /// Text Theme Configuration
    textTheme: buildTextTheme(ThemeData.dark().textTheme),
    primaryTextTheme: buildTextTheme(ThemeData.dark().textTheme),

    /// Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),

    /// Card Theme Configuration
    cardTheme: CardThemeData(
      color: AppColors.containerFillColor,
      elevation: 2,
      shadowColor: AppColors.primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    /// Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.containerFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    /// Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteTextColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'OpenSans'),
      ),
    ),

    /// Icon Theme
    iconTheme: const IconThemeData(color: AppColors.primaryColor, size: 24),

    /// Divider Theme
    dividerTheme: const DividerThemeData(color: AppColors.dividerAndBorderColor, thickness: 1, space: 1),

    /// Color Scheme Configuration
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      surface: AppColors.backgroundColor,
      onPrimary: AppColors.whiteTextColor,
      onSurface: AppColors.primaryTextColor,
      error: AppColors.red,
      onError: AppColors.whiteTextColor, //
    ),
    tabBarTheme: const TabBarThemeData(indicatorColor: AppColors.primaryColor),
  );

  /// Helper method to get the current theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }

  /// Helper method to get the opposite theme
  static ThemeData getOppositeTheme(Brightness brightness) {
    return brightness == Brightness.light ? darkTheme : lightTheme;
  }
}

/// Builds a custom text theme with consistent typography
///
/// This function creates a comprehensive text theme that maintains
/// consistency across the application with proper font sizes, weights,
/// and the custom font family.
///
/// Parameters:
/// - [base]: The base TextTheme to extend from
///
/// Returns:
/// - A customized TextTheme with consistent styling
TextTheme buildTextTheme(TextTheme base) {
  return base.copyWith(
    //* Label Styles - Used for small UI elements like chips, badges
    labelSmall: TextStyle(fontSize: 11.0, fontFamily: 'OpenSans', color: base.labelSmall!.color, fontWeight: FontWeight.w400),
    labelMedium: TextStyle(fontSize: 12.0, fontFamily: 'OpenSans', color: base.labelMedium!.color, fontWeight: FontWeight.w500),
    labelLarge: TextStyle(fontSize: 14.0, fontFamily: 'OpenSans', color: base.labelLarge!.color, fontWeight: FontWeight.w600),

    //* Body Text Styles - Used for main content text
    bodySmall: TextStyle(fontSize: 12.0, fontFamily: 'OpenSans', color: base.bodySmall!.color, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'OpenSans', color: base.bodyMedium!.color, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(fontSize: 16.0, fontFamily: 'OpenSans', color: base.bodyLarge!.color, fontWeight: FontWeight.w500),

    //* Title Styles - Used for section headers and important text
    titleSmall: TextStyle(fontSize: 14.0, fontFamily: 'OpenSans', color: base.titleSmall!.color, fontWeight: FontWeight.w500),
    titleMedium: const TextStyle(fontSize: 16.0, fontFamily: 'OpenSans', color: AppColors.white, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22.0, fontFamily: 'OpenSans', color: base.titleLarge!.color, fontWeight: FontWeight.w600),

    //* Headline Styles - Used for main headings and prominent text
    headlineSmall: const TextStyle(fontSize: 24.0, fontFamily: 'OpenSans', color: AppColors.white, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 28.0, fontFamily: 'OpenSans', color: base.headlineMedium!.color, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(fontSize: 32.0, fontFamily: 'OpenSans', color: base.headlineLarge!.color, fontWeight: FontWeight.w800),

    //* Display Styles - Used for very large, prominent text
    displaySmall: TextStyle(fontSize: 36.0, fontFamily: 'OpenSans', color: base.displaySmall!.color, fontWeight: FontWeight.w800),
    displayMedium: TextStyle(fontSize: 45.0, fontFamily: 'OpenSans', color: base.displayMedium!.color, fontWeight: FontWeight.w900),
    displayLarge: TextStyle(fontSize: 57.0, fontFamily: 'OpenSans', color: base.displayLarge!.color, fontWeight: FontWeight.w900),
  );
}

/// Material 3 Typography Reference
///
/// Official Flutter Material 3 typography font sizes and line heights:
///
/// Body Styles:
/// - Body Small: Size 12, Height 1.33
/// - Body Medium: Size 14, Height 1.43
/// - Body Large: Size 16, Height 1.5
///
/// Label Styles:
/// - Label Small: Size 11, Height 1.45
/// - Label Medium: Size 12, Height 1.33
/// - Label Large: Size 14, Height 1.43
///
/// Title Styles:
/// - Title Small: Size 14, Height 1.43
/// - Title Medium: Size 16, Height 1.5
/// - Title Large: Size 22, Height 1.27
///
/// Headline Styles:
/// - Headline Small: Size 24, Height 1.33
/// - Headline Medium: Size 28, Height 1.29
/// - Headline Large: Size 32, Height 1.25
///
/// Display Styles:
/// - Display Small: Size 36, Height 1.22
/// - Display Medium: Size 45, Height 1.16
/// - Display Large: Size 57, Height 1.12
