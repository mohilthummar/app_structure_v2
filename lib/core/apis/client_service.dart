import 'package:app_structure/core/apis/interceptor.dart';
import 'package:app_structure/core/services/connectivity_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'base_response.dart';
import 'result.dart';

export 'base_response.dart';

/// HTTP Status Codes for reference
/// 200 = Success
/// 400 = Bad Request
/// 401 = Unauthorized
/// 403 = Forbidden
/// 404 = Not Found
/// 422 = Unprocessable Entity
/// 500 = Internal Server Error

/// Enum representing different HTTP request types supported by the API service
enum RequestType { get, post, delete, put, patch }

/// Abstract base class for API service operations
/// Provides a unified interface for making HTTP requests with proper error handling
/// and response parsing using the Result pattern
abstract class ClientService {
  /// Dio instance for making HTTP requests
  final Dio _dio = Dio();

  /// Makes an HTTP request with the specified parameters
  ///
  /// [requestType] - The type of HTTP request (GET, POST, etc.)
  /// [path] - The API endpoint path (will be appended to base URL)
  /// [data] - Request body data (for POST, PUT, PATCH requests)
  /// [queryParameters] - Query parameters for the request
  ///
  /// Returns a [Result] containing either a successful [BaseResponse] or an error message
  Future<Result<BaseResponse<dynamic>, String>> request({required RequestType requestType, required String path, dynamic data, Map<String, dynamic>? queryParameters}) async {
    // Configure Dio with base settings
    _configureDio();

    // Add interceptors for authentication and logging
    _setupInterceptors();

    Response? response;

    try {
      // Check internet connectivity before making the request
      if (await ConnectivityService.isConnected) {
        // Make the appropriate HTTP request based on request type
        response = await _makeRequest(requestType, path, data, queryParameters);

        // Parse the response
        var result = BaseResponse.fromResponse(response.data);

        // Return success or failure based on the API response
        if (result.success) {
          return Success(result);
        } else {
          return Failure(result.message);
        }
      } else {
        return Failure("No internet connection");
      }
    } on DioException catch (e) {
      // Handle Dio-specific exceptions
      return _handleDioException(e);
    } catch (e) {
      // Handle any other unexpected exceptions
      return Failure("Something went wrong");
    }
  }

  /// Configures the Dio instance with base options
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: "https://api.example.com",
      receiveDataWhenStatusError: true,
      sendTimeout: const Duration(seconds: 6),
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
      //
    );
  }

  /// Sets up interceptors for authentication and logging
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      AuthInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          //
        ),
    ]);
  }

  /// Makes the actual HTTP request based on the request type
  Future<Response> _makeRequest(RequestType requestType, String path, dynamic data, Map<String, dynamic>? queryParameters) async {
    switch (requestType) {
      case RequestType.get:
        return await _dio.get(path, queryParameters: queryParameters);
      case RequestType.post:
        return await _dio.post(path, data: data);
      case RequestType.put:
        return await _dio.put(path, data: data);
      case RequestType.patch:
        return await _dio.patch(path, data: data);
      case RequestType.delete:
        return await _dio.delete(path);
    }
  }

  /// Handles Dio-specific exceptions and returns appropriate error messages
  Result<BaseResponse<dynamic>, String> _handleDioException(DioException e) {
    // Handle connection timeout
    if (e.type == DioExceptionType.connectionTimeout) {
      return Failure("Connection timeout");
    }

    // Handle specific HTTP status codes
    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 422:
        // Unprocessable Entity - return the response as success for validation errors
        return Success(BaseResponse.fromResponse(e.response?.data));
      case 401:
        // Unauthorized - extract error message from response
        return Failure(e.response?.data['error'] ?? "Unauthorized");
      case 400:
        // Bad Request - extract error message from response
        return Failure(e.response?.data['error'] ?? "Bad Request");
      case 404:
        // Bad Request or Not Found - extract error message from response
        return Failure(e.response?.data['error'] ?? "Not Found");
      default:
        // For other status codes, try to parse the response
        if (e.response != null && e.response?.data != null) {
          var result = BaseResponse.fromResponse(e.response?.data);
          return Failure(result.message);
        } else {
          return Failure("Something went wrong");
        }
    }
  }
}

/// Exception thrown when an unsupported request type is used
class RequestTypeNotFoundException implements Exception {
  final String cause;

  RequestTypeNotFoundException(this.cause);

  @override
  String toString() => 'RequestTypeNotFoundException: $cause';
}
