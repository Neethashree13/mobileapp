import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../../domain/entities/auth_tokens.dart';

abstract class IAuthLocalDataSource {
  Future<void> saveSession({
    required UserModel user,
    required AuthTokens tokens,
    required bool rememberMe,
  });

  Future<UserModel?> getCachedUser();

  Future<AuthTokens?> getCachedTokens();

  Future<bool> isRememberMeEnabled();

  Future<String?> getSavedEmail();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  final SecureStorageService storage;

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveSession({
    required UserModel user,
    required AuthTokens tokens,
    required bool rememberMe,
  }) async {
    await storage.writeAccessToken(tokens.accessToken);
    await storage.writeRefreshToken(tokens.refreshToken);
    await storage.writeUserData(user.toJson());
    await storage.writeRememberMe(rememberMe, email: user.email);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userData = await storage.readUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<AuthTokens?> getCachedTokens() async {
    final accessToken = await storage.readAccessToken();
    final refreshToken = await storage.readRefreshToken();
    if (accessToken != null && refreshToken != null) {
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    return null;
  }

  @override
  Future<bool> isRememberMeEnabled() async {
    return await storage.readRememberMe();
  }

  @override
  Future<String?> getSavedEmail() async {
    return await storage.readSavedEmail();
  }

  @override
  Future<void> clearSession() async {
    await storage.clearAll();
  }
}
