import 'package:flutter/material.dart';

/// App-wide color tokens.
///
/// **Rule:** never inline `Color(0xFF…)` in feature/shared code. If the
/// color you need isn't here, add it. Don't create duplicate tokens for
/// the same hex — reuse the existing one.
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════════════════════════════
  // v2 template tokens (existing — DO NOT REMOVE or RENAME)
  // ════════════════════════════════════════════════════════════════════════

  /// Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFff3333);
  static const Color yellow = Color(0xFFFFAC33);
  static const Color green = Color(0xFF2BEF83);

  /// App Specific Colors
  static const Color primaryColor = Color(0xFF264653);

  static const Color primaryTextColor = Color(0xFF264653);
  static const Color darkGreyTextColor = Color(0xFF837E80);
  static const Color lightGreyTextColor = Color(0xFFB9B6B8);
  static const Color whiteTextColor = Color(0xFFFFFFFF);

  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color containerFillColor = Color(0xFFF4F5F6);
  static const Color disableColor = Color(0x33264653);
  static const Color dividerAndBorderColor = Color(0xFFB9B6B8);
  static const Color hintColor = Color(0xFF264653);

  static const Color profitColor = Color(0xff00AD26);
  static const Color lossColor = Color(0xffE3374E);
  static const Color dayLeftColor = Color(0xffFF6174);

  // ════════════════════════════════════════════════════════════════════════
  // Skeleton design tokens (added in skeleton-update from happypet)
  // ════════════════════════════════════════════════════════════════════════

  // Orange brand scale
  static const Color orange25 = Color(0xFFFFDCCC);
  static const Color orange50 = Color(0xFFFFC4AA);
  static const Color orange75 = Color(0xFFFFF8F4);
  static const Color orange100 = Color(0xFFFFA680);
  static const Color orange200 = Color(0xFFFF8955);
  static const Color orange300 = Color(0xFFFF6C2B);
  static const Color orange400 = Color(0xFFFF4E00);
  static const Color orange500 = Color(0xFFD44100);
  static const Color orange600 = Color(0xFFAA3400);
  static const Color orange700 = Color(0xFF802700);
  static const Color orange800 = Color(0xFF551A00);
  static const Color orange900 = Color(0xFF331000);

  static const Color orangeHover = Color(0xFFFF631E);
  static const Color orangeHoverBg = Color(0xFFFFEFE8);
  static const Color orangeLight = Color(0xFFFFF5F1);
  static const Color orangeSelected = Color(0x0DFF4E00);

  // Gray scale
  static const Color gray25 = Color(0xFFFCFCFD);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF2F4F7);
  static const Color gray150 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFEAECF0);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray350 = Color(0xFFE7E7E7);
  static const Color gray400 = Color(0xFF98A2B3);
  static const Color gray450 = Color(0xFF6B7280);
  static const Color gray500 = Color(0xFF667085);
  static const Color gray550 = Color(0xFF7A7A7A);
  static const Color gray600 = Color(0xFF475467);
  static const Color gray700 = Color(0xFF344054);
  static const Color gray800 = Color(0xFF1D2939);
  static const Color gray900 = Color(0xFF101828);

  // Status: success / error / warning / info
  static const Color success = Color(0xFF12B76A);
  static const Color successDark = Color(0xFF039855);
  static const Color successLight = Color(0xFF32D583);
  static const Color successMid = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFECFDF3);
  static const Color successBgStrong = Color(0xFFDCFCE7);

  static const Color error = Color(0xFFF04438);
  static const Color errorDark = Color(0xFFD92D20);
  static const Color errorBorder = Color(0xFFF97066);
  static const Color errorBg = Color(0xFFFEF3F2);

  static const Color warning = Color(0xFFF79009);
  static const Color warningDark = Color(0xFFDC6803);
  static const Color warningMid = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBg = Color(0xFFFFFBEB);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoMid = Color(0xFF2E90FA);
  static const Color infoDark = Color(0xFF175CD3);
  static const Color infoBg = Color(0xFFEFF8FF);

  // Toast (semantic accents used by AppSnackBar)
  static const Color toastSuccess = Color(0xFF00B716);
  static const Color toastError = Color(0xFFD01222);
  static const Color toastWarning = Color(0xFFFFAE06);
  static const Color toastInfo = Color(0xFF47AFFF);

  // Accents
  static const Color teal = Color(0xFF12BAA9);
  static const Color indigo = Color(0xFF4F34D3);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleBg = Color(0xFFF4F3FF);

  static const Color emptyStateIcon = Color(0xFF615E83);

  // Semantic
  static const Color placeholder = Color(0xFFADABAC);
  static const Color inputText = Color(0xFF111928);
  static const Color backdrop = Color(0x80121212);
  static const Color transparent = Color(0x00000000);

  // Switch / scrollbar
  static const Color switchDisabled = Color(0xFFD1D5DB);
  static const Color scrollbarTrack = Color(0xFFF1F1F1);
  static const Color scrollbarThumb = Color(0xFFCBD5E1);
  static const Color scrollbarThumbHover = Color(0xFF94A3B8);

  // Material hover / splash (used by AppTheme — both brightnesses)
  static const Color hoverLight = Color(0x80C5C2C2);
  static const Color hoverDark = Color(0xC7C9C0C0);
  static const Color splashLight = Color(0x66C8C8C8);
  static const Color splashDark = Color(0xBEF3EFEF);

  // ════════════════════════════════════════════════════════════════════════
  // Dark-mode surface tokens
  // Used by AppTheme via the `isLight ? X : XDark` selector. If you add
  // a new light token that participates in the theme, add its dark
  // counterpart here too — otherwise dark mode will look broken.
  // ════════════════════════════════════════════════════════════════════════

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color containerFillDark = Color(0xFF2A2A2A);
  static const Color primaryTextDark = Color(0xFFE5E5E5);
  static const Color secondaryTextDark = Color(0xFFB3B3B3);
  static const Color disabledTextDark = Color(0xFF6E6E6E);
  static const Color dividerDark = Color(0xFF2F2F2F);
  static const Color placeholderDark = Color(0xFF6E6E6E);
  static const Color primaryDark = Color(0xFF7BA7B6);

  // Primary swatch (brand orange)
  static MaterialColor get primarySwatch => MaterialColor(
    orange400.toARGB32(),
    const <int, Color>{
      50: orange75,
      100: orange100,
      200: orange200,
      300: orange300,
      400: orange400,
      500: orange500,
      600: orange600,
      700: orange700,
      800: orange800,
      900: orange900,
    },
  );
}
