import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/utils/color_print.dart';

/// Shared boot logic. Called from `main.dart` BEFORE
/// `InitialBinding().dependencies()`, so `.env` and Firebase are ready
/// when the DI graph wires up.
Future<void> bootstrap() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // .env — single source of truth for env-specific URLs + flags.
    await dotenv.load(fileName: '.env');

    // Firebase — eager init. Adds ~200-400 ms cold start; matches the
    // decision in the skeleton spec.
    await Firebase.initializeApp();

    // Status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Lock to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    AppPrint.error(type: 'Bootstrap Error', text: e.toString());
  }
}
