import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:app_structure/core/network/api_client.dart';
import 'package:app_structure/core/network/auth_interceptor.dart';
import 'package:app_structure/core/services/permission_service.dart';
import 'package:app_structure/core/utils/app_logger.dart';

/// Where to save a downloaded file.
enum DownloadDestination {
  /// App-private documents directory. **No permission required.**
  ///
  /// * Android: `/data/data/<package>/app_flutter/` — NOT visible in the
  ///   system Files app. Use this for files the app reads itself
  ///   (cached PDFs, generated reports).
  /// * iOS: app sandbox `Documents/` — visible in the Files app **only**
  ///   if you set `UIFileSharingEnabled = YES` AND
  ///   `LSSupportsOpeningDocumentsInPlace = YES` in `Info.plist`.
  appDocuments,

  /// Public Downloads folder (Android only — visible in Files app /
  /// gallery). Requests `Permission.storage` first; on Android 10+ this
  /// is automatically granted because the public Downloads folder is
  /// part of scoped storage. On iOS, falls back to [appDocuments]
  /// because the sandbox prevents writing outside the app.
  downloads,
}

/// Result of a download attempt. `success: true` ⇒ `path` is non-null.
class DownloadOutcome {
  const DownloadOutcome._({required this.success, this.path, this.error});

  factory DownloadOutcome.success(String path) => DownloadOutcome._(success: true, path: path);

  factory DownloadOutcome.failure(String error) => DownloadOutcome._(success: false, error: error);

  final bool success;
  final String? path;
  final String? error;
}

/// Downloads remote files to platform-appropriate storage.
///
/// Built on `ApiClient.dio.download` so the existing interceptor stack
/// (auth, token refresh, logging) participates. For public CDN URLs,
/// pass `sendAuthHeader: false` and the Bearer token is suppressed for
/// that request via `AuthInterceptor.skipAuthKey`.
///
/// Security (per `.claude/rules/security.md`):
///
/// * URL scheme is whitelisted to `http` / `https`. `file://`, `javascript:`,
///   custom schemes are rejected.
/// * Filename is sanitized — path separators and parent-dir refs (`..`) are
///   stripped, so callers can pass server-supplied names without risking
///   directory traversal.
/// * Resolved save path is verified to live inside the resolved
///   destination directory (defense in depth).
///
/// Registered lazy + fenix in `InitialBinding`.
///
/// Usage:
/// ```dart
/// final downloader = Get.find<FileDownloadService>();
///
/// // Authenticated API download (default)
/// final result = await downloader.download(
///   url: '${AppEnvironment.baseUrl}/files/invoice_42.pdf',
///   fileName: 'invoice_42.pdf',
///   destination: DownloadDestination.downloads,
///   onProgress: (received, total) {
///     final pct = total > 0 ? received / total : 0.0;
///     debugPrint('Progress: ${(pct * 100).toStringAsFixed(0)}%');
///   },
/// );
///
/// if (result.success) {
///   AppSnackBar.success(message: 'Saved to ${result.path}');
/// } else {
///   AppSnackBar.error(message: result.error ?? 'Download failed');
/// }
///
/// // Public CDN download (no auth header)
/// await downloader.download(
///   url: 'https://cdn.example.com/logo.png',
///   fileName: 'logo.png',
///   sendAuthHeader: false,
/// );
/// ```
///
/// To open the file after download, add `open_filex` (or similar) to
/// `pubspec.yaml` and call `OpenFilex.open(result.path!)` — kept out of
/// this service so the skeleton doesn't add another dependency.
class FileDownloadService {
  FileDownloadService({
    required ApiClient api,
    required PermissionService permissions,
  }) : _api = api,
       _permissions = permissions;

  final ApiClient _api;
  final PermissionService _permissions;

  Future<DownloadOutcome> download({
    required String url,
    required String fileName,
    DownloadDestination destination = DownloadDestination.appDocuments,
    bool sendAuthHeader = true,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
    bool overwrite = true,
  }) async {
    // 1. Validate URL scheme.
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return DownloadOutcome.failure('URL must use http or https');
    }

