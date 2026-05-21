import 'package:app_structure/shared/models/api_error_model.dart';

/// Transport-layer envelope. Stays inside the data layer — DataSources
/// inspect `success` + `data` and throw on `!success`. Controllers/views
/// never see this type.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  final bool success;
  final T? data;
  final String? message;
  final ApiErrorModel? error;

  factory ApiResponse.fromSuccess(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.fromError(ApiErrorModel error) {
    return ApiResponse(success: false, error: error);
  }
}
