import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_typography.dart';

/// AppTheme — light and dark configurations built from `AppColors`,
/// `AppDimensions`, and `AppTypography` tokens. No inline color/size literals.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.light,
/// )
/// ```
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _baseTheme(Brightness.light);
  static ThemeData get darkTheme => _baseTheme(Brightness.dark);

  static ThemeData getTheme(Brightness brightness) => brightness == Brightness.light ? lightTheme : darkTheme;

  static ThemeData getOppositeTheme(Brightness brightness) => brightness == Brightness.light ? darkTheme : lightTheme;

  static ThemeData _baseTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final foundation = isLight ? ThemeData.light() : ThemeData.dark();

    return foundation.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      disabledColor: AppColors.disableColor,
      hoverColor: isLight ? const Color(0x80C5C2C2) : const Color(0xC7C9C0C0),
      splashColor: isLight ? const Color(0x66C8C8C8) : const Color(0xBEF3EFEF),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      highlightColor: Colors.transparent,
      primaryColor: AppColors.primaryColor,

      appBarTheme: AppBarTheme(
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: AppTypography.semibold(AppTypography.base).copyWith(color: AppColors.primaryTextColor),
      ),

      textTheme: _buildTextTheme(foundation.textTheme),
      primaryTextTheme: _buildTextTheme(foundation.primaryTextTheme),

      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius20)),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.containerFillColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius12,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.containerFillColor,
        contentPadding: AppDimensions.inputPadding,
        hintStyle: AppTypography.sm.copyWith(color: AppColors.placeholder),
        labelStyle: AppTypography.sm.copyWith(color: AppColors.primaryTextColor),
        errorStyle: AppTypography.xs.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius10,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius10,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius10,
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius10,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius10,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteTextColor,
          disabledBackgroundColor: AppColors.disableColor,
          disabledForegroundColor: AppColors.whiteTextColor,
          elevation: 2,
          shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius10,
          ),
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius10,
          ),
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryColor;
          return AppColors.white;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.gray300, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius4),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryColor;
          return AppColors.switchDisabled;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryColor;
          return AppColors.gray300;
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerAndBorderColor,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.primaryColor, size: 24),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryColor),

      tabBarTheme: const TabBarThemeData(indicatorColor: AppColors.primaryColor),

      colorScheme: isLight
          ? const ColorScheme.light().copyWith(
              brightness: Brightness.light,
              primary: AppColors.primaryColor,
              surface: AppColors.backgroundColor,
              onPrimary: AppColors.whiteTextColor,
              onSurface: AppColors.primaryTextColor,
              error: AppColors.error,
              onError: AppColors.whiteTextColor,
            )
          : const ColorScheme.dark().copyWith(
              brightness: Brightness.dark,
              primary: AppColors.primaryColor,
              surface: AppColors.backgroundColor,
              onPrimary: AppColors.whiteTextColor,
              onSurface: AppColors.primaryTextColor,
              error: AppColors.error,
              onError: AppColors.whiteTextColor,
            ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: AppTypography.bold(AppTypography.text2xl).copyWith(color: base.displayLarge?.color),
      displayMedium: AppTypography.bold(AppTypography.xl).copyWith(color: base.displayMedium?.color),
      displaySmall: AppTypography.semibold(AppTypography.xl).copyWith(color: base.displaySmall?.color),
      headlineLarge: AppTypography.semibold(AppTypography.lg).copyWith(color: base.headlineLarge?.color),
      headlineMedium: AppTypography.semibold(AppTypography.base).copyWith(color: base.headlineMedium?.color),
      headlineSmall: AppTypography.semibold(AppTypography.md).copyWith(color: base.headlineSmall?.color),
      titleLarge: AppTypography.semibold(AppTypography.md).copyWith(color: base.titleLarge?.color),
      titleMedium: AppTypography.semibold(AppTypography.sm).copyWith(color: base.titleMedium?.color),
      titleSmall: AppTypography.medium(AppTypography.sm).copyWith(color: base.titleSmall?.color),
      bodyLarge: AppTypography.md.copyWith(color: base.bodyLarge?.color),
      bodyMedium: AppTypography.sm.copyWith(color: base.bodyMedium?.color),
      bodySmall: AppTypography.xs.copyWith(color: base.bodySmall?.color),
      labelLarge: AppTypography.smMedium.copyWith(color: base.labelLarge?.color),
      labelMedium: AppTypography.xsMedium.copyWith(color: base.labelMedium?.color),
      labelSmall: AppTypography.xxs.copyWith(color: base.labelSmall?.color),
    );
  }
}
