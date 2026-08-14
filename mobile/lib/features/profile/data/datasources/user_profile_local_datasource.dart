import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../models/address_model.dart';
import '../models/user_preferences_model.dart';

class UserProfileLocalDataSource {
  static const String _profileKey = 'cached_user_profile';
  static const String _addressesKey = 'cached_user_addresses';
  static const String _preferencesKey = 'cached_user_preferences';

  Future<void> cacheProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfileModel?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr != null) {
      try {
        return UserProfileModel.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return null;
  }

  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = addresses.map((a) => a.toJson()).toList();
    await prefs.setString(_addressesKey, jsonEncode(listJson));
  }

  Future<List<AddressModel>> getCachedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_addressesKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        return list.map((item) => AddressModel.fromJson(item)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> cachePreferences(UserPreferencesModel preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  Future<UserPreferencesModel?> getCachedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_preferencesKey);
    if (jsonStr != null) {
      try {
        return UserPreferencesModel.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return null;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_addressesKey);
    await prefs.remove(_preferencesKey);
  }
}
