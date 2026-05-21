import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/core/routing/app_pages.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/theme/app_theme.dart';
import 'package:app_structure/core/utils/stretch_scroll_behavior.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => GetMaterialApp(
        title: AppStrings.appName,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        scrollBehavior: ScrollBehaviorModified(),
        getPages: AppPages.pages,
        initialRoute: RouteNames.splash,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final scaler = mq.textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.14,
          );
          return MediaQuery(
            data: mq.copyWith(textScaler: scaler),
            child: child!,
          );
        },
      ),
    );
  }
}
