import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> login({
    String? email,
    String? phone,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> loginWithGoogle({
    required String firebaseUid,
    required String email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phoneNumber,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> sendOtp({required String phone});

  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> forgotPassword({required String email});

  Future<AuthResponseModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
  });

  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    bool rememberMe = false,
  }) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          'rememberMe': rememberMe,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> login({
    String? email,
    String? phone,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/login',
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'password': password,
          'rememberMe': rememberMe,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> loginWithGoogle({
    required String firebaseUid,
    required String email,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? phoneNumber,
    bool rememberMe = false,
  }) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/google',
        data: {
          'firebaseUid': firebaseUid,
          'email': email,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (profilePhoto != null) 'profilePhoto': profilePhoto,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          'rememberMe': rememberMe,
          'device_name': 'Flutter Mobile Client',
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> sendOtp({required String phone}) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/send-otp',
        data: {'phone': phone},
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
    bool rememberMe = false,
  }) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
          'rememberMe': rememberMe,
          'device_name': 'Flutter Mobile Client',
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> forgotPassword({required String email}) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.http.post(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.http.get('/api/auth/profile');
      if (response.data['user'] != null) {
        return UserModel.fromJson(response.data['user']);
      }
      throw ApiException(message: 'Invalid profile response from server');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
  }) async {
    try {
      final response = await apiClient.http.put(
        '/api/auth/profile',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (profilePhoto != null) 'profilePhoto': profilePhoto,
          if (gender != null) 'gender': gender,
        },
      );
      if (response.data['profile'] != null) {
        return UserModel.fromJson(response.data['profile']);
      } else if (response.data['user'] != null) {
        return UserModel.fromJson(response.data['user']);
      }
      throw ApiException(message: 'Failed to update user profile');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await apiClient.http.post(
        '/api/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      // Non-blocking logout error
      print('Logout warning: $e');
    }
  }
}
