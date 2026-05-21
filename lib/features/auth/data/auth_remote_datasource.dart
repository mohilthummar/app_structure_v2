import 'package:app_structure/core/config/api_urls.dart';
import 'package:app_structure/core/network/api_client.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/data/login_response.dart';

/// Thin wrapper over `ApiClient` for auth endpoints. Throws on
/// `!response.success` — the repository's try/catch surfaces these as
/// `Exception(e.toString())` for the controller layer.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<LoginResponse> login(LoginRequest request) async {
    final res = await _api.post<LoginResponse>(
      ApiUrls.login,
      data: request.toJson(),
      fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error?.message ?? 'Login failed');
    }
    return res.data!;
  }

  Future<void> forgotPassword(String email) async {
    final res = await _api.put(
      ApiUrls.forgotPassword,
      data: {'email': email},
    );
    if (!res.success) {
      throw Exception(res.error?.message ?? 'Could not send reset link');
    }
  }

  Future<void> logout({String? deviceId}) async {
    final res = await _api.post(
      ApiUrls.logout,
      data: deviceId != null ? {'device_id': deviceId} : null,
    );
    if (!res.success) {
      throw Exception(res.error?.message ?? 'Logout failed');
    }
  }
}
