import 'package:intl/intl.dart';

/// Extension on int to provide currency formatting capabilities
/// Formats integers as Indian currency with the ₹ symbol and comma separators
///
/// Example usage:
/// ```dart
/// int amount = 100000;
/// String formatted = amount.toCurrency(); // Returns "₹1,00,000"
/// ```
extension CurrencyIntFormatting on int {
  /// Formats the integer as Indian currency (₹1,00,000)
  String toCurrency({String locale = 'en_IN', String symbol = '₹'}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
    return format.format(this);
  }

  /// Formats the integer as compact Indian currency (₹1K, ₹1L, etc.)
  String toCompactCurrency({String locale = 'en-INR', String symbol = '₹'}) {
    final format = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: 0);
    return format.format(this);
  }
}

/// Extension on double to provide currency formatting capabilities
/// Formats doubles as Indian currency with the ₹ symbol, comma separators, and decimals
///
/// Example usage:
/// ```dart
/// double amount = 123456.78;
/// String formatted = amount.toCurrency(); // Returns "₹1,23,456.78"
/// ```
extension CurrencyDoubleFormatting on double {
  /// Formats the double as Indian currency (₹1,23,456.78)
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
    return format.format(this);
  }

  /// Formats the double as compact Indian currency (₹1.2K, ₹1.5L, etc.)
  String toCompactCurrency({String locale = 'en-INR', String symbol = '₹', int decimalDigits = 2}) {
    final format = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
    return format.format(this);
  }
}

/// Extension on num to provide currency formatting for both int and double
///
/// Example usage:
/// ```dart
/// num amount = 50000.5;
/// String formatted = amount.toCurrency(); // Returns "₹50,000.50"
/// ```
extension CurrencyNumFormatting on num {
  /// Formats the num as Indian currency (₹50,000.50)
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int? decimalDigits}) {
    final digits = decimalDigits ?? (this is int ? 0 : 2);
    final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: digits);
    return format.format(this);
  }

  /// Formats the num as compact Indian currency (₹50K, ₹1.2L, etc.)
  String toCompactCurrency({String locale = 'en-INR', String symbol = '₹', int? decimalDigits}) {
    final digits = decimalDigits ?? (this is int ? 0 : 2);
    final format = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: digits);
    return format.format(this);
  }
}

/// Extension on String to provide currency parsing and formatting
///
/// Example usage:
/// ```dart
/// String value = "12345.67";
/// String formatted = value.toCurrency(); // Returns "₹12,345.67"
/// ```
extension CurrencyStringFormatting on String {
  /// Parses the string as a double and formats as Indian currency
  /// Returns "₹0.00" if parsing fails
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    try {
      final value = double.parse(this);
      final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
      return format.format(value);
    } catch (e) {
      final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
      return format.format(0);
    }
  }

  /// Parses the string as a double and formats as compact Indian currency
  /// Returns "₹0" if parsing fails
  String toCompactCurrency({String locale = 'en-INR', String symbol = '₹', int decimalDigits = 2}) {
    try {
      final value = double.parse(this);
      final format = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
      return format.format(value);
    } catch (e) {
      final format = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
      return format.format(0);
    }
  }
}
