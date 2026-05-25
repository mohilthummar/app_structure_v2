import 'package:get/get.dart';

import 'package:app_structure/features/home/presentation/profile/profile_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}
