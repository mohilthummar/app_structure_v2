import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_structure/core/apis/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for file and image operations.
///
/// Usage:
/// ```dart
/// // Pick an image from gallery
/// final file = await FileUtils.pickImage(ImageSource.gallery);
///
/// // Pick multiple images
/// final images = await FileUtils.pickMultipleImage();
///
/// // Pick a PDF file
/// final result = await FileUtils.pickFile();
///
/// // Get download folder path
/// final path = await FileUtils.getDownloadFolderPath();
///
/// // Convert ui.Image to base64
/// final base64 = await FileUtils.imageToBase64(image);
/// ```

class FileUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      XFile? xFile = await _picker.pickImage(source: source, requestFullMetadata: false);
      if (xFile != null) {
        return xFile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> pickMultipleImage() async {
    try {
      List<XFile> xFile = await _picker.pickMultiImage();
      if (xFile.isNotEmpty) {
        List<String> images = xFile.map((e) {
          String base64String = base64Encode(File(e.path).readAsBytesSync());
          return 'data:image/png;base64,$base64String';
        }).toList();
        return images;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Result<PlatformFile, String>> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
      if (result != null) {
        return Success(result.files.first);
      }
      return Failure("Please select a file");
    } catch (e) {
      return Failure("Please select a file");
    }
  }

  static Future<String> getDownloadFolderPath() async {
    Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = await getDownloadsDirectory();
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    }
    if (downloadDir == null) {
      throw Exception('Failed to get download folder path.');
    }
    return downloadDir.path;
  }

  static Future<String?> imageToBase64(ui.Image image) async {
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    Uint8List pngBytes = byteData.buffer.asUint8List();
    String base64Image = base64Encode(pngBytes);
    return base64Image;
  }
}
