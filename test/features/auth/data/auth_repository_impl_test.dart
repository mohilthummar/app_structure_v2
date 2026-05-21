import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/auth_repository_impl.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/data/login_response.dart';
import 'package:app_structure/features/auth/data/user_model.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockLocalStorage extends Mock implements LocalStorageService {}

void main() {
  late _MockAuthRemoteDataSource ds;
  late _MockSecureStorage secure;
  late _MockLocalStorage local;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequest(email: 'fallback@example.com', password: 'pw'),
    );
  });

  setUp(() {
    ds = _MockAuthRemoteDataSource();
    secure = _MockSecureStorage();
    local = _MockLocalStorage();
    repo = AuthRepositoryImpl(ds, secure, local);

    // Common storage stubs used by multiple tests.
    when(() => secure.saveToken(any())).thenAnswer((_) async {});
    when(() => secure.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => secure.clearAll()).thenAnswer((_) async {});
    when(() => local.saveUserData(any())).thenAnswer((_) async => true);
    when(() => local.clearUserData()).thenAnswer((_) async => true);
  });

  group('login', () {
    test('persists access token, refresh token, and user JSON on success', () async {
      const response = LoginResponse(
        user: UserModel(id: 'u1', email: 'user@example.com'),
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );
      when(() => ds.login(any())).thenAnswer((_) async => response);

      final result = await repo.login(
        const LoginRequest(email: 'user@example.com', password: 'Abcd1234'),
      );

      expect(result, same(response));
      verify(() => secure.saveToken('access-1')).called(1);
      verify(() => secure.saveRefreshToken('refresh-1')).called(1);

      final captured = verify(() => local.saveUserData(captureAny())).captured.single;
      final decoded = jsonDecode(captured as String) as Map<String, dynamic>;
      expect(decoded['id'], 'u1');
      expect(decoded['email'], 'user@example.com');
    });

    test('rethrows the underlying exception as Exception', () async {
      when(() => ds.login(any())).thenThrow(Exception('bad creds'));

      expect(
        () => repo.login(const LoginRequest(email: 'u', password: 'p')),
        throwsA(isA<Exception>()),
      );
    });

    test('does not persist when access token is null', () async {
      const response = LoginResponse(user: null, accessToken: null);
      when(() => ds.login(any())).thenAnswer((_) async => response);

      await repo.login(const LoginRequest(email: 'u', password: 'p'));

      verifyNever(() => secure.saveToken(any()));
      verifyNever(() => local.saveUserData(any()));
    });
  });

  group('logout', () {
    test('clears storage even when API logout throws', () async {
      when(() => ds.logout(deviceId: any(named: 'deviceId'))).thenThrow(Exception('network'));

      await repo.logout();

      verify(() => secure.clearAll()).called(1);
      verify(() => local.clearUserData()).called(1);
    });

    test('clears storage on happy path', () async {
      when(() => ds.logout(deviceId: any(named: 'deviceId'))).thenAnswer((_) async {});

      await repo.logout(deviceId: 'device-1');

      verify(() => ds.logout(deviceId: 'device-1')).called(1);
      verify(() => secure.clearAll()).called(1);
      verify(() => local.clearUserData()).called(1);
    });
  });

  group('isAuthenticated', () {
    test('delegates to SecureStorage.hasToken', () async {
      when(() => secure.hasToken()).thenAnswer((_) async => true);
      expect(await repo.isAuthenticated(), isTrue);

      when(() => secure.hasToken()).thenAnswer((_) async => false);
      expect(await repo.isAuthenticated(), isFalse);
    });
  });

  group('getStoredUser', () {
    test('returns null when no JSON cached', () async {
      when(() => local.userDataJson).thenReturn(null);
      expect(await repo.getStoredUser(), isNull);
    });

    test('returns null when cached JSON is empty', () async {
      when(() => local.userDataJson).thenReturn('');
      expect(await repo.getStoredUser(), isNull);
    });

    test('parses cached JSON into UserModel', () async {
      when(() => local.userDataJson).thenReturn('{"id":"u2","email":"x@y.com"}');

      final user = await repo.getStoredUser();

      expect(user, isNotNull);
      expect(user!.id, 'u2');
      expect(user.email, 'x@y.com');
    });

    test('returns null on malformed JSON', () async {
      when(() => local.userDataJson).thenReturn('not-json');
      expect(await repo.getStoredUser(), isNull);
    });
  });
}
