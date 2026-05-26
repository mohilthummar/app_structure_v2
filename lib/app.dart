import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/controllers/locale_controller.dart';
import 'package:app_structure/core/controllers/theme_controller.dart';
import 'package:app_structure/core/i18n/app_translations.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/routing/app_pages.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/services/analytics_service.dart';
import 'package:app_structure/core/theme/app_theme.dart';
import 'package:app_structure/core/utils/app_scroll_behavior.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<AnalyticsService>();
    final translations = Get.find<AppTranslations>();
    final localeController = Get.find<LocaleController>();
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => GetMaterialApp(
        title: I18n.appName.tr,
        themeMode: themeController.mode.value,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        getPages: AppPages.pages,
        initialRoute: RouteNames.splash,
        navigatorObservers: [analytics.observer],
        translations: translations,
        locale: localeController.currentLocale.value,
        fallbackLocale: AppTranslations.fallbackLocale,
        supportedLocales: AppTranslations.supportedLocales,
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
