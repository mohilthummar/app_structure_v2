import 'package:get/get.dart';

import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/core/utils/app_logger.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';

/// Base for every feature controller. Bundles the three things every
/// controller in this project needs:
///
/// * `state` — current `ViewState` (idle / loading / success / error / empty)
///   that views branch on via `StateSwitch`.
/// * `errorMessage` — last error string, shown in the `onError` builder.
/// * `runGuarded` — one-liner that wraps an async call with the full state
///   transition + try/catch + logger + optional snackbar. Cuts ~10 lines
///   of boilerplate per `on*` action.
///
/// Subclasses are still free to manage `state` manually when they need
/// non-standard transitions (e.g. parallel sub-states), but `runGuarded`
/// covers the 80% case.
abstract class BaseController extends GetxController {
  final state = ViewState.idle.obs;
  final errorMessage = ''.obs;

  /// Runs [body] inside a try/catch and drives `state` + `errorMessage`.
  ///
  /// * Sets `state = loading` before invoking [body].
  /// * On success: `state = success` (or `state = empty` when [emptyWhen]
  ///   returns true for the result), returns the value.
  /// * On failure: `state = error`, populates `errorMessage`, logs via
  ///   `AppLogger.error` (which forwards to Crashlytics in prod), optionally
  ///   shows an error snackbar, returns null.
  ///
  /// Pass [showErrorSnackbar] = false when the view will surface the error
  /// itself (e.g. inline form error) so the snackbar doesn't double up.
  Future<T?> runGuarded<T>(
    Future<T> Function() body, {
    bool showErrorSnackbar = true,
    String? errorTag,
    bool Function(T result)? emptyWhen,
  }) async {
    state.value = ViewState.loading;
    errorMessage.value = '';
    try {
      final result = await body();
      state.value = emptyWhen != null && emptyWhen(result) ? ViewState.empty : ViewState.success;
      return result;
    } catch (e, st) {
      state.value = ViewState.error;
      errorMessage.value = e.toString();
      AppLogger.error(
        e.toString(),
        tag: errorTag ?? runtimeType.toString(),
        error: e,
        stackTrace: st,
      );
      if (showErrorSnackbar) {
        AppSnackBar.error(message: e.toString());
      }
      return null;
    }
  }
}
