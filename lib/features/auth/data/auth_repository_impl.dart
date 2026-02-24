import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/domain/user.dart';

/// Repository implementation - Implements domain interface
/// Handles Result internally using result.fold and returns entity directly (or throws exception)
/// Controller only receives the data, doesn't handle Result
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> signUp({
    required String name,
    required String mobileNumber,
    required String address,
  }) async {
    try {
      final user = await _remoteDataSource.signUp(
        name: name,
        mobileNumber: mobileNumber,
        address: address,
      );

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> validateSignUpOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final user = await _remoteDataSource.validateSignUpOtp(
        mobileNumber: mobileNumber,
        otp: otp,
      );

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> signIn({
    required String mobileNumber,
  }) async {
    try {
      final user = await _remoteDataSource.signIn(mobileNumber: mobileNumber);

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> validateSignInOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final user = await _remoteDataSource.validateSignInOtp(
        mobileNumber: mobileNumber,
        otp: otp,
      );

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resendOtp({
    required String mobileNumber,
  }) async {
    try {
      await _remoteDataSource.resendOtp(mobileNumber: mobileNumber);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
