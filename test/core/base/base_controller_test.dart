import 'package:flutter_test/flutter_test.dart';

import 'package:app_structure/core/base/base_controller.dart';
import 'package:app_structure/core/enums/view_state.dart';

import '../../_helpers/test_bootstrap.dart';

/// Concrete subclass — `BaseController` is abstract so we can't instantiate
/// it directly. This subclass adds nothing; the tests exercise the
/// inherited `runGuarded` / `state` / `errorMessage`.
class _TestController extends BaseController {}

void main() {
  setUp(testReset);

  group('BaseController initial state', () {
    test('starts in ViewState.idle', () {
      final c = _TestController();
      expect(c.state.value, ViewState.idle);
    });

    test('starts with empty errorMessage', () {
      final c = _TestController();
      expect(c.errorMessage.value, isEmpty);
    });
  });

  group('runGuarded', () {
    test('transitions to success and returns the value on happy path', () async {
      final c = _TestController();

      final result = await c.runGuarded(() async => 42);

      expect(result, 42);
      expect(c.state.value, ViewState.success);
      expect(c.errorMessage.value, isEmpty);
    });

    test('transitions to error and returns null on thrown exception', () async {
      final c = _TestController();

      final result = await c.runGuarded<int>(
        () async => throw Exception('boom'),
        showErrorSnackbar: false,
      );

      expect(result, isNull);
      expect(c.state.value, ViewState.error);
      expect(c.errorMessage.value, contains('boom'));
    });

    test('transitions to empty when emptyWhen returns true', () async {
      final c = _TestController();

      final result = await c.runGuarded<List<int>>(
        () async => <int>[],
        emptyWhen: (list) => list.isEmpty,
      );

      expect(result, isEmpty);
      expect(c.state.value, ViewState.empty);
    });

    test('clears previous errorMessage before running', () async {
      final c = _TestController();
      c.errorMessage.value = 'stale error';

      await c.runGuarded(() async => 1);

      expect(c.errorMessage.value, isEmpty);
    });

    test('uses errorTag in the logger when provided', () async {
      // We can't easily intercept AppLogger, but we can at least verify
      // runGuarded doesn't crash when errorTag is set.
      final c = _TestController();

      final result = await c.runGuarded<int>(
        () async => throw Exception('tagged'),
        showErrorSnackbar: false,
        errorTag: 'TestTag',
      );

      expect(result, isNull);
      expect(c.state.value, ViewState.error);
    });
  });
}
