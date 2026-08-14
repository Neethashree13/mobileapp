import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_tokens.dart';
import 'package:flashcart_ai/features/auth/domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<({UserEntity user, AuthTokens tokens})> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    bool rememberMe = false,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      rememberMe: rememberMe,
    );

    if (response.user != null && response.tokens != null) {
      await localDataSource.saveSession(
        user: response.user!,
        tokens: response.tokens!,
        rememberMe: rememberMe,
      );
      return (user: response.user!, tokens: response.tokens!);
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Registration failed');
  }

  @override
  Future<({UserEntity user, AuthTokens tokens})> login({
    String? email,
    String? phone,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      phone: phone,
      password: password,
      rememberMe: rememberMe,
    );

    if (response.user != null && response.tokens != null) {
      await localDataSource.saveSession(
        user: response.user!,
        tokens: response.tokens!,
        rememberMe: rememberMe,
      );
      return (user: response.user!, tokens: response.tokens!);
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Login failed');
  }

  @override
  Future<({UserEntity user, AuthTokens tokens})> loginWithGoogle({
    required String firebaseUid,
    required String email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phoneNumber,
    bool rememberMe = false,
  }) async {
    final response = await remoteDataSource.loginWithGoogle(
      firebaseUid: firebaseUid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profilePhoto: profilePhoto,
      phoneNumber: phoneNumber,
      rememberMe: rememberMe,
    );

    if (response.user != null && response.tokens != null) {
      await localDataSource.saveSession(
        user: response.user!,
        tokens: response.tokens!,
        rememberMe: rememberMe,
      );
      return (user: response.user!, tokens: response.tokens!);
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Google OAuth sign in failed');
  }

  @override
  Future<String> sendOtp({required String phone}) async {
    final response = await remoteDataSource.sendOtp(phone: phone);
    if (response.success) {
      return response.otp ?? response.message;
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Failed to send OTP');
  }

  @override
  Future<({UserEntity user, AuthTokens tokens, bool isNewUser})> verifyOtp({
    required String phone,
    required String otp,
    bool rememberMe = false,
  }) async {
    final response = await remoteDataSource.verifyOtp(
      phone: phone,
      otp: otp,
      rememberMe: rememberMe,
    );

    if (response.user != null && response.tokens != null) {
      await localDataSource.saveSession(
        user: response.user!,
        tokens: response.tokens!,
        rememberMe: rememberMe,
      );
      return (
        user: response.user!,
        tokens: response.tokens!,
        isNewUser: response.isNewUser ?? false,
      );
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'OTP verification failed');
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final response = await remoteDataSource.forgotPassword(email: email);
    if (response.success) {
      return response.message;
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Failed to initiate password recovery');
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    if (response.success) {
      return true;
    }
    throw Exception(response.message.isNotEmpty ? response.message : 'Password reset failed');
  }

  @override
  Future<UserEntity> getProfile() async {
    final user = await remoteDataSource.getProfile();
    final tokens = await localDataSource.getCachedTokens();
    final rememberMe = await localDataSource.isRememberMeEnabled();
    if (tokens != null) {
      await localDataSource.saveSession(user: user, tokens: tokens, rememberMe: rememberMe);
    }
    return user;
  }

  @override
  Future<UserEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
  }) async {
    final updatedUser = await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profilePhoto: profilePhoto,
      gender: gender,
    );
    final tokens = await localDataSource.getCachedTokens();
    final rememberMe = await localDataSource.isRememberMeEnabled();
    if (tokens != null) {
      await localDataSource.saveSession(user: updatedUser, tokens: tokens, rememberMe: rememberMe);
    }
    return updatedUser;
  }

  @override
  Future<void> logout() async {
    final tokens = await localDataSource.getCachedTokens();
    if (tokens != null && tokens.refreshToken.isNotEmpty) {
      await remoteDataSource.logout(refreshToken: tokens.refreshToken);
    }
    await localDataSource.clearSession();
  }

  @override
  Future<UserEntity?> checkAuthStatus() async {
    final tokens = await localDataSource.getCachedTokens();
    if (tokens == null || tokens.accessToken.isEmpty) {
      return null;
    }

    try {
      // Fetch fresh profile from live backend
      final freshProfile = await remoteDataSource.getProfile();
      return freshProfile;
    } catch (_) {
      // Fallback to cached user if offline
      return await localDataSource.getCachedUser();
    }
  }
}
