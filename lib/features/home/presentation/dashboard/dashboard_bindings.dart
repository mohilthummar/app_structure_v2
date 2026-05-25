import 'package:get/get.dart';

import 'package:app_structure/features/home/data/home_remote_datasource.dart';
import 'package:app_structure/features/home/data/home_repository_impl.dart';
import 'package:app_structure/features/home/domain/home_repository.dart';
import 'package:app_structure/features/home/presentation/dashboard/dashboard_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeRemoteDataSource(Get.find()));
    Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl(Get.find()));
    Get.lazyPut(() => DashboardController(Get.find<HomeRepository>()));
  }
}
