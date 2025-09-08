import 'package:app_structure/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🧠 Shared bootstrap logic for both app runtime and widget testing
Future<void> bootstrap() async {
  try {
    /// 🧱 Ensure widget binding is initialized before calling native platform code
    WidgetsFlutterBinding.ensureInitialized();

    /// 🍯 Initialize Hive for local message storage
    // await HiveConfig.initializeHive();

    /// 💾 Initialize GetStorage and preload local app data
    // await GetStorage.init().then((_) async => await LocalStorage.readDataInfo());

    /// 🔥 Initialize Firebase (using env-specific options)
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    /// 🔔 Setup push notifications and local notifications
    // await NotificationService.init();

    /// 🔄 Lock the app orientation to portrait mode (both up & down)
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // 🧠 Start Firebase Crashlytics to track app-level errors in real-time
    // CrashAnalyticsManager.initialize();
  } catch (e) {
    /// 🛑 Handle early-stage errors and print them safely
    printError(type: "Error 'void main()' before [MyApp]", text: e);
  }
}
