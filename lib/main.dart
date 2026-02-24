import 'package:app_structure/app.dart';
import 'package:app_structure/bootstrap.dart';
import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/enums/common_enums.dart';
import 'package:flutter/material.dart';

void main() async {
  /// 🧱 Bootstrap first (loads .env, binding, orientation, etc.)
  await bootstrap();

  /// 🧩 Set environment after .env is loaded so baseUrl and flags are correct
  AppEnvironment.setEnvironment(EnvironmentType.development);

  /// 🏁 Run the app
  runApp(const MyApp());
}
