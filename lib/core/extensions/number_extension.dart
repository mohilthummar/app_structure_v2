import 'dart:math';

import 'package:intl/intl.dart';

/// Number formatting + parsing helpers. Tuned for the Indian number
/// system (lakh / crore grouping like `1,00,000`) — change the locale at
/// the call site for a different format.
///
/// Usage:
/// ```dart
/// 100000.formatNumber();        // '1,00,000'
/// 1234567.toCompactFormat();    // '12.3L'
/// '12345.67'.toDouble();        // 12345.67
/// '12345.67'.formatNumber();    // '12,345.67'
/// '1500'.compactNumber();       // '1.5K'
/// '1500'.compactCurrency();     // '₹1.5K'
/// 75.percentageOf(150);         // 50.0
/// ```
extension NumberFormatting on int {
  /// Indian grouping, no decimals — `100000` → `1,00,000`.
  String formatNumber() => NumberFormat('##,##,##,##0', 'en_IN').format(this);

  /// Compact form — `1000` → `1K`, `1000000` → `10L` (Indian compact).
  String toCompactFormat() => NumberFormat.compact(locale: 'en-INR').format(this);

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}

extension NumberDoubleFormatting on double {
  /// Indian grouping with 2 decimals — `100000.5` → `1,00,000.50`.
  String formatNumber() => NumberFormat('##,##,##,##0.00', 'en_IN').format(this);

  /// Indian grouping with [decimals] decimal places.
  String formatNumberWithDecimals(int decimals) {
    return NumberFormat("##,##,##,##0.${'0' * decimals}", 'en_IN').format(this);
  }

  String toCompactFormat() => NumberFormat.compact(locale: 'en-INR').format(this);

  /// Round to [decimals] decimal places.
  double roundToDecimals(int decimals) {
    final multiplier = pow(10.0, decimals).toDouble();
    return (this * multiplier).round() / multiplier;
  }

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
  bool get isInteger => this == toInt();
}

/// String → number parsing + formatting. Use `*OrNull` variants when the
/// input may be malformed and you don't want an exception.
extension StringFormatting on String {
  /// Parse + format with Indian grouping + 2 decimals. Returns `'0.00'`
  /// on parse failure.
  String formatNumber() {
    try {
      return NumberFormat('##,##,##,##0.00', 'en_IN').format(double.parse(this));
    } catch (_) {
      return '0.00';
    }
  }

  double toDouble() => double.parse(this);
  num toNum() => num.parse(this);
  int toInt() => int.parse(this);

  double? toDoubleOrNull() => double.tryParse(this);
  int? toIntOrNull() => int.tryParse(this);

  bool get isNumeric => double.tryParse(this) != null;
  bool get isInteger => int.tryParse(this) != null;

  /// Strips everything except digits and the decimal point.
  String get numericOnly => replaceAll(RegExp(r'[^0-9.]'), '');
}

/// String → compact number formatting. Parses, then formats — handy for
/// stringly-typed APIs that ship counts as strings.
extension NumberCompactFormatting on String {
  /// `'1500'` → `'1.5K'`. Returns `'0'` on parse failure.
  String compactNumber() {
    final n = double.tryParse(this) ?? 0;
    return NumberFormat.compact(locale: 'en-INR').format(n);
  }

  String compactNumberWithLocale(String locale) {
    final n = double.tryParse(this) ?? 0;
    return NumberFormat.compact(locale: locale).format(n);
  }

  /// `'1500'` → `'₹1.5K'`. Compact Indian currency.
  String compactCurrency() {
    final n = double.tryParse(this) ?? 0;
    return NumberFormat.compactCurrency(locale: 'en-INR').format(n);
  }
}

/// Works on both `int` and `double` — pick this when the type isn't known
/// at the call site.
extension NumFormatting on num {
  /// Indian grouping. No decimals for ints, 2 decimals for doubles.
  String toIndianFormat() {
    if (this is int) return NumberFormat('##,##,##,##0', 'en_IN').format(this);
    return NumberFormat('##,##,##,##0.00', 'en_IN').format(this);
  }

  String toCompactFormat() => NumberFormat.compact(locale: 'en-INR').format(this);

  bool isInRange(num min, num max) => this >= min && this <= max;

  num clampToRange(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Percentage of [total], `0.0` … `100.0`. Returns `0.0` when total is zero.
  double percentageOf(num total) {
    if (total == 0) return 0.0;
    return (this / total) * 100;
  }
}
