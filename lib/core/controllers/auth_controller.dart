import 'package:get/get.dart';

import 'package:app_structure/core/routing/route_names.dart';
import 'package:app_structure/features/auth/data/login_response.dart';
import 'package:app_structure/features/auth/data/user_model.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

/// App-wide auth state. Feature controllers (LoginController etc.) call
/// `applyLoginResponse(response)` after a successful API call, and
/// `logout()` from any logout button — never clear tokens or navigate
/// manually elsewhere.
class AuthController extends GetxController {
  AuthController(this._repo);

  final AuthRepository _repo;

  final user = Rxn<UserModel>();
  final loginResponse = Rxn<LoginResponse>();

  /// Synchronous bool backed by the in-memory `user`. Set on login and on
  /// successful boot rehydration; cleared on logout.
  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  /// Rehydrate state at app start. Reads `LocalStorage.userDataJson` if a
  /// token is present in `SecureStorage`.
  Future<void> checkAuth() async {
    if (await _repo.isAuthenticated()) {
      user.value = await _repo.getStoredUser();
    }
  }

  /// Update global auth state after a successful login.
  void applyLoginResponse(LoginResponse response) {
    loginResponse.value = response;
    user.value = response.user;
  }

  /// Single logout entry point. Tolerates API failure; always clears
  /// storage and navigates to login; then disposes every non-permanent
  /// GetX instance so a different user starts clean.
  Future<void> logout({String? deviceId}) async {
    try {
      await _repo.logout(deviceId: deviceId);
    } catch (_) {
      // Repo already tolerates API failure and does local cleanup.
    }

    user.value = null;
    loginResponse.value = null;

    try {
      Get.offAllNamed(RouteNames.login);
    } catch (_) {
      // Navigator may be unmounted in tests.
    }

    await Future<void>.delayed(Duration.zero);
    await Get.deleteAll(force: false);
  }
}
