import 'package:app_structure/core/base/base_view_controller.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/core/services/deep_linking_manager.dart';
import 'package:app_structure/core/theme/app_theme.dart';
import 'package:app_structure/core/utils/stretch_scroll_behavior.dart';
import 'package:app_structure/routes/routes.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          themeMode: ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialBinding: LazyBinding(),
          debugShowCheckedModeBanner: false,
          scrollBehavior: ScrollBehaviorModified(),
          // navigatorObservers: [CustomRouteObserver(), ChatRouteObserver()],
          // navigatorKey: GlobalContext.instance.navigatorKey,
          getPages: pages,
          initialRoute: RoutesName.splashView,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);

            // Clamp system font scaling between 1.0 and 1.14 (or any range you prefer)
            final clampedTextScaler = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.14);

            // Optional: Wrap with banner for environment display
            final Widget app = MediaQuery(
              data: mediaQueryData.copyWith(textScaler: clampedTextScaler),
              child: child!,
            );

            return app;
          },
        );
      },
    );
  }
}

class LazyBinding implements Bindings {
  @override
  void dependencies() {
    // Register core services
    Get.put(BaseViewController(), permanent: true);
    Get.put(DeepLinkManager(), permanent: true);

    /* if (kDebugMode || LocalStorage.isInternalTester) {
      Get.put(OverlayController(), permanent: true);
    } */
  }
}
