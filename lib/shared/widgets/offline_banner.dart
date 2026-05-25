import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/controllers/connectivity_controller.dart';
import 'package:app_structure/core/i18n/i18n_keys.dart';
import 'package:app_structure/core/theme/app_dimensions.dart';
import 'package:app_structure/core/theme/app_text.dart';

/// Slim banner shown when the device goes offline. Wrap protected
/// screens like:
///
/// ```dart
/// Column(children: [const OfflineBanner(), Expanded(child: ...)])
/// ```
///
/// Or use `_buildOfflineAware(child)` as a helper. The banner reads
/// `ConnectivityController.isOnline` reactively — no widget rebuilds
/// happen while the device stays online.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityController>();
    return Obx(() {
      if (connectivity.isOnline.value) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        color: AppColors.warningBg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing8,
        ),
        child: AppText(
          I18n.offline.tr,
          textSize: TextSize.small_12,
          textColor: AppColors.warningDark,
          textAlign: TextAlign.center,
        ),
      );
    });
  }
}
