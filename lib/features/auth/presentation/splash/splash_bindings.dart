import 'package:get/get.dart';

import 'package:app_structure/features/auth/presentation/splash/splash_controller.dart';

class SplashBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
