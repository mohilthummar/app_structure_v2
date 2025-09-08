import 'dart:io';

import 'package:flutter/material.dart';

/// Utility functions for printing colored text to the console (Android only).
///
/// Usage:
/// ```dart
/// printRed('Error!');
/// printGreen('Success!');
/// printBlue('Info!');
/// printError(type: 'Error', text: 'Something went wrong');
/// ```
///
/// Note: Colors only appear on Android console. On other platforms, prints plain text.
///
/// For production logging, prefer a proper logging package.
void printRed(dynamic text) => _printColoredMessage(text, '\x1B[91m');

/// Prints text in green color (for success messages).
void printGreen(dynamic text) => _printColoredMessage(text, '\x1B[92m');

/// Prints text in yellow color (for warnings or info).
void printYellow(dynamic text) => _printColoredMessage(text, '\x1B[93m');

/// Prints text in blue color (for info messages).
void printBlue(dynamic text) => _printColoredMessage(text, '\x1B[94m');

/// Prints text in purple color.
void printPurple(dynamic text) => _printColoredMessage(text, '\x1B[95m');

/// Prints text in white color.
void printWhite(dynamic text) => _printColoredMessage(text, '\x1B[97m');

/// Prints an error message with a specified type label.
void printError({required dynamic type, required dynamic text}) => _printColoredMessage(' [1m$type: $text', '\x1B[51m\x1B[91m');

/// Prints a general message with a specified type label.
void printMessage({required dynamic type, required dynamic text}) => _printColoredMessage(' [1m$type: $text', '\x1B[51m\x1B[96m');

/// Prints data with a specified type label.
void printData({required dynamic type, required dynamic text}) => _printColoredMessage(' [1m$type:\n$text', '\x1B[7m');

/// Internal function to print colored messages based on platform.
/// On Android, uses ANSI color codes; on other platforms, prints plain text.
void _printColoredMessage(dynamic text, String colorCode) {
  if (Platform.isAndroid) {
    debugPrint('$colorCode$text\x1B[0m', wrapWidth: 99999);
  } else {
    debugPrint(text.toString(), wrapWidth: 99999);
  }
}
