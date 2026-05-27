import 'package:intl/intl.dart';

/// Indian-rupee currency formatting on `int`, `double`, `num`, and `String`.
///
/// Defaults: locale `en_IN`, symbol `₹`, 0 decimals for ints / 2 for doubles.
/// Override at the call site for other currencies or precision.
///
/// Usage:
/// ```dart
/// 100000.toCurrency();              // '₹1,00,000'
/// 123456.78.toCurrency();           // '₹1,23,456.78'
/// 50000.5.toCompactCurrency();      // '₹50K'
/// '12345.67'.toCurrency();          // '₹12,345.67'
/// 100.toCurrency(symbol: '\$', locale: 'en_US'); // '$100'
/// ```
extension CurrencyIntFormatting on int {
  String toCurrency({String locale = 'en_IN', String symbol = '₹'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0).format(this);
  }

  String toCompactCurrency({String locale = 'en_IN', String symbol = '₹'}) {
    return NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: 0).format(this);
  }
}

extension CurrencyDoubleFormatting on double {
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits).format(this);
  }

  String toCompactCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    return NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: decimalDigits).format(this);
  }
}

/// Works on both `int` and `double` — uses 0 decimals for ints and 2 for
/// doubles unless [decimalDigits] is set.
extension CurrencyNumFormatting on num {
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int? decimalDigits}) {
    final digits = decimalDigits ?? (this is int ? 0 : 2);
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: digits).format(this);
  }

  String toCompactCurrency({String locale = 'en_IN', String symbol = '₹', int? decimalDigits}) {
    final digits = decimalDigits ?? (this is int ? 0 : 2);
    return NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: digits).format(this);
  }
}

/// Parse + format currency strings. Returns the zero-formatted value
/// (`'₹0.00'` / `'₹0'`) on parse failure.
extension CurrencyStringFormatting on String {
  String toCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    final fmt = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
    try {
      return fmt.format(double.parse(this));
    } catch (_) {
      return fmt.format(0);
    }
  }

  String toCompactCurrency({String locale = 'en_IN', String symbol = '₹', int decimalDigits = 2}) {
    final fmt = NumberFormat.compactCurrency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);
    try {
      return fmt.format(double.parse(this));
    } catch (_) {
      return fmt.format(0);
    }
  }
}
