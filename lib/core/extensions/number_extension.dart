import 'dart:math';

import 'package:intl/intl.dart';

/// Extension on int to provide number formatting capabilities
/// Formats integers using Indian number system with comma separators
///
/// Example usage:
/// ```dart
/// class NumberUtils {
///   void formatInteger(int value) {
///     String formatted = value.formatNumber(); // Returns "1,00,000"
///   }
/// }
/// ```
extension NumberFormatting on int {
  /// Formats the integer using Indian number system
  ///
  /// Returns a string with comma separators following Indian format
  /// Example: 100000 becomes "1,00,000"
  String formatNumber() {
    final format = NumberFormat('##,##,##,##0', 'en_IN');
    return format.format(this);
  }

  /// Converts the integer to a compact format
  ///
  /// Returns a string like "1K", "1M", "1B" for large numbers
  /// Example: 1000 becomes "1K", 1000000 becomes "1M"
  String toCompactFormat() {
    return NumberFormat.compact(locale: 'en-INR').format(this);
  }

  /// Checks if the number is positive
  bool get isPositive => this > 0;

  /// Checks if the number is negative
  bool get isNegative => this < 0;

  /// Checks if the number is zero
  bool get isZero => this == 0;

  /// Checks if the number is even
  bool get isEven => this % 2 == 0;

  /// Checks if the number is odd
  bool get isOdd => this % 2 != 0;
}

/// Extension on double to provide number formatting capabilities
/// Formats doubles using Indian number system with decimal places
///
/// Example usage:
/// ```dart
/// class NumberUtils {
///   void formatDouble(double value) {
///     String formatted = value.formatNumber(); // Returns "1,00,000.50"
///   }
/// }
/// ```
extension NumberDoubleFormatting on double {
  /// Formats the double using Indian number system with 2 decimal places
  ///
  /// Returns a string with comma separators and decimal places
  /// Example: 100000.5 becomes "1,00,000.50"
  String formatNumber() {
    final format = NumberFormat('##,##,##,##0.00', 'en_IN');
    return format.format(this);
  }

  /// Formats the double with specified decimal places
  ///
  /// [decimals] - Number of decimal places to show
  /// Returns a formatted string with specified decimal places
  String formatNumberWithDecimals(int decimals) {
    final format = NumberFormat("##,##,##,##0.${'0' * decimals}", 'en_IN');
    return format.format(this);
  }

  /// Converts the double to a compact format
  ///
  /// Returns a string like "1.5K", "2.3M" for large numbers
  String toCompactFormat() {
    return NumberFormat.compact(locale: 'en-INR').format(this);
  }

  /// Rounds the double to specified decimal places
  ///
  /// [decimals] - Number of decimal places to round to
  /// Returns a double rounded to specified decimal places
  double roundToDecimals(int decimals) {
    final double multiplier = pow(10.0, decimals).toDouble();
    return (this * multiplier).round() / multiplier;
  }

  /// Checks if the number is positive
  bool get isPositive => this > 0;

  /// Checks if the number is negative
  bool get isNegative => this < 0;

  /// Checks if the number is zero
  bool get isZero => this == 0;

  /// Checks if the number is an integer
  bool get isInteger => this == toInt();
}

/// Extension on String to provide number parsing and formatting capabilities
/// Converts strings to numbers and formats them appropriately
///
/// Example usage:
/// ```dart
/// class StringUtils {
///   void parseNumber(String value) {
///     double number = value.toDouble(); // Converts "123.45" to 123.45
///     String formatted = value.formatNumber(); // Returns "123.45"
///   }
/// }
/// ```
extension StringFormatting on String {
  /// Formats the string as a number using Indian number system
  ///
  /// Parses the string as double and formats it with 2 decimal places
  /// Returns a formatted string or "0.00" if parsing fails
  String formatNumber() {
    try {
      final format = NumberFormat('##,##,##,##0.00', 'en_IN');
      return format.format(double.parse(this));
    } catch (e) {
      return '0.00';
    }
  }

  /// Converts the string to a double
  ///
  /// Returns the parsed double value
  /// Throws FormatException if the string cannot be parsed
  double toDouble() {
    return double.parse(this);
  }

  /// Converts the string to a num (int or double)
  ///
  /// Returns the parsed num value
  /// Throws FormatException if the string cannot be parsed
  num toNum() {
    return num.parse(this);
  }

