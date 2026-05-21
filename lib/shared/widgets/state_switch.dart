import 'package:flutter/widgets.dart';

import 'package:app_structure/core/enums/view_state.dart';

/// Branches on a [ViewState] to render one of five widgets. The single
/// glue between controller state and the loading/empty/error/content UX —
/// every screen uses this so the pattern stays consistent.
///
/// Usage:
/// ```dart
/// Obx(() => StateSwitch(
///   state: controller.state.value,
///   onLoading: (_) => const AppLoading(),
///   onEmpty:   (_) => const AppEmptyState(title: 'Nothing here'),
///   onError:   (_) => AppErrorView(message: controller.errorMessage.value),
///   onSuccess: (_) => _buildContent(controller),
/// ));
/// ```
class StateSwitch extends StatelessWidget {
  const StateSwitch({
    super.key,
    required this.state,
    this.onIdle,
    required this.onLoading,
    required this.onEmpty,
    required this.onError,
    required this.onSuccess,
  });

  final ViewState state;
  final WidgetBuilder? onIdle;
  final WidgetBuilder onLoading;
  final WidgetBuilder onEmpty;
  final WidgetBuilder onError;
  final WidgetBuilder onSuccess;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewState.idle => (onIdle ?? (_) => const SizedBox.shrink())(context),
      ViewState.loading => onLoading(context),
      ViewState.empty => onEmpty(context),
      ViewState.error => onError(context),
      ViewState.success => onSuccess(context),
    };
  }
}
