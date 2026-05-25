import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/controllers/connectivity_controller.dart';
import 'package:app_structure/core/network/api_client.dart';
import 'package:app_structure/core/services/analytics_service.dart';
import 'package:app_structure/core/services/app_info_service.dart';
import 'package:app_structure/core/services/crashlytics_service.dart';
import 'package:app_structure/core/services/deep_linking_manager.dart';
import 'package:app_structure/core/services/device_info_service.dart';
import 'package:app_structure/core/services/file_download_service.dart';
import 'package:app_structure/core/services/notification_services.dart';
import 'package:app_structure/core/services/permission_service.dart';
import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/auth_repository_impl.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

/// Wires every permanent + lazy/fenix dependency for the app. Called from
/// `main.dart` BEFORE `runApp`, after `bootstrap()` has loaded `.env` and
/// initialised Firebase.
///
/// Order matters — each line below depends on something registered above.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage (permanent — survive logout teardown)
    Get.put(SecureStorageService(), permanent: true);
    Get.put(LocalStorageService(), permanent: true);

    // Telemetry (permanent — must outlive logout so post-logout errors
    // still reach Crashlytics; init() called from bootstrap after this
    // method returns).
    Get.put(CrashlyticsService(), permanent: true);
    Get.put(AnalyticsService(), permanent: true);

    // App metadata (lazy + fenix — cheap; call .load() before reading)
    Get.lazyPut(() => AppInfoService(), fenix: true);

    // Permission wrapper (lazy + fenix — stateless)
    Get.lazyPut(() => PermissionService(), fenix: true);

    // Connectivity (permanent — subscription must outlive logout)
    Get.put(ConnectivityController(), permanent: true);

    // Deep links (permanent — stream subscription outlives logout)
    // To wire up: pass `allowedPaths: { '/dashboard', '/profile' }`
    // when extending this skeleton, then `Get.find<DeepLinkService>()
    // .init()` from your top-level coordinator.
    Get.put(DeepLinkService(), permanent: true);

    // Device + Network (lazy + fenix — re-registered after Get.deleteAll)
    Get.lazyPut(
      () => DeviceInfoService(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ApiClient(Get.find<SecureStorageService>()),
      fenix: true,
    );

    // File downloader (lazy + fenix — pulls dio via ApiClient + perm service)
    Get.lazyPut(
      () => FileDownloadService(
        api: Get.find<ApiClient>(),
        permissions: Get.find<PermissionService>(),
      ),
      fenix: true,
    );

    // Notification service (permanent — FCM token survives logout).
    // Call `.init()` from the splash controller after first paint so
    // the token is fetched before the first authenticated request.
    Get.put(
      NotificationService(
        storage: Get.find<LocalStorageService>(),
        permissions: Get.find<PermissionService>(),
        deviceInfo: Get.find<DeviceInfoService>(),
        // Whitelist allowed notification types — extend per project.
        allowedTypes: const {},
      ),
      permanent: true,
    );

    // Auth datasource + repo (lazy + fenix)
    Get.lazyPut(
      () => AuthRemoteDataSource(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<AuthRemoteDataSource>(),
        Get.find<SecureStorageService>(),
        Get.find<LocalStorageService>(),
      ),
      fenix: true,
    );

    // Auth controller (permanent — single source of truth for session)
    Get.put(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
  }
}