  /// Converts the string to an integer
  ///
  /// Returns the parsed integer value
  /// Throws FormatException if the string cannot be parsed
  int toInt() {
    return int.parse(this);
  }

  /// Safely converts the string to a double
  ///
  /// Returns the parsed double value or null if parsing fails
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Safely converts the string to an integer
  ///
  /// Returns the parsed integer value or null if parsing fails
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Checks if the string can be parsed as a number
  ///
  /// Returns true if the string represents a valid number, false otherwise
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Checks if the string can be parsed as an integer
  ///
  /// Returns true if the string represents a valid integer, false otherwise
  bool get isInteger {
    return int.tryParse(this) != null;
  }

  /// Removes all non-numeric characters from the string
  ///
  /// Returns a string containing only digits and decimal points
  String get numericOnly {
    return replaceAll(RegExp(r'[^0-9.]'), '');
  }
}

/// Extension on String to provide compact number formatting
/// Formats large numbers into compact form (K, M, B, etc.)
///
/// Example usage:
/// ```dart
/// class CompactUtils {
///   void formatLargeNumber(String value) {
///     String compact = value.compactNumber(); // Returns "1.2K" for "1200"
///   }
/// }
/// ```
extension NumberCompactFormatting on String {
  /// Converts the string to a compact number format
  ///
  /// Parses the string as double and formats it in compact form
  /// Returns a string like "1.2K", "3.4M", "2.1B" for large numbers
  /// Returns "0" if parsing fails
  String compactNumber() {
    // Convert number into double to be formatted
    // Default to zero if unable to do so
    final double doubleNumber = double.tryParse(this) ?? 0;

    // Set number format to use
    final NumberFormat numberFormat = NumberFormat.compact(locale: 'en-INR');

    return numberFormat.format(doubleNumber);
  }

  /// Converts the string to a compact number format with custom locale
  ///
  /// [locale] - The locale to use for formatting (e.g., "en-US", "en-INR")
  /// Returns a compact formatted string
  String compactNumberWithLocale(String locale) {
    final double doubleNumber = double.tryParse(this) ?? 0;
    final NumberFormat numberFormat = NumberFormat.compact(locale: locale);
    return numberFormat.format(doubleNumber);
  }

  /// Formats the string as currency in compact form
  ///
  /// Returns a string like "₹1.2K", "$3.4M" for currency values
  String compactCurrency() {
    final double doubleNumber = double.tryParse(this) ?? 0;
    final NumberFormat currencyFormat = NumberFormat.compactCurrency(locale: 'en-INR');
    return currencyFormat.format(doubleNumber);
  }
}

/// Extension on num to provide additional number utilities
/// Works with both int and double values
///
/// Example usage:
/// ```dart
/// class NumUtils {
///   void formatAnyNumber(num value) {
///     String formatted = value.toIndianFormat(); // Returns "1,00,000"
///   }
/// }
/// ```
extension NumFormatting on num {
  /// Formats the number using Indian number system
  ///
  /// Automatically handles both integers and doubles
  /// Returns a formatted string with appropriate decimal places
  String toIndianFormat() {
    if (this is int) {
      return NumberFormat('##,##,##,##0', 'en_IN').format(this);
    } else {
      return NumberFormat('##,##,##,##0.00', 'en_IN').format(this);
    }
  }

  /// Converts the number to a compact format
  ///
  /// Returns a string like "1K", "1.5M" for large numbers
  String toCompactFormat() {
    return NumberFormat.compact(locale: 'en-INR').format(this);
  }

  /// Checks if the number is within a specified range
  ///
  /// [min] - Minimum value (inclusive)
  /// [max] - Maximum value (inclusive)
  /// Returns true if the number is within the range, false otherwise
  bool isInRange(num min, num max) {
    return this >= min && this <= max;
  }

  /// Clamps the number to a specified range
  ///
  /// [min] - Minimum value
  /// [max] - Maximum value
  /// Returns the number clamped to the specified range
  num clampToRange(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Calculates the percentage of this number relative to a total
  ///
  /// [total] - The total value to calculate percentage against
  /// Returns the percentage as a double (0.0 to 100.0)
  double percentageOf(num total) {
    if (total == 0) return 0.0;
    return (this / total) * 100;
  }
}
