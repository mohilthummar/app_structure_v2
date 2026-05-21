import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._repo);

  final AuthRepository _repo;

  // ── State ─────────────────────────────────────────────────────────────
  final state = ViewState.idle.obs;
  final errorMessage = ''.obs;
  final isPasswordHidden = true.obs;

  // ── Form ──────────────────────────────────────────────────────────────
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

    state.value = ViewState.loading;
    try {
      final response = await _repo.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
      Get.find<AuthController>().applyLoginResponse(response);
      state.value = ViewState.success;
      Get.offAllNamed(RouteNames.home);
      return true;
    } catch (e) {
      state.value = ViewState.error;
      errorMessage.value = e.toString();
      AppSnackBar.error(message: e.toString());
      return false;
    }
  }

  void onTogglePassword() => isPasswordHidden.toggle();
  void onForgotPassword() => Get.toNamed(RouteNames.forgotPassword);
}
