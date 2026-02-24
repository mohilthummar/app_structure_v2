import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text;
    int selectionIndex = newValue.selection.end;

    // Check if input is valid
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newText)) {
      return oldValue;
    }

    // Split the input into parts before and after the decimal point
    final parts = newText.split('.');

    // Check the number of digits before the decimal point
    if (parts[0].length > 3) {
      return oldValue;
    }

    // Check the number of digits after the decimal point
    if (parts.length > 1 && parts[1].length > decimalRange) {
      return oldValue;
    }

    // If there is no decimal point yet and the length exceeds 3 digits, add the decimal point
    if (parts.length == 1 && newText.length > 3) {
      final String newString = '${newText.substring(0, 3)}.${newText.substring(3)}';
      selectionIndex++;
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
    }

    return newValue;
  }
}
