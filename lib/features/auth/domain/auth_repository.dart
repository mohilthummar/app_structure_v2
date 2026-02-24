import 'package:app_structure/features/auth/domain/user.dart';

/// Repository interface - Returns entity directly (not Result)
/// Repository implementation handles Result internally
abstract class AuthRepository {
  Future<User> signUp({
    required String name,
    required String mobileNumber,
    required String address,
  });

  Future<User> validateSignUpOtp({
    required String mobileNumber,
    required String otp,
  });

  Future<User> signIn({
    required String mobileNumber,
  });

  Future<User> validateSignInOtp({
    required String mobileNumber,
    required String otp,
  });

  Future<void> resendOtp({
    required String mobileNumber,
  });
}
