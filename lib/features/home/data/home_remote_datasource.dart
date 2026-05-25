import 'package:app_structure/core/config/api_urls.dart';
import 'package:app_structure/core/network/api_client.dart';
import 'package:app_structure/features/home/data/dashboard_item_model.dart';

/// Thin wrapper over `ApiClient` for the home/dashboard endpoints.
/// Throws `Exception` on non-success responses — the repository's
/// try/catch surfaces these to the controller layer.
class HomeRemoteDataSource {
  HomeRemoteDataSource(this._api);

  final ApiClient _api;

  Future<DashboardPage> getDashboard({int page = 1, int limit = 10}) async {
    final res = await _api.get<DashboardPage>(
      ApiUrls.dashboardList,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => DashboardPage.fromJson(json as Map<String, dynamic>),
    );
    if (!res.success || res.data == null) {
      throw Exception(res.error?.message ?? 'Could not load dashboard');
    }
    return res.data!;
  }
}
