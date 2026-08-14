import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_state.dart';

// 1. Dependency Injection Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<IAuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(storage: ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// 2. Auth State Controller
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  /// Initial App Start - Check persistent session
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.checkAuthStatus();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Email & Password Login
  Future<bool> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        infoMessage: 'Login successful!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Registration
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        infoMessage: 'Account created successfully. Please log in to continue.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Google OAuth Sign In
  Future<bool> loginWithGoogle({
    required String firebaseUid,
    required String email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phoneNumber,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repository.loginWithGoogle(
        firebaseUid: firebaseUid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        profilePhoto: profilePhoto,
        phoneNumber: phoneNumber,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        infoMessage: 'Signed in with Google!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Request Phone OTP
  Future<bool> sendOtp({required String phone}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final info = await _repository.sendOtp(phone: phone);
      state = state.copyWith(
        status: AuthStatus.otpSent,
        pendingPhone: phone,
        infoMessage: info,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Verify Phone OTP
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repository.verifyOtp(
        phone: phone,
        otp: otp,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        isNewUser: result.isNewUser,
        infoMessage: 'Phone OTP verified!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Forgot Password Request
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final info = await _repository.forgotPassword(email: email);
      state = state.copyWith(
        status: AuthStatus.passwordResetSent,
        pendingEmail: email,
        infoMessage: info,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Reset Password Execution
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        infoMessage: 'Password reset successfully! Please sign in with your new password.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update User Profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final updatedUser = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profilePhoto: profilePhoto,
        gender: gender,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        infoMessage: 'Profile updated successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.logout();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear Error or Info Messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      infoMessage: null,
    );
  }
}

// 3. Main Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
