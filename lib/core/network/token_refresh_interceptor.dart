import 'dart:async';

import 'package:app_structure/core/config/api_urls.dart';
import 'package:app_structure/core/config/app_environment.dart';
import 'package:app_structure/core/constants/app_constants.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:app_structure/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Mirrors the gms-management web project's axios refresh logic:
///
/// * On any 401 (except on the refresh endpoint itself) we attempt one refresh.
/// * Concurrent 401s during a refresh in flight are queued — refresh fires
///   exactly once, then every queued request is retried with the new token.
/// * Tokens are never wiped automatically. If the refresh itself fails
///   (any reason — 401, 500, network, parse), every queued request is
///   rejected with the original error and the caller decides what to do.
///   Logout happens explicitly through `AuthController.logout()`, not as a
///   side-effect of a single failing API call.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorageService _secureStorage;

  // Instance fields, not static: when ApiClient is recreated via Get.fenix
  // (e.g. after logout), a fresh interceptor must start with clean state.
  // Static fields would leak the previous Dio's queue into the new instance.
  bool _isRefreshing = false;
  final List<_PendingRequest> _failedQueue = <_PendingRequest>[];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (statusCode != 401) return handler.next(err);

    final originalOptions = err.requestOptions;
    final path = originalOptions.path;

    _log('401 on $path — starting refresh flow');

    if (path.contains(ApiUrls.refreshToken)) {
      _log('401 is from refresh endpoint itself — propagating.');
      return handler.next(err);
    }

    if (_isRefreshing) {
      _log('refresh already in flight — queueing $path');
      try {
        final newToken = await _enqueue();
        final retried = await _retry(originalOptions, newToken);
        _log('queued retry OK for $path');
        return handler.resolve(retried);
      } catch (e) {
        _log('queued retry failed for $path: $e');
        return handler.next(err);
      }
    }

    _isRefreshing = true;
    try {
      final newAccessToken = await _refreshAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        _log('refresh returned no access token — propagating 401.');
        _drainQueue(error: err);
        return handler.next(err);
      }

      await _secureStorage.saveToken(newAccessToken);
      _log('refresh succeeded — new access token saved.');
      _drainQueue(token: newAccessToken);

      final retried = await _retry(originalOptions, newAccessToken);
      _log('retry OK for $path');
      return handler.resolve(retried);
    } catch (refreshError) {
      _log('refresh threw: $refreshError — propagating original 401.');
      _drainQueue(error: err);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _log(String msg) {
    AppLogger.debug(msg, tag: 'TokenRefresh');
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _log('no refresh token in secure storage — cannot refresh.');
      return null;
    }

    _log('calling refresh endpoint ${ApiUrls.refreshToken}');

    final cleanDio = Dio(
      BaseOptions(
        baseUrl: '${AppEnvironment.baseUrl}/${ApiUrls.apiV1}',
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: 'application/json',
      ),
    );
    if (kDebugMode && AppEnvironment.enableLogging) {
      cleanDio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 120,
        ),
      );
    }

    final headers = <String, dynamic>{
      'Cookie': 'refreshToken=${Uri.encodeComponent(refreshToken)}',
    };
    final webOrigin = AppEnvironment.webOrigin;
    if (webOrigin.isNotEmpty) {
      headers['Origin'] = webOrigin;
      headers['Referer'] = webOrigin;
    }

    final response = await cleanDio.post(
      ApiUrls.refreshToken,
      data: {'refreshToken': refreshToken},
      options: Options(headers: headers),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) return null;

    final wrapper = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
    final tokens = (wrapper['tokens'] is Map<String, dynamic> ? wrapper['tokens'] : wrapper['token']) as Map<String, dynamic>?;
    final access = tokens?['access'] is Map<String, dynamic> ? tokens!['access'] as Map<String, dynamic> : null;
    final newAccessToken = access?['token'] as String? ?? wrapper['accessToken'] as String?;

    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      for (final cookie in cookies) {
        final match = RegExp(r'refreshToken=([^;]+)').firstMatch(cookie);
        if (match != null) {
          await _secureStorage.saveRefreshToken(
            Uri.decodeComponent(match.group(1)!),
          );
          break;
        }
      }
    }

    return newAccessToken;
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    final retryOptions = options.copyWith(
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return _dio.fetch(retryOptions);
  }

  Future<String> _enqueue() {
    final pending = _PendingRequest();
    _failedQueue.add(pending);
    return pending.completer.future;
  }

  void _drainQueue({String? token, DioException? error}) {
    final snapshot = List<_PendingRequest>.from(_failedQueue);
    _failedQueue.clear();
    for (final req in snapshot) {
      if (token != null) {
        req.completer.complete(token);
      } else {
        req.completer.completeError(
          error ??
              DioException(
                requestOptions: RequestOptions(path: ''),
                error: 'Token refresh failed',
              ),
        );
      }
    }
  }
}

class _PendingRequest {
  final Completer<String> completer = Completer<String>();
}
