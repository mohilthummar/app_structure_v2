import 'package:get/get.dart';

/// Bindings for the [`ShowcaseView`].
///
/// The showcase is a pure presentation surface — every section either
/// renders static widgets or wires straight into a globally-registered
/// service (themed snackbars, pickers, shimmer). No new controller is
/// needed, so this binding is intentionally empty; it exists so the
/// route declaration matches the rest of the app.
class ShowcaseBindings extends Bindings {
  @override
  void dependencies() {}
}
