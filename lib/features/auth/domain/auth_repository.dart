import 'package:app_structure/features/auth/data/login_request.dart';
import 'package:app_structure/features/auth/data/login_response.dart';
import 'package:app_structure/features/auth/data/user_model.dart';

/// Auth domain interface. Controllers depend on THIS, never on
/// `AuthRepositoryImpl` or `AuthRemoteDataSource`. The impl handles token /
/// user persistence (SecureStorage + LocalStorage) inside its methods.
abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);

  Future<void> forgotPassword(String email);

  Future<void> logout({String? deviceId});

  Future<bool> isAuthenticated();

  Future<UserModel?> getStoredUser();
}
