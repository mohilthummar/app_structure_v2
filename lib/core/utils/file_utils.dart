import 'dart:math';

/// File-name / extension / size helpers. No filesystem I/O — pure string
/// utilities that operate on file names + byte counts you already have.
abstract class FileUtils {
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg',
  ];

  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
  ];

  static const List<String> defaultAllowed = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  static bool isValidFileType(String fileName, [List<String>? allowedExtensions]) {
    final ext = getExtension(fileName).toLowerCase();
    final allowed = allowedExtensions ?? defaultAllowed;
    return allowed.contains(ext);
  }

  static bool isValidFileSize(int bytes, {int maxMB = 10}) => bytes <= maxMB * 1024 * 1024;

  static String getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }

  static bool isImage(String fileName) => imageExtensions.contains(getExtension(fileName).toLowerCase());

  static bool isDocument(String fileName) => documentExtensions.contains(getExtension(fileName).toLowerCase());
}
