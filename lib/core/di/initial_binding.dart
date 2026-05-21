import 'package:get/get.dart';

import 'package:app_structure/core/controllers/auth_controller.dart';
import 'package:app_structure/core/network/api_client.dart';
import 'package:app_structure/core/services/device_info_service.dart';
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

    // Device + Network (lazy + fenix — re-registered after Get.deleteAll)
    Get.lazyPut(
      () => DeviceInfoService(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ApiClient(Get.find<SecureStorageService>()),
      fenix: true,
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
