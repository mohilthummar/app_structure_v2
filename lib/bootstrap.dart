import 'package:app_structure/core/utils/color_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🧠 Shared bootstrap logic for app startup.
Future<void> bootstrap() async {
  try {
    /// 🧱 Ensure widget binding is initialized before calling native platform code
    WidgetsFlutterBinding.ensureInitialized();

    // Load single .env file (contains all environment configs)
    await dotenv.load(fileName: '.env');

    /// 💾 Initialize GetStorage and preload local app data
    // await GetStorage.init().then((_) async => await LocalStorage.readDataInfo());

    /// 🔥 Initialize Firebase (using env-specific options)
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    /// 🔔 Setup push notifications and local notifications
    // await NotificationService.init();

    /// 🔄 Lock the app orientation to portrait mode (both up & down)
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // 🧠 Start Firebase Crashlytics to track app-level errors in real-time
    // if (AppEnvironment.enableCrashlytics) CrashAnalyticsManager.initialize();
  } catch (e) {
    /// 🔴 Error occurred during bootstrap process
    AppPrint.error(type: 'Bootstrap Error', text: e.toString());
  }
}
