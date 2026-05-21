import 'package:dio/dio.dart';

/// Typed, user-safe API error. Built from a `DioException` at the
/// `ApiClient` boundary so the rest of the app never touches raw Dio types.
///
/// `message` is always safe to surface to the UI; raw URLs/headers/internal
/// hints are stripped or replaced with generic copy.
class ApiErrorModel {
  const ApiErrorModel({
    this.statusCode,
    required this.message,
    this.code,
  });

  final int? statusCode;
  final String message;
  final String? code;

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String? ?? 'An error occurred',
      code: json['code'] as String?,
    );
  }

  factory ApiErrorModel.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiErrorModel(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiErrorModel(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final data = exception.response?.data;

        if (statusCode == 404) {
          return ApiErrorModel(
            statusCode: 404,
            message: data is Map<String, dynamic> && data['message'] != null ? data['message'] as String : 'The requested resource was not found.',
            code: 'not_found',
          );
        }

        if (statusCode == 403) {
          return ApiErrorModel(
            statusCode: 403,
            message: data is Map<String, dynamic> && data['message'] != null ? data['message'] as String : 'You do not have permission to access this resource.',
            code: 'forbidden',
          );
        }

        if (statusCode == 500) {
          return ApiErrorModel(
            statusCode: 500,
            message: data is Map<String, dynamic> && data['message'] != null ? data['message'] as String : 'Internal server error. Please try again later.',
            code: 'server_error',
          );
        }

        if (data is Map<String, dynamic>) {
          return ApiErrorModel.fromJson({
            ...data,
            'statusCode': statusCode,
          });
        }
        return ApiErrorModel(
          statusCode: statusCode,
          message: 'Server error. Please try again later.',
        );
      case DioExceptionType.cancel:
        return const ApiErrorModel(message: 'Request was cancelled.');
      default:
        return const ApiErrorModel(message: 'Something went wrong. Please try again.');
    }
  }

  bool get isNotFound => statusCode == 404 || code == 'not_found';
  bool get isForbidden => statusCode == 403 || code == 'forbidden';
  bool get isServerError => statusCode == 500 || code == 'server_error';
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiError($statusCode): $message';
}
