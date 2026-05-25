import 'package:app_structure/features/home/data/dashboard_item_model.dart';
import 'package:app_structure/features/home/data/home_remote_datasource.dart';
import 'package:app_structure/features/home/domain/home_repository.dart';

/// Concrete `HomeRepository`. Pure passthrough today — extend with
/// caching / offline storage as the feature grows. The wrapper exists
/// so controllers always depend on the domain interface.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._ds);

  final HomeRemoteDataSource _ds;

  @override
  Future<DashboardPage> getDashboard({int page = 1, int limit = 10}) async {
    try {
      return await _ds.getDashboard(page: page, limit: limit);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
