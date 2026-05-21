import 'package:get/get.dart';

import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/presentation/login/login_controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}
