import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'core/enums/common_enums.dart';
import 'core/handler/app_environment.dart';
import 'my_app.dart';

void main() async {
  /// 🧩 Inject the selected environment into the app's configuration
  AppEnvironment.setEnvironment(EnvironmentType.development);

  /// 🧱 Execute bootstrap logic (storage, Firebase, notifications, orientation, crashlytics, etc.)
  await bootstrap();

  /// 🏁 Run the app
  runApp(const MyApp());
}
