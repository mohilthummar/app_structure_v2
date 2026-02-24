import 'package:app_structure/routes/routes_name.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  void navigation() {
    Get.toNamed(RoutesName.signInView);
  }

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () => navigation());
    super.onInit();
  }
}
