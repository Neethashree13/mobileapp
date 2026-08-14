import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enterprise Secure Token Storage Service for FlashCart AI Mobile
/// Uses FlutterSecureStorage with SharedPreferences fallback for web platform
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _accessTokenKey = 'fc_access_token';
  static const String _refreshTokenKey = 'fc_refresh_token';
  static const String _userDataKey = 'fc_user_data';
  static const String _rememberMeKey = 'fc_remember_me';
  static const String _savedEmailKey = 'fc_saved_email';

  SecureStorageService._internal();

  /// Save Access Token
  Future<void> writeAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
    }
  }

  /// Read Access Token
  Future<String?> readAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Save Refresh Token
  Future<void> writeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, token);
    }
  }

  /// Read Refresh Token
  Future<String?> readRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Save Logged In User JSON Data
  Future<void> writeUserData(Map<String, dynamic> userData) async {
    final jsonStr = jsonEncode(userData);
    try {
      await _storage.write(key: _userDataKey, value: jsonStr);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonStr);
    }
  }

  /// Read User Data
  Future<Map<String, dynamic>?> readUserData() async {
    try {
      final jsonStr = await _storage.read(key: _userDataKey);
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userDataKey);
    if (jsonStr != null) {
      try {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  /// Save Remember Me Preference
  Future<void> writeRememberMe(bool remember, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
    if (remember && email != null) {
      await prefs.setString(_savedEmailKey, email);
    } else {
      await prefs.remove(_savedEmailKey);
    }
  }

  /// Read Remember Me Preference
  Future<bool> readRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Read Saved Email
  Future<String?> readSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  /// Clear All Secure Session Data (Logout / Token Revocation)
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }

  /// Backwards-compatible: clear only tokens
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
