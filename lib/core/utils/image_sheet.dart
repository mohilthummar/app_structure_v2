import 'dart:ui';

import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_structure/core/utils/ui_utils.dart';

/// A bottom sheet for picking an image from gallery or camera.
/// Returns an [XFile] or null.
class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  /// Shows the image source sheet and returns the selected [XFile] or null.
  static Future<XFile?> showSheet() async {
    return await Get.bottomSheet(const ImageSourceSheet());
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: BottomSheet(
        backgroundColor: AppColors.containerFillColor,
        enableDrag: false,
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius * 2), topLeft: Radius.circular(defaultRadius * 2)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogHeader(context, title: 'Select Option'),
                _buildListTile(
                  icon: Icons.image_rounded,
                  title: 'Gallery',
                  onTap: () async {
                    final XFile? file = await UiUtils.pickImage(ImageSource.gallery);
                    Get.back(result: file);
                  },
                ),
                _buildListTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  onTap: () async {
                    final XFile? file = await UiUtils.pickImage(ImageSource.camera);
                    Get.back(result: file);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a list tile for the image source option.
  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 24, color: AppColors.primaryTextColor),
      title: AppText(title, textSize: TextSize.medium_14, textWeight: TextWeight.w500),
      onTap: onTap,
    );
  }

  /// Builds the dialog header with a close button.
  Widget _dialogHeader(BuildContext context, {required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: AppText(title, textSize: TextSize.large_16, textWeight: TextWeight.w600),
          trailing: InkWell(
            onTap: () => Get.back(),
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
