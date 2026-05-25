import 'package:app_structure/features/home/data/dashboard_item_model.dart';

/// Home/dashboard domain contract. Controllers depend on THIS, never on
/// the impl. Same shape as `AuthRepository` so adding new features
/// follows the same recipe.
abstract class HomeRepository {
  Future<DashboardPage> getDashboard({int page = 1, int limit = 10});
}
