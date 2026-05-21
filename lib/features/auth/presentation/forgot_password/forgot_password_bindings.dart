import 'package:get/get.dart';

import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/presentation/forgot_password/forgot_password_controller.dart';

class ForgotPasswordBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ForgotPasswordController(Get.find<AuthRepository>()),
    );
  }
}
