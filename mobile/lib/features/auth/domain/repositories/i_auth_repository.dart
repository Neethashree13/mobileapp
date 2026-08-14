import '../entities/user_entity.dart';
import '../entities/auth_tokens.dart';

/// Clean Domain Authentication Repository Interface
abstract class IAuthRepository {
  /// Register with Email and Password
  Future<({UserEntity user, AuthTokens tokens})> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    bool rememberMe = false,
  });

  /// Login with Email / Phone and Password
  Future<({UserEntity user, AuthTokens tokens})> login({
    String? email,
    String? phone,
    required String password,
    bool rememberMe = false,
  });

  /// Google OAuth Sign In
  Future<({UserEntity user, AuthTokens tokens})> loginWithGoogle({
    required String firebaseUid,
    required String email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phoneNumber,
    bool rememberMe = false,
  });

  /// Trigger SMS OTP
  Future<String> sendOtp({required String phone});

  /// Verify SMS OTP
  Future<({UserEntity user, AuthTokens tokens, bool isNewUser})> verifyOtp({
    required String phone,
    required String otp,
    bool rememberMe = false,
  });

  /// Forgot Password - Request Recovery OTP
  Future<String> forgotPassword({required String email});

  /// Reset Password with Recovery OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Get Profile from server
  Future<UserEntity> getProfile();

  /// Update Profile
  Future<UserEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
  });

  /// Logout active session
  Future<void> logout();

  /// Check if user is currently logged in with stored session
  Future<UserEntity?> checkAuthStatus();
}
