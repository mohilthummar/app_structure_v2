// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

import 'package:app_structure/core/apis/client_service.dart';
// import 'package:app_structure/core/apis/result.dart';
// import 'package:app_structure/core/handler/api_url.dart';

class AuthRepository extends ClientService {
  // Future<Result<BaseResponse, String>> login({required Map<String, dynamic> data}) async {
  //   return request(
  //     requestType: RequestType.post,
  //     path: ApiUrls.login,
  //     data: data, //
  //   );
  // }

  // Future<Result<BaseResponse, String>> register({required Map<String, dynamic> data}) async {
  //   return request(
  //     requestType: RequestType.post,
  //     path: ApiUrls.register,
  //     data: data, //
  //   );
  // }

  // Future<Result<BaseResponse, String>> updateProfile({required Map<String, dynamic> data}) async {
  //   return request(
  //     requestType: RequestType.post,
  //     path: ApiUrls.updateProfile,
  //     data: data, //
  //   );
  // }

  // Future<Result<BaseResponse, String>> updateDeviceInfo({required String? deviceToken, required String? deviceID, required String? deviceName, required String? oAuthToken}) async {
  //   return request(
  //     requestType: RequestType.post,
  //     path: ApiUrls.updateDeviceInfo,
  //     data: {'device_type': Platform.isAndroid ? 'android' : 'ios', 'device_id': deviceID, 'device_name': deviceName, 'device_token': deviceToken, 'oauthToken': oAuthToken}, //
  //   );
  // }

  // Future<Result<User, String>> getProfile() async {
  //   Result<BaseResponse, String> result = await request(
  //     requestType: RequestType.get,
  //     path: ApiUrls.profile, //
  //   );
  //   return result.when(
  //     (value) {
  //       log("User: ------------------------>> ${jsonEncode(value.data['user'])}");
  //       return Success(User.fromJson(value.data['user']));
  //     },
  //     (error) {
  //       return Failure(error);
  //     },
  //   );
  // }
}
