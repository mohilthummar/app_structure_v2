import 'package:flutter/services.dart';

/// A [TextInputFormatter] that allows only valid double values (e.g., 123.45).
/// Blocks invalid characters and multiple decimals.
///
/// Usage:
/// ```dart
/// TextField(
///   inputFormatters: [DoubleRangeInputFormatter()],
/// )
/// ```
class DoubleRangeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }
    final doubleValue = double.tryParse(newValue.text);
    if (doubleValue != null) {
      return newValue;
    }
    return oldValue;
  }
}
