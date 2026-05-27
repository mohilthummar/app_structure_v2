import 'package:get/get.dart';

import 'package:app_structure/core/base/base_controller.dart';
import 'package:app_structure/core/constants/app_constants.dart';
import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/utils/app_logger.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/home/data/dashboard_item_model.dart';
import 'package:app_structure/features/home/domain/home_repository.dart';

/// Dashboard list controller. Demonstrates the canonical paginated-list
/// pattern using `BaseController.runGuarded` + `StateSwitch` + a simple
/// `_loadingMore` guard.
///
/// To clone for a new list screen:
///   1. Copy this file, rename `items` / `DashboardItem` / `_repo.getDashboard`.
///   2. Update the binding to provide the right repository.
///   3. View widget stays almost identical — only the row builder changes.
class DashboardController extends BaseController {
  DashboardController(this._repo);

  final HomeRepository _repo;

  /// Visible list. Views can `Obx` on this directly.
  final items = <DashboardItem>[].obs;

  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  void onReady() {
    super.onReady();
    onRefresh();
  }

  /// Reset + load first page. Bind to `RefreshIndicator.onRefresh`.
  /// Named `onRefresh` (not `refresh`) to avoid shadowing
  /// `GetxController.refresh()`.
  Future<void> onRefresh() async {
    _page = 1;
    _hasMore = true;
    items.clear();
    await _fetch();
  }

  /// Pull next page. Idempotent — no-ops when already loading or end
  /// reached. Trigger from a scroll listener / `itemBuilder` near the
  /// bottom of the list.
  ///
  /// Deliberately bypasses [runGuarded]: that would flip `state` to
  /// `loading`, and `StateSwitch.onLoading` swaps the list for a full-
  /// screen spinner. During pagination we want the visible list to stay
  /// rendered while a footer indicator (driven by [loadingMore]) shows
  /// progress. Errors here surface via snackbar, not the error state.
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    try {
      final page = await _repo.getDashboard(
        page: _page,
        limit: AppConstants.defaultPageLimit,
      );
      items.addAll(page.items);
      _hasMore = page.hasMore;
      _page = page.page + 1;
    } catch (e, st) {
      AppLogger.error(
        e.toString(),
        tag: 'DashboardController.loadMore',
        error: e,
        stackTrace: st,
      );
      AppSnackBar.error(message: e.toString());
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> _fetch() async {
    final page = await runGuarded<DashboardPage>(
      () => _repo.getDashboard(page: _page, limit: AppConstants.defaultPageLimit),
      errorTag: 'DashboardController._fetch',
      showErrorSnackbar: false, // initial failure surfaces via StateSwitch.onError
      emptyWhen: (p) => p.items.isEmpty,
    );

    if (page == null) return;

    items.addAll(page.items);
    _hasMore = page.hasMore;
    _page = page.page + 1;

    if (items.isEmpty) {
      state.value = ViewState.empty;
    }
  }
}
