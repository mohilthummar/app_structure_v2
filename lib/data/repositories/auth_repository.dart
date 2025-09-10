import 'package:app_structure/core/apis/client_service.dart';
import 'package:app_structure/core/apis/result.dart';
import 'package:app_structure/core/handler/api_url.dart';

class AuthRepository extends ClientService {
  Future<Result<BaseResponse<dynamic>, String>> signUp({
    required Map<String, dynamic> data,
  }) async {
    return request(
      requestType: RequestType.post,
      path: ApiUrls.signUp,
      data: data,
    );
  }

  Future<Result<BaseResponse<dynamic>, String>> validateSignUpOtp({
    required Map<String, dynamic> data,
  }) async {
    return request(
      requestType: RequestType.post,
      path: ApiUrls.validateSignUpOtp,
      data: data,
    );
  }

  Future<Result<BaseResponse<dynamic>, String>> signIn({
    required Map<String, dynamic> data,
  }) async {
    return request(
      requestType: RequestType.post,
      path: ApiUrls.signIn,
      data: data,
    );
  }

  Future<Result<BaseResponse<dynamic>, String>> validateSignInOtp({
    required Map<String, dynamic> data,
  }) async {
    return request(
      requestType: RequestType.post,
      path: ApiUrls.validateSignInOtp,
      data: data,
    );
  }

  Future<Result<BaseResponse<dynamic>, String>> resendOtp({
    required Map<String, dynamic> data,
  }) async {
    return request(
      requestType: RequestType.post,
      path: ApiUrls.resendOtp,
      data: data,
    );
  }
}
