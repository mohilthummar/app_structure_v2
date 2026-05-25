import 'package:app_structure/core/constants/app_constants.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

/// Attaches Bearer token on every request, and the CSRF header on
/// state-changing requests (POST/PUT/PATCH/DELETE) when a CSRF token is
/// stored. Reads from `SecureStorageService` only.
///
/// **Per-request opt-out:** pass `options.extra[skipAuthKey] = true` on a
/// request to suppress the Bearer header — useful for public CDN
/// downloads where the file URL is unauthenticated.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  /// Key consumers set in `Options(extra: {AuthInterceptor.skipAuthKey: true})`
  /// to skip Authorization for a single request.
  static const String skipAuthKey = 'skipAuth';

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra[skipAuthKey] == true;

    if (!skipAuth) {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    final method = options.method.toUpperCase();
    if (!skipAuth && (method == 'POST' || method == 'PUT' || method == 'PATCH' || method == 'DELETE')) {
      final csrf = await _secureStorage.getCsrfToken();
      if (csrf != null && csrf.isNotEmpty) {
        options.headers[AppConstants.csrfHeaderName] = csrf;
      }
    }

    handler.next(options);
  }
}
