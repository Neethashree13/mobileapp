import 'user_model.dart';
import '../../domain/entities/auth_tokens.dart';

/// Data Model for API Authentication Response
class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel? user;
  final AuthTokens? tokens;
  final bool? isNewUser;
  final String? otp;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.tokens,
    this.isNewUser,
    this.otp,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user']);
    } else if (json['profile'] != null && json['profile'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['profile']);
    }

    AuthTokens? parsedTokens;
    if (json['tokens'] != null && json['tokens'] is Map<String, dynamic>) {
      final t = json['tokens'];
      parsedTokens = AuthTokens(
        accessToken: (t['accessToken'] ?? '').toString(),
        refreshToken: (t['refreshToken'] ?? '').toString(),
        tokenType: (t['tokenType'] ?? 'Bearer').toString(),
        expiresIn: (t['expiresIn'] ?? 900 as num).toInt(),
      );
    } else if (json['accessToken'] != null) {
      parsedTokens = AuthTokens(
        accessToken: json['accessToken'].toString(),
        refreshToken: (json['refreshToken'] ?? '').toString(),
        tokenType: (json['tokenType'] ?? 'Bearer').toString(),
        expiresIn: (json['expiresIn'] ?? 900 as num).toInt(),
      );
    }

    return AuthResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      user: parsedUser,
      tokens: parsedTokens,
      isNewUser: json['isNewUser'] == true,
      otp: json['otp']?.toString(),
    );
  }
}
