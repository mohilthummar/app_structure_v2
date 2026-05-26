import 'package:app_structure/shared/models/api_error_model.dart';

/// Transport-layer envelope returned by every [`ApiClient`] call.
///
/// Stays inside the data layer — DataSources inspect `success` + `data`
/// and throw `Exception` on `!success`. Controllers and views never see
/// this type.
///
/// Usage:
/// ```dart
/// final res = await _client.get<UserModel>(
///   ApiUrls.userProfile,
///   fromJson: (json) => UserModel.fromJson(json),
/// );
/// if (!res.success || res.data == null) {
///   throw Exception(res.error?.message ?? 'Failed to load profile');
/// }
/// return res.data!;
/// ```
class BaseResponse<T> {
  const BaseResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  final bool success;
  final T? data;
  final String? message;
  final ApiErrorModel? error;

  factory BaseResponse.fromSuccess(T data, {String? message}) {
    return BaseResponse(success: true, data: data, message: message);
  }

  factory BaseResponse.fromError(ApiErrorModel error) {
    return BaseResponse(success: false, error: error);
  }
}
