import 'dart:convert';

import 'package:app_structure/core/storage/local_storage.dart';
import 'package:app_structure/core/storage/secure_storage.dart';
import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/data/login_response.dart';
import 'package:app_structure/features/auth/data/user_model.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';

/// Concrete auth repository. Handles token storage (SecureStorage) and
/// cached user (LocalStorage) inside the repo so feature controllers only
/// know about typed input/output and exceptions.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ds, this._secure, this._local);

  final AuthRemoteDataSource _ds;
  final SecureStorageService _secure;
  final LocalStorageService _local;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _ds.login(request);
      await _persist(response);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _ds.forgotPassword(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout({String? deviceId}) async {
    try {
      await _ds.logout(deviceId: deviceId);
    } catch (_) {
      // Tolerate API failure — local cleanup always runs.
    }
    await _secure.clearAll();
    await _local.clearUserData();
  }

  @override
  Future<bool> isAuthenticated() => _secure.hasToken();

  @override
  Future<UserModel?> getStoredUser() async {
    final raw = _local.userDataJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(LoginResponse r) async {
    if (r.accessToken != null && r.accessToken!.isNotEmpty) {
      await _secure.saveToken(r.accessToken!);
    }
    if (r.refreshToken != null && r.refreshToken!.isNotEmpty) {
      await _secure.saveRefreshToken(r.refreshToken!);
    }
    if (r.user != null) {
      await _local.saveUserData(jsonEncode(r.user!.toJson()));
    }
  }
}
