import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverlayController extends GetxController {
  OverlayEntry? overlayEntry;
  Rx<Offset> buttonPosition = const Offset(34, 560.0).obs; // Initial position for the button

  @override
  void onReady() {
    super.onReady();
    showGlobalButton();
  }

  void showGlobalButton() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (overlayEntry == null && Get.overlayContext != null) {
        overlayEntry = OverlayEntry(
          builder: (context) => Obx(
            () => Positioned(
              left: buttonPosition.value.dx,
              top: buttonPosition.value.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // Update the position based on drag
                  buttonPosition.value += details.delta;
                },
                onTap: () {
                  // Get.snackbar('Button Pressed', 'Global button pressed');S
                  AppPrint.success(buttonPosition.value);
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: const Text('-', textAlign: TextAlign.start),
                  ),
                ),
              ),
            ),
          ),
        );
        Overlay.of(Get.overlayContext!).insert(overlayEntry!); // Insert using Get.overlayContext
      }
    });
  }

  void removeGlobalButton() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  @override
  void onClose() {
    removeGlobalButton();
    super.onClose();
  }
}
