import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/auth_repository_impl.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/presentation/sign_up/sign_up_controller.dart';
import 'package:get/get.dart';

class SignUpBindings implements Bindings {
  @override
  void dependencies() {
    // 1. Data Source (ClientService registered globally as ApiClient)
    Get.lazyPut(() => AuthRemoteDataSource());

    // 2. Repository (Inject Data Source)
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));

    // 3. Controller (Inject Repository)
    Get.lazyPut(() => SignUpController(Get.find()));
  }
}
