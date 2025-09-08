import 'package:dio/dio.dart';

import '../utils/preferences.dart';
import 'header_builder.dart';

/// Interceptor for handling authentication and authorization in HTTP requests
/// Automatically adds authentication headers and handles authentication-related errors
class AuthInterceptor extends Interceptor {
  /// Called before a request is sent
  /// Adds authentication headers if a token is available
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    // Get the stored authentication token
    String? token = Preferences.token;

    // Add Bearer token to headers if available
    if (token != null && token.isNotEmpty) {
      options.headers = HeaderBuilder().setBearerToken(token).build();
    }
  }

  /// Called when an error occurs during the request
  /// Handles authentication and authorization errors
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);

    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 401:
        // Unauthorized - user needs to re-authenticate
        _handleUnauthorizedError();
        break;
      case 480:
        // Custom status code for specific app logic
        _handleCustomError();
        break;
      default:
        // Let other errors be handled normally
        break;
    }
  }

  /// Handles 401 Unauthorized errors by logging out the user and redirecting to sign in
  void _handleUnauthorizedError() {
    // Clear user session
    Preferences.logout();

    // Navigate to sign in screen
    // Get.offAllNamed(RoutesName.signInView);
  }

  /// Handles custom 480 status code by updating the bottom bar navigation
  void _handleCustomError() {}
}
