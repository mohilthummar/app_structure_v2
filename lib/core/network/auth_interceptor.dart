import 'package:app_structure/core/constants/app_constants.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

/// Attaches Bearer token on every request, and the CSRF header on
/// state-changing requests (POST/PUT/PATCH/DELETE) when a CSRF token is
/// stored. Reads from `SecureStorageService` only.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH' || method == 'DELETE') {
      final csrf = await _secureStorage.getCsrfToken();
      if (csrf != null && csrf.isNotEmpty) {
        options.headers[AppConstants.csrfHeaderName] = csrf;
      }
    }

    handler.next(options);
  }
}
