import 'package:app_structure/core/network/header_builder.dart';
import 'package:app_structure/core/storage/preferences.dart';
import 'package:dio/dio.dart';

/// Interceptor for handling authentication and authorization in HTTP requests
/// Automatically adds authentication headers and handles authentication-related errors
class AuthInterceptor extends Interceptor {
  /// Called before a request is sent
  /// Adds authentication headers if a token is available
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    final HeaderBuilder headerBuilder = HeaderBuilder();

    // Get the stored authentication token
    final String? token = Preferences.token;

    // Add Bearer token to headers if available
    if (token != null && token.isNotEmpty) {
      options.headers = headerBuilder.setBearerToken(token).build();
      options.contentType = Headers.jsonContentType;
      // options.headers['Accept'] = Headers.jsonContentType;
    }
  }

  /// Called when an error occurs during the request
  /// Handles authentication and authorization errors
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    // Handle 401 Unauthorized errors
    if (statusCode == 401) {
      // Unauthorized - user needs to re-authenticate
      // Handle logout and navigation first
      _handleUnauthorizedError();
      // Then let the error propagate so ApiService can catch it and return Failure
      // This ensures the error is properly handled in the Result pattern
      handler.next(err);
      return;
    }

    // Handle other status codes
    switch (statusCode) {
      case 480:
        // Custom status code for specific app logic
        _handleCustomError();
        handler.next(err);
        return;
      default:
        // Let other errors be handled normally
        handler.next(err);
        return;
    }
  }

  /// Handles 401 Unauthorized errors by logging out the user and redirecting to sign in
  void _handleUnauthorizedError() {
    // Clear local preferences first (synchronous)
    Preferences.logout();

    // Sign out
    // Navigate to login screen
    // Use a microtask to ensure navigation happens after current execution
    Future.microtask(() {
      // Get.offAllNamed(RoutesName.loginView);
    });
  }

  /// Handles custom 480 status code by updating the bottom bar navigation
  void _handleCustomError() {}
}