    // 2. Sanitize filename — strip directory parts + parent traversal.
    final safeName = _sanitizeFileName(fileName);
    if (safeName.isEmpty) {
      return DownloadOutcome.failure('Invalid file name');
    }

    // 3. Resolve destination directory.
    final dir = await _resolveDirectory(destination);
    if (dir == null) {
      return DownloadOutcome.failure('Could not resolve save directory');
    }

    // 4. Compose full path + defense-in-depth: confirm we're staying
    //    inside `dir` (no symlink shenanigans / path-traversal escape).
    final fullPath = p.normalize(p.join(dir.path, safeName));
    if (!p.isWithin(dir.path, fullPath) && p.dirname(fullPath) != dir.path) {
      return DownloadOutcome.failure('Resolved path escapes save directory');
    }

    // 5. Honor overwrite flag.
    final outFile = File(fullPath);
    if (!overwrite && await outFile.exists()) {
      return DownloadOutcome.success(fullPath);
    }

    // 6. Stream download.
    try {
      await _api.dio.download(
        url,
        fullPath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          extra: sendAuthHeader ? null : const {AuthInterceptor.skipAuthKey: true},
        ),
      );
      AppLogger.success('Downloaded to $fullPath', tag: 'FileDownloadService');
      return DownloadOutcome.success(fullPath);
    } on DioException catch (e, st) {
      // Best-effort cleanup of partial files.
      if (await outFile.exists()) {
        try {
          await outFile.delete();
        } catch (_) {}
      }
      if (CancelToken.isCancel(e)) {
        AppLogger.warning('Download cancelled: $url', tag: 'FileDownloadService');
        return DownloadOutcome.failure('Download cancelled');
      }
      AppLogger.error(
        e.message ?? e.toString(),
        tag: 'FileDownloadService.download',
        error: e,
        stackTrace: st,
      );
      return DownloadOutcome.failure(_userSafeError(e));
    } catch (e, st) {
      if (await outFile.exists()) {
        try {
          await outFile.delete();
        } catch (_) {}
      }
      AppLogger.error(
        e.toString(),
        tag: 'FileDownloadService.download',
        error: e,
        stackTrace: st,
      );
      return DownloadOutcome.failure('Download failed');
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  Future<Directory?> _resolveDirectory(DownloadDestination dest) async {
    if (dest == DownloadDestination.downloads && Platform.isAndroid) {
      final granted = await _ensureAndroidStoragePermission();
      if (!granted) {
        AppLogger.warning(
          'Storage permission denied — falling back to app documents.',
          tag: 'FileDownloadService',
        );
      } else {
        // path_provider's getDownloadsDirectory returns
        // /storage/emulated/0/Download on most Android devices.
        try {
          final downloads = await getDownloadsDirectory();
          if (downloads != null) {
            if (!await downloads.exists()) {
              await downloads.create(recursive: true);
            }
            return downloads;
          }
        } catch (e) {
          AppLogger.warning(
            'Could not access public Downloads — falling back: $e',
            tag: 'FileDownloadService',
          );
        }
      }
      // Fall through to appDocuments.
    }

    // iOS / fallback: app sandbox.
    final docs = await getApplicationDocumentsDirectory();
    if (!await docs.exists()) {
      await docs.create(recursive: true);
    }
    return docs;
  }

  Future<bool> _ensureAndroidStoragePermission() async {
    final outcome = await _permissions.storage();
    return outcome == PermissionOutcome.granted;
  }

  /// Strip path separators + parent-dir refs from a server-supplied name.
  /// Preserves dots in the extension (`report.pdf` stays `report.pdf`).
  String _sanitizeFileName(String name) {
    // Take only the basename — drops anything before the last slash.
    var base = p.basename(name);
    // Replace any remaining backslashes (Windows-style) just in case.
    base = base.replaceAll(r'\', '_');
    // Collapse parent-traversal refs that survive basename (rare but safe).
    base = base.replaceAll('..', '_');
    return base.trim();
  }

  String _userSafeError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Download timed out';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return code != null ? 'Server returned $code' : 'Server error';
      case DioExceptionType.cancel:
        return 'Download cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badCertificate:
        return 'Certificate error';
      case DioExceptionType.unknown:
        return 'Download failed';
    }
  }
}
