import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// File picker + lightweight filesystem helpers.
///
/// Validate type and size at the call site before uploading — this helper
/// returns the raw [PlatformFile]; it doesn't enforce any policy. The
/// `is*` predicates and [formatFileSize] are here so every feature uses
/// the same allow-lists.
///
/// Usage:
/// ```dart
/// final file = await FilePickerService.pick();
/// if (file == null) return; // user cancelled
/// if (!FilePickerService.isValidSize(file.size)) {
///   AppSnackBar.error(message: 'File too large');
///   return;
/// }
/// final downloadDir = await FilePickerService.getDownloadPath();
/// ```
///
/// Stateless static helper — not a GetX-injected service; it lives under
/// `services/` because it wraps a platform capability (the file picker +
/// download dirs), not because it holds session state.
abstract class FilePickerService {
  // ── Allow-lists ──────────────────────────────────────────────────────────
  /// Image extensions accepted across the app.
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg',
  ];

  /// Document extensions accepted across the app.
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
  ];

  /// Default allow-list used when callers don't pass a custom one.
  static const List<String> defaultAllowed = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  // ── Pickers ──────────────────────────────────────────────────────────────
  /// Pick a single file. Defaults to PDF; pass [allowedExtensions] for a
  /// different filter (e.g. `['png', 'jpg']`).
  ///
  /// Returns `null` if the user cancelled or the picker threw.
  static Future<PlatformFile?> pick({
    List<String> allowedExtensions = const ['pdf'],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );
      return result?.files.first;
    } catch (_) {
      return null;
    }
  }

  /// Pick multiple files. Returns an empty list on cancel / error.
  static Future<List<PlatformFile>> pickMultiple({
    List<String> allowedExtensions = const ['pdf'],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );
      return result?.files ?? <PlatformFile>[];
    } catch (_) {
      return <PlatformFile>[];
    }
  }

  // ── Filesystem ───────────────────────────────────────────────────────────
  /// Platform-appropriate download folder.
  ///
  /// Android → public Downloads dir; iOS → app documents dir (since iOS
  /// doesn't expose a system Downloads folder).
  static Future<String> getDownloadPath() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getDownloadsDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }
    if (dir == null) {
      throw Exception('Failed to resolve download folder path.');
    }
    return dir.path;
  }

  // ── Validation helpers ───────────────────────────────────────────────────
  /// Returns the file extension (without leading `.`), lowercased.
  static String getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// `true` when [fileName]'s extension is in [allowedExtensions]
  /// (defaults to [defaultAllowed]).
  static bool isValidType(String fileName, [List<String>? allowedExtensions]) {
    final ext = getExtension(fileName);
    return (allowedExtensions ?? defaultAllowed).contains(ext);
  }

  /// `true` when [bytes] ≤ [maxMB] megabytes. Default cap is 10MB.
  static bool isValidSize(int bytes, {int maxMB = 10}) => bytes <= maxMB * 1024 * 1024;

  /// `true` when [fileName] has an image extension.
  static bool isImage(String fileName) => imageExtensions.contains(getExtension(fileName));

  /// `true` when [fileName] has a document extension.
  static bool isDocument(String fileName) => documentExtensions.contains(getExtension(fileName));

  /// Human-readable size: `12 B`, `4 KB`, `1.5 MB`, `3 GB`.
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }
}
