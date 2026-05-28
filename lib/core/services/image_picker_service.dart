import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';

/// Image picker — gallery, camera, multi-pick, and `ui.Image` → base64.
///
/// Validate MIME, size, and extension at the call site before uploading
/// (see [.claude/rules/security.md]). The picker returns `null` on
/// cancellation or failure; callers should treat null as "no file" and
/// surface their own message — failures are logged inside the helper.
///
/// Usage:
/// ```dart
/// // Pick from a known source
/// final file = await ImagePickerService.pick(ImageSource.gallery);
///
/// // Show a bottom sheet that lets the user choose
/// final file = await ImagePickerService.pickFromSheet();
///
/// // Multi-pick
/// final files = await ImagePickerService.pickMultiple();
/// ```
///
/// Stateless static helper — not a GetX-injected service; it lives under
/// `services/` because it wraps a platform capability (the image picker),
/// not because it holds session state.
abstract class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from [source] (gallery or camera).
  ///
  /// Returns the selected [XFile], or `null` if the user cancelled or the
  /// picker threw.
  static Future<XFile?> pick(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Pick multiple images from the gallery. Returns an empty list when
  /// the user cancelled or the picker threw.
  static Future<List<XFile>> pickMultiple() async {
    try {
      return await _picker.pickMultiImage();
    } catch (_) {
      return <XFile>[];
    }
  }

  /// Pick multiple images and return them as base64 `data:image/png;base64`
  /// strings. Convenience for backends that accept inline images.
  static Future<List<String>> pickMultipleAsBase64() async {
    final files = await pickMultiple();
    // Read each file async to avoid blocking the UI isolate. A multi-MB
    // image read via readAsBytesSync stalls the main thread until done.
    final encoded = <String>[];
    for (final f in files) {
      final bytes = await File(f.path).readAsBytes();
      encoded.add('data:image/png;base64,${base64Encode(bytes)}');
    }
    return encoded;
  }

  /// Show [ImageSourceSheet] and return the picked file.
  static Future<XFile?> pickFromSheet() => ImageSourceSheet.show();

  /// Encode a Flutter [ui.Image] as a base64 PNG string. Returns `null`
  /// when the image has no byte data.
  static Future<String?> toBase64(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return base64Encode(byteData.buffer.asUint8List());
  }
}

/// Bottom sheet that lets the user pick **Gallery** or **Camera** before
/// the actual picker fires. Returns the chosen [XFile] or `null`.
///
/// Usage:
/// ```dart
/// final file = await ImageSourceSheet.show();
/// if (file != null) controller.upload(File(file.path));
/// ```
class ImageSourceSheet extends StatelessWidget {
  /// Creates the sheet. Prefer the static [show] helper.
  const ImageSourceSheet({super.key});

  /// Shows the sheet and resolves with the chosen file, or `null` if the
  /// user dismissed it.
  static Future<XFile?> show() => Get.bottomSheet(const ImageSourceSheet());

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: BottomSheet(
        backgroundColor: AppColors.containerFillColor,
        enableDrag: false,
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(defaultRadius * 2),
            topLeft: Radius.circular(defaultRadius * 2),
          ),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Header(title: 'Select Option'),
              _OptionTile(
                icon: Icons.image_rounded,
                title: 'Gallery',
                onTap: () async {
                  final file = await ImagePickerService.pick(ImageSource.gallery);
                  Get.back<XFile?>(result: file);
                },
              ),
              _OptionTile(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                onTap: () async {
                  final file = await ImagePickerService.pick(ImageSource.camera);
                  Get.back<XFile?>(result: file);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: AppText(title, textSize: TextSize.large_16, textWeight: TextWeight.w600),
          trailing: InkWell(
            onTap: () => Get.back<void>(),
            child: const Icon(Icons.close, color: AppColors.primaryColor, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 0, color: AppColors.lightGreyTextColor),
        const SizedBox(height: 2),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24, color: AppColors.primaryTextColor),
      title: AppText(title, textSize: TextSize.medium_14, textWeight: TextWeight.w500),
      onTap: onTap,
    );
  }
}
