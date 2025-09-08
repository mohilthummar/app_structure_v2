// import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

class DeepLinkManager extends GetxController {
  // final AppLinks _appLinks = AppLinks(); // Singleton instance of AppLinks
  // RxString deepLink = ''.obs; // Observable string to store deep link

  // @override
  // void onInit() {
  //   super.onInit();
  //   _listenForDeepLinks();
  // }

  // // Listen for deep links (both app launch and background/foreground)
  // void _listenForDeepLinks() {
  //   // Listen for the deep links when the app is already opened
  //   _appLinks.uriLinkStream.listen((uri) {
  //     deepLink.value = uri.toString();
  //     _handleDeepLink(uri);
  //   });

  //   // Listen for deep links when the app is launched from a cold state (app is not running)
  //   _appLinks.getInitialLink().then((uri) {
  //     if (uri != null) {
  //       deepLink.value = uri.toString();
  //       _handleDeepLink(uri);
  //     }
  //   });
  // }

  // bool isAppEnvMatchingTheDomain(Uri uri) {
  //   bool isMatchingDomain = false;

  //   if (AppEnvironment.environmentType == EnvironmentType.production) {
  //     isMatchingDomain = uri.host == AppStrings.gmsWebProductionDomain;
  //   } else if (AppEnvironment.environmentType == EnvironmentType.staging) {
  //     isMatchingDomain = uri.host == AppStrings.gmsWebStagingDomain;
  //   }

  //   return isMatchingDomain;
  // }

  // // Handle the deep link (based on path, query parameters, etc.)
  // void _handleDeepLink(Uri uri) {
  //   if (isAppEnvMatchingTheDomain(uri)) {
  //     printOkStatus("Deep Link Opened: $uri");
  //     printOkStatus("Path: ${uri.path}");

  //     // Map that holds the path and its corresponding handler
  //     final Map<String, Function(Uri)> linkHandlers = {AppStrings.registerRouteSlug: registerDeepLinkActivity, AppStrings.appointmentDetailsRouteSlug: appointmentDetailsDeepLinkActivity};

  //     for (var entry in linkHandlers.entries) {
  //       if (uri.path.startsWith(entry.key)) {
  //         // Call the corresponding handler function
  //         entry.value(uri);
  //         return;
  //       } else {
  //         printYellow("Unhandled deep link: ${uri.toString()}");
  //       }
  //     }
  //   }
  // }

  // /// ***********************************************************************************
  // /// *                                 COMMON FUNCTIONS                                *
  // /// ***********************************************************************************

  // /// Register flow
  // Future<void> registerDeepLinkActivity(Uri uri) async {
  //   // if (isValEmpty(OnboardLocalStorage.accessToken)) {
  //   if (isRegistered<OnboardingViewModel>()) {
  //     OnboardingViewModel con = Get.find<OnboardingViewModel>();
  //     con.onboardingGetStartedButtonRedirection.value = OnboardingGetStartedButtonRedirection.register;
  //   }

  //   /* if (Get.currentRoute != AppRoutes.onBoardingView) {
  //       Get.toNamed(AppRoutes.onBoardingView, arguments: {
  //         "onboardingGetStartedButtonRedirection": OnboardingGetStartedButtonRedirection.register,
  //       });
  //     } else {

  //     }*/
  //   // }
  //   // navigateOnboard();
  // }

  // /// Appointment Details
  // Future<void> appointmentDetailsDeepLinkActivity(Uri uri) async {
  //   final segments = uri.path.split('/');
  //   if (segments.length > 1) {
  //     final String appointmentId = segments[1].toString();

  //     printOkStatus('Deep Link Data: $appointmentId');

  //     if (isValEmpty(LocalStorage.accessToken.value)) {
  //       // Navigation
  //       if (Get.currentRoute == AppRoutes.mobileAppointmentDetailsView) Get.back();
  //       Get.toNamed(AppRoutes.mobileAppointmentDetailsView, arguments: {"apptID": appointmentId});
  //     }
  //   } else {
  //     printYellow('Invalid deep link format');
  //   }
  // }

  // /// ***********************************************************************************
  // /// *                                    NAVIGATION                                   *
  // /// ***********************************************************************************

  // Future<void> navigateOnboard() async {
  //   baseCon.appFlowType.value = AppFlowType.onboard;

  //   String deeplinkId = 'adsafdsds';

  //   if ( /* deeplinkId == OnboardLocalStorage.deeplinkId && */ !isValEmpty(OnboardLocalStorage.accessToken.value)) {
  //     /// verify token API -> check how many step are complete, prefill the values and navigate to the remaining step.
  //     if (!isValEmpty(baseCon.userCompanyModel.value.id)) {
  //       await OnboardRepository.existingUserVerifyAndGetAPI(backgroundMode: true);
  //     }

  //     Get.toNamed(AppRoutes.companyOnboardingView, arguments: {'screenState': ScreenState.add, 'screenFlow': ScreenFlowType.onboardingFlow});
  //   } else {
  //     await OnboardLocalStorage.clearLocalStorage();

  //     OnboardLocalStorage.setDeeplinkId(linkId: deeplinkId);

  //     Get.toNamed(AppRoutes.companyLogoUploadView);
  //   }
  // }
}
