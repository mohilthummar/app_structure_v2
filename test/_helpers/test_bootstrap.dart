import 'package:get/get.dart';

/// Shared helper for resetting GetX state between tests.
///
/// Call `setUp(testReset)` in every test that touches `Get.find` /
/// `Get.put` / `Get.lazyPut`. This keeps registrations isolated per test
/// and prevents cross-pollution.
///
/// Usage:
/// ```dart
/// void main() {
///   setUp(testReset);
///
///   test('login controller transitions state to loading', () async {
///     final repo = _MockAuthRepository();
///     final controller = LoginController(repo);
///     // ...
///   });
/// }
/// ```
void testInit() {
  Get.testMode = true;
}

/// Resets all `Get` registrations and re-enables test mode. Use in
/// `setUp` so each test starts from a clean DI graph.
void testReset() {
  Get.reset();
  Get.testMode = true;
}
