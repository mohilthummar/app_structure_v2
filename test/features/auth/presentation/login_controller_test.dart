import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_structure/core/enums/view_state.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/presentation/login/login_controller.dart';

import '../../../_helpers/test_bootstrap.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  // Required so `GlobalKey.currentState` is reachable inside `onLogin`
  // (the controller reads `loginFormKey.currentState?.validate()`).
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(testReset);

  setUpAll(() {
    registerFallbackValue(
      const LoginRequest(email: 'fallback@example.com', password: 'pw'),
    );
  });

  group('LoginController initial state', () {
    test('starts in ViewState.idle', () {
      final controller = LoginController(_MockAuthRepository());
      expect(controller.state.value, ViewState.idle);
    });

    test('starts with empty errorMessage', () {
      final controller = LoginController(_MockAuthRepository());
      expect(controller.errorMessage.value, '');
    });

    test('starts with password hidden', () {
      final controller = LoginController(_MockAuthRepository());
      expect(controller.isPasswordHidden.value, isTrue);
    });
  });

  group('onTogglePassword', () {
    test('flips isPasswordHidden from true to false', () {
      final controller = LoginController(_MockAuthRepository());
      controller.onTogglePassword();
      expect(controller.isPasswordHidden.value, isFalse);
    });

    test('flips isPasswordHidden back to true on second call', () {
      final controller = LoginController(_MockAuthRepository());
      controller.onTogglePassword();
      controller.onTogglePassword();
      expect(controller.isPasswordHidden.value, isTrue);
    });
  });

  group('onLogin', () {
    test('returns false when the form key is not attached to a widget', () async {
      // In a pure unit test the FormState is null, so validate() returns null
      // and the controller short-circuits with false. This is the documented
      // pre-call guard — keeps the repo from being called on an unmounted form.
      final repo = _MockAuthRepository();
      final controller = LoginController(repo);

      final result = await controller.onLogin();

      expect(result, isFalse);
      verifyNever(() => repo.login(any()));
      expect(controller.state.value, ViewState.idle);
    });
  });
}
