import 'package:app_structure/core/config/api_urls.dart';
import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/constants/app_constants.dart';
import 'package:app_structure/core/network/base_response.dart';
import 'package:app_structure/core/network/auth_interceptor.dart';
import 'package:app_structure/core/network/token_refresh_interceptor.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:app_structure/shared/models/api_error_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Long-lived HTTP client. One `Dio` per app lifetime, interceptors attached
/// once. DataSources call `get/post/put/patch/delete/uploadFile` and receive
/// `BaseResponse<T>` — they throw on `!response.success`.
///
/// Registered as a lazy/fenix service in `InitialBinding`.
class ApiClient {
  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage),
      TokenRefreshInterceptor(_dio, _secureStorage),
      if (kDebugMode && AppEnvironment.enableLogging)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 120,
        ),
    ]);
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;

  Dio get dio => _dio;

  String _versionedPath(String path, String? version) => '/${version ?? ApiUrls.apiV1}$path';

  Future<BaseResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  }) => _request(
    () => _dio.get(
      _versionedPath(path, version),
      queryParameters: queryParameters,
      options: options,
    ),
    fromJson: fromJson,
  );

  Future<BaseResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  }) => _request(
    () => _dio.post(
      _versionedPath(path, version),
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    fromJson: fromJson,
  );

  Future<BaseResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  }) => _request(
    () => _dio.put(
      _versionedPath(path, version),
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    fromJson: fromJson,
  );

  Future<BaseResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  }) => _request(
    () => _dio.patch(
      _versionedPath(path, version),
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    fromJson: fromJson,
  );

  Future<BaseResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  }) => _request(
    () => _dio.delete(
      _versionedPath(path, version),
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    fromJson: fromJson,
  );

  /// Multipart upload. Defaults to POST; pass `method: 'PUT'`/`'PATCH'` for
  /// endpoints that take multipart over a different verb.
  Future<BaseResponse<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onSendProgress,
    String? version,
    String method = 'POST',
  }) {
    final fullPath = _versionedPath(path, version);
    final options = Options(contentType: 'multipart/form-data');
    final upper = method.toUpperCase();

    return _request(
      () {
        switch (upper) {
          case 'PUT':
            return _dio.put(
              fullPath,
              data: formData,
              options: options,
              onSendProgress: onSendProgress,
            );
          case 'PATCH':
            return _dio.patch(
              fullPath,
              data: formData,
              options: options,
              onSendProgress: onSendProgress,
            );
          case 'POST':
          default:
            return _dio.post(
              fullPath,
              data: formData,
              options: options,
              onSendProgress: onSendProgress,
            );
        }
      },
      fromJson: fromJson,
    );
  }

  Future<BaseResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() request, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      if (fromJson != null && data is Map<String, dynamic>) {
        final parsed = data['data'] != null ? fromJson(data['data']) : fromJson(data);
        return BaseResponse.fromSuccess(
          parsed,
          message: data['message'] as String?,
        );
      }

      return BaseResponse<T>(
        success: true,
        data: data is T ? data : null,
        message: data is Map<String, dynamic> ? data['message'] as String? : null,
      );
    } on DioException catch (e) {
      return BaseResponse.fromError(ApiErrorModel.fromDioException(e));
    } catch (e) {
      return BaseResponse.fromError(
        ApiErrorModel(message: e.toString()),
      );
    }
  }
}
