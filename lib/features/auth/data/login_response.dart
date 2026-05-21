import 'package:app_structure/features/auth/data/user_model.dart';

/// Login / verify-token response. Tolerant `fromJson` handles both the
/// nested `data.tokens.{access,refresh}.token` shape and flat
/// `accessToken`/`refreshToken` shapes some backends use.
class LoginResponse {
  const LoginResponse({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final tokens = data['tokens'] is Map<String, dynamic> ? data['tokens'] as Map<String, dynamic> : null;
    final access = tokens?['access'] is Map<String, dynamic> ? tokens!['access'] as Map<String, dynamic> : null;
    final refresh = tokens?['refresh'] is Map<String, dynamic> ? tokens!['refresh'] as Map<String, dynamic> : null;

    return LoginResponse(
      user: data['user'] is Map<String, dynamic> ? UserModel.fromJson(data['user'] as Map<String, dynamic>) : null,
      accessToken: access?['token'] as String? ?? data['accessToken'] as String?,
      refreshToken: refresh?['token'] as String? ?? data['refreshToken'] as String?,
      message: json['message'] as String?,
    );
  }
}
