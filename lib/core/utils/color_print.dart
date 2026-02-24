import 'dart:io';

import 'package:flutter/foundation.dart';

/// Utility class for printing colored text to the console
class AppPrint {
  AppPrint._();

  /// Print info message in blue
  static void info(dynamic text) {
    _printColoredMessage('ℹ️ $text', '\x1B[94m');
  }

  /// Print success message in green
  static void success(dynamic text) {
    _printColoredMessage('✅ $text', '\x1B[92m');
  }

  /// Print warning message in yellow
  static void warning(dynamic text) {
    _printColoredMessage('⚠️ $text', '\x1B[93m');
  }

  /// Print error message in red
  static void error({required String type, required dynamic text}) {
    _printColoredMessage('❌ $type: $text', '\x1B[91m');
  }

  /// Print debug message in purple
  static void debug(dynamic text) {
    _printColoredMessage('🐛 $text', '\x1B[95m');
  }

  /// Print data message in cyan
  static void data({required String type, required dynamic text}) {
    _printColoredMessage('📊 $type: $text', '\x1B[96m');
  }

  /// Internal function to print colored messages based on platform
  static void _printColoredMessage(dynamic text, String colorCode) {
    if (!kDebugMode) return;

    if (Platform.isAndroid) {
      debugPrint('$colorCode$text\x1B[0m', wrapWidth: 99999);
    } else {
      debugPrint(text.toString(), wrapWidth: 99999);
    }
  }
}
