import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseViewController extends GetxController with WidgetsBindingObserver {
  // late PackageInfo packageInfo;

  @override
  void onInit() {
    super.onInit();

    // Register this controller to listen to lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // deleteCacheDir();
    // UiUtils.keyboardStatusListen();
  }

  // @override
  // void onReady() async {
  //   super.onReady();
  // await getPackageInfo().then((returnPkgInfo) {
  //   packageInfo = returnPkgInfo;
  //   AppStrings.appName.value = returnPkgInfo.appName;
  // });
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // printOkStatus('App Resumed');
        break;

      case AppLifecycleState.inactive:
        // printYellow('App Inactive');
        break;

      case AppLifecycleState.paused:
        // printWhite('App Paused');
        break;

      case AppLifecycleState.detached:
        // printCancel('App Detached');
        break;

      case AppLifecycleState.hidden:
        // printWarning('App hidden');
        break;
    }
  }

  @override
  void onClose() {
    // Unregister the observer when controller is closed
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
