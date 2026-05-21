/// Login form payload. Constructed in `LoginController.onLogin` and passed
/// to `AuthRepository.login`. `deviceInfo` is built by `DeviceInfoService`
/// when push / device tracking is wired; nullable so projects without FCM
/// can omit it.
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.deviceInfo,
  });

  final String email;
  final String password;
  final Map<String, dynamic>? deviceInfo;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (deviceInfo != null) 'device_info': deviceInfo,
  };
}
