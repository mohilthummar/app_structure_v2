import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/app.dart';
import 'package:app_structure/bootstrap.dart';
import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/di/initial_binding.dart';
import 'package:app_structure/core/enums/environment_enums.dart';
import 'package:app_structure/core/storage/local_storage.dart';

Future<void> main() async {
  // 1. Bootstrap: dotenv, Firebase, status bar, orientation.
  await bootstrap();

  // 2. Pick environment — flip this constant in a new project.
  AppEnvironment.setEnvironment(EnvironmentType.development);

  // 3. Wire DI graph (storage, network, auth controller).
  InitialBinding().dependencies();

  // 4. Async warmup for GetStorage (sync reads after this).
  await Get.find<LocalStorageService>().init();

  // 5. Launch app.
  runApp(const MyApp());
}
