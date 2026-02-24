import 'package:app_structure/core/config/api_url.dart';
import 'package:app_structure/core/network/client_service.dart';
import 'package:app_structure/features/auth/data/user_model.dart';
import 'package:app_structure/features/auth/domain/user.dart';

/// Remote datasource - Handles API calls
/// Returns JSON or throws exceptions
class AuthRemoteDataSource extends ClientService {
  Future<User> signUp({
    required String name,
    required String mobileNumber,
    required String address,
  }) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.signUp,
      data: {
        'name': name,
        'mobileNumber': mobileNumber,
        'address': address,
      },
    );

    return response.when(
      (success) {
        if (success.data != null) {
          return UserModel.fromJson(success.data).toEntity();
        }
        throw Exception(success.message);
      },
      (error) => throw Exception(error),
    );
  }

  Future<User> validateSignUpOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.validateSignUpOtp,
      data: {
        'mobileNumber': mobileNumber,
        'otp': otp,
      },
    );

    return response.when(
      (success) {
        if (success.data != null) {
          return UserModel.fromJson(success.data).toEntity();
        }
        throw Exception(success.message);
      },
      (error) => throw Exception(error),
    );
  }

  Future<User> signIn({
    required String mobileNumber,
  }) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.signIn,
      data: {
        'mobileNumber': mobileNumber,
      },
    );

    return response.when(
      (success) {
        if (success.data != null) {
          return UserModel.fromJson(success.data).toEntity();
        }
        throw Exception(success.message);
      },
      (error) => throw Exception(error),
    );
  }

  Future<User> validateSignInOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.validateSignInOtp,
      data: {
        'mobileNumber': mobileNumber,
        'otp': otp,
      },
    );

    return response.when(
      (success) {
        if (success.data != null) {
          return UserModel.fromJson(success.data).toEntity();
        }
        throw Exception(success.message);
      },
      (error) => throw Exception(error),
    );
  }

  Future<void> resendOtp({
    required String mobileNumber,
  }) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.resendOtp,
      data: {
        'mobileNumber': mobileNumber,
      },
    );

    response.when(
      (success) => null,
      (error) => throw Exception(error),
    );
  }
}
