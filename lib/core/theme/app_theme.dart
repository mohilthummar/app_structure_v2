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

    // Brightness-aware swatch — every token below picks light or dark
    // variant via the `pick` helper. Adding a new themed surface? Add
    // both light and dark tokens to AppColors and pick them here.
    Color pick(Color lightColor, Color darkColor) => isLight ? lightColor : darkColor;

    final background = pick(AppColors.backgroundColor, AppColors.backgroundDark);
    final surface = pick(AppColors.backgroundColor, AppColors.surfaceDark);
    final containerFill = pick(AppColors.containerFillColor, AppColors.containerFillDark);
    final primary = pick(AppColors.primaryColor, AppColors.primaryDark);
    final primaryText = pick(AppColors.primaryTextColor, AppColors.primaryTextDark);
    final placeholder = pick(AppColors.placeholder, AppColors.placeholderDark);
    final divider = pick(AppColors.dividerAndBorderColor, AppColors.dividerDark);

    return foundation.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      disabledColor: AppColors.disableColor,
      hoverColor: pick(AppColors.hoverLight, AppColors.hoverDark),
      splashColor: pick(AppColors.splashLight, AppColors.splashDark),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      highlightColor: Colors.transparent,
      primaryColor: primary,

      appBarTheme: AppBarTheme(
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: AppTypography.semibold(AppTypography.base).copyWith(color: primaryText),
      ),

      textTheme: _buildTextTheme(foundation.textTheme),
      primaryTextTheme: _buildTextTheme(foundation.primaryTextTheme),

      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius20)),
        ),
      ),

      cardTheme: CardThemeData(
        color: containerFill,
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius12,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: containerFill,
        contentPadding: AppDimensions.inputPadding,
        hintStyle: AppTypography.sm.copyWith(color: placeholder),
        labelStyle: AppTypography.sm.copyWith(color: primaryText),
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
          borderSide: BorderSide(color: primary, width: 1.5),
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
          backgroundColor: primary,
          foregroundColor: AppColors.whiteTextColor,
          disabledBackgroundColor: AppColors.disableColor,
          disabledForegroundColor: AppColors.whiteTextColor,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius10,
          ),
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius10,
          ),
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: AppDimensions.buttonPadding,
          textStyle: AppTypography.medium(AppTypography.md),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return AppColors.white;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.gray300, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius4),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return AppColors.switchDisabled;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return AppColors.gray300;
        }),
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: primary, size: 24),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),

      tabBarTheme: TabBarThemeData(indicatorColor: primary),

      colorScheme: isLight
          ? ColorScheme.light(
              primary: primary,
              surface: background,
              onPrimary: AppColors.whiteTextColor,
              onSurface: primaryText,
              error: AppColors.error,
              onError: AppColors.whiteTextColor,
            )
          : ColorScheme.dark(
              primary: primary,
              surface: background,
              onPrimary: AppColors.whiteTextColor,
              onSurface: primaryText,
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
