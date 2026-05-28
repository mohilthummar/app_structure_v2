import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/base/base_controller.dart';
import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/mixins/validation_mixin.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

class LoginController extends BaseController with ValidationMixin {
  LoginController(this._repo);

  final AuthRepository _repo;

  final isPasswordHidden = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> onLogin() async {
    if (loginFormKey.currentState?.validate() != true) return false;

    final response = await runGuarded(
      () => _repo.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      ),
      errorTag: 'LoginController.onLogin',
    );

    if (response == null) return false;

    Get.find<AuthController>().applyLoginResponse(response);
    Get.offAllNamed(RouteNames.home);
    return true;
  }

  void onTogglePassword() => isPasswordHidden.toggle();
  void onForgotPassword() => Get.toNamed(RouteNames.forgotPassword);
}
