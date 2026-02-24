import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/auth_repository_impl.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/presentation/sign_in/sign_in_controller.dart';
import 'package:get/get.dart';

class SignInBindings implements Bindings {
  @override
  void dependencies() {
    // 1. Data Source (ClientService registered globally as ApiClient)
    Get.lazyPut(() => AuthRemoteDataSource());

    // 2. Repository (Inject Data Source)
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));

    // 3. Controller (Inject Repository)
    Get.lazyPut(() => SignInController(Get.find()));
  }
}
