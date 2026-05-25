import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_structure/app.dart';
import 'package:app_structure/bootstrap.dart';
import 'package:app_structure/core/enums/environment_enums.dart';
import 'package:app_structure/core/error/app_error_handler.dart';

/// Entry point. Everything boot-related lives in `bootstrap.dart`; this file
/// only picks the environment and wraps `runApp` in `runZonedGuarded` so
/// uncaught async errors land in `AppErrorHandler`.
///
/// To switch environments, change `EnvironmentType.development` below to
/// `.local`, `.staging`, or `.production` — no flavors, no --dart-define.
void main() {
  runZonedGuarded(
    () async {
      await bootstrap(environment: EnvironmentType.development);
      runApp(const MyApp());
    },
    AppErrorHandler.onZoneError,
  );
}
