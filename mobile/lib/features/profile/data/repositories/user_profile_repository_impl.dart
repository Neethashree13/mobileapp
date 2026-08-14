import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../datasources/user_profile_local_datasource.dart';
import '../models/address_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_settings_model.dart';

class UserProfileRepositoryImpl implements IUserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileLocalDataSource localDataSource;

  UserProfileRepositoryImpl({
    UserProfileRemoteDataSource? remoteDataSource,
    UserProfileLocalDataSource? localDataSource,
  })  : remoteDataSource = remoteDataSource ?? UserProfileRemoteDataSource(),
        localDataSource = localDataSource ?? UserProfileLocalDataSource();

  @override
  Future<UserProfileEntity> getProfile() async {
    try {
      final remoteProfile = await remoteDataSource.getProfile();
      await localDataSource.cacheProfile(remoteProfile);
      return remoteProfile;
    } catch (_) {
      final cached = await localDataSource.getCachedProfile();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? bio,
    String? profilePhoto,
  }) async {
    final updated = await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      gender: gender,
      bio: bio,
      profilePhoto: profilePhoto,
    );
    await localDataSource.cacheProfile(updated);
    return updated;
  }

  @override
  Future<UserProfileEntity> uploadProfilePhoto(String photoPathOrUrl) async {
    final updated = await remoteDataSource.uploadProfilePhoto(photoPathOrUrl);
    await localDataSource.cacheProfile(updated);
    return updated;
  }

 @override
Future<List<AddressEntity>> getAddresses() async {
  debugPrint('========== REPOSITORY GET ADDRESSES ==========');

  try {
    final addresses = await remoteDataSource.getAddresses();

    debugPrint(
      'REPOSITORY: Backend returned ${addresses.length} addresses',
    );

    await localDataSource.cacheAddresses(addresses);

    return addresses;
  } catch (e, stackTrace) {
    debugPrint('REPOSITORY GET ADDRESSES ERROR: $e');
    debugPrint('$stackTrace');

    rethrow;
  }
}

  @override
  Future<List<AddressEntity>> getRecentlyUsedAddresses() async {
    try {
      final addresses = await remoteDataSource.getRecentlyUsedAddresses();
      if (addresses.isNotEmpty) {
        return addresses;
      }
    } catch (_) {}
    final addresses = await getAddresses();
    return addresses.take(3).toList();
  }

  @override
Future<AddressEntity> addAddress(AddressEntity address) async {
  debugPrint('========== REPOSITORY ADD ADDRESS START ==========');

  try {
    final model = AddressModel.fromEntity(address);

    debugPrint('ADDRESS MODEL CREATED');
    debugPrint('ID: ${model.id}');
    debugPrint('TITLE: ${model.title}');
    debugPrint('ADDRESS LINE 1: ${model.addressLine1}');
    debugPrint('CITY: ${model.city}');
    debugPrint('STATE: ${model.state}');
    debugPrint('PIN: ${model.postalCode}');
    debugPrint('LATITUDE: ${model.latitude}');
    debugPrint('LONGITUDE: ${model.longitude}');
    debugPrint('IS DEFAULT: ${model.isDefault}');

    // IMPORTANT:
    // Do NOT silently fallback to local storage.
    // The backend must successfully save the address.
    final savedAddress = await remoteDataSource.addAddress(model);

    debugPrint('========== BACKEND ADDRESS SAVE SUCCESS ==========');
    debugPrint('SAVED ADDRESS ID: ${savedAddress.id}');

    // Cache only after backend successfully saves.
    final cached = await localDataSource.getCachedAddresses();

    final updatedList = [
      savedAddress,
      ...cached.where((a) => a.id != savedAddress.id),
    ];

    await localDataSource.cacheAddresses(updatedList);

    debugPrint('LOCAL ADDRESS CACHE UPDATED');
    debugPrint('TOTAL CACHED ADDRESSES: ${updatedList.length}');

    return savedAddress;
  } catch (e, stackTrace) {
    debugPrint('========== BACKEND ADDRESS SAVE FAILED ==========');
    debugPrint('ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');

    // IMPORTANT:
    // Re-throw the error so the UI knows the save failed.
    rethrow;
  }
}

  @override
  Future<AddressEntity> updateAddress(String id, AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    AddressEntity updated = address;
    try {
      updated = await remoteDataSource.updateAddress(id, model);
    } catch (_) {
      updated = address;
    }
    final cached = await localDataSource.getCachedAddresses();
    final updatedList = cached.map((item) => item.id == id ? AddressModel.fromEntity(updated) : item).toList();
    await localDataSource.cacheAddresses(updatedList);
    return updated;
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
    } catch (_) {}
    final cached = await localDataSource.getCachedAddresses();
    final updatedList = cached.where((item) => item.id != id).toList();
    await localDataSource.cacheAddresses(updatedList);
  }

  @override
  Future<List<AddressEntity>> setDefaultAddress(String id) async {
    try {
      final list = await remoteDataSource.setDefaultAddress(id);
      if (list.isNotEmpty) {
        await localDataSource.cacheAddresses(list);
        return list;
      }
    } catch (_) {}
    final cached = await localDataSource.getCachedAddresses();
    final updatedList = cached.map((item) {
      return AddressModel(
        id: item.id,
        title: item.title,
        addressLine1: item.addressLine1,
        addressLine2: item.addressLine2,
        houseNo: item.houseNo,
        street: item.street,
        landmark: item.landmark,
        city: item.city,
        state: item.state,
        postalCode: item.postalCode,
        country: item.country,
        latitude: item.latitude,
        longitude: item.longitude,
        isDefault: item.id == id,
      );
    }).toList();
    await localDataSource.cacheAddresses(updatedList);
    return updatedList;
  }

  @override
  Future<AddressEntity> reverseGeocode(double latitude, double longitude) async {
    return await remoteDataSource.reverseGeocode(latitude, longitude);
  }

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    try {
      final prefs = await remoteDataSource.getPreferences();
      await localDataSource.cachePreferences(prefs);
      return prefs;
    } catch (_) {
      final cached = await localDataSource.getCachedPreferences();
      if (cached != null) return cached;
      return const UserPreferencesEntity();
    }
  }

  @override
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences) async {
    final model = UserPreferencesModel(
      emailNotifications: preferences.emailNotifications,
      pushNotifications: preferences.pushNotifications,
      smsNotifications: preferences.smsNotifications,
      promotionalAlerts: preferences.promotionalAlerts,
      orderUpdates: preferences.orderUpdates,
      deliveryAlerts: preferences.deliveryAlerts,
      language: preferences.language,
      dietary: preferences.dietary,
      shareDataWithPartners: preferences.shareDataWithPartners,
      personalizedAds: preferences.personalizedAds,
      locationTracking: preferences.locationTracking,
    );
    final updated = await remoteDataSource.updatePreferences(model);
    await localDataSource.cachePreferences(updated);
    return updated;
  }

  @override
  Future<UserSettingsEntity> getSettings() async {
    return await remoteDataSource.getSettings();
  }

  @override
  Future<UserSettingsEntity> updateSettings(UserSettingsEntity settings) async {
    final model = UserSettingsModel(
      isDarkMode: settings.isDarkMode,
      biometricsEnabled: settings.biometricsEnabled,
      cacheSizeMb: settings.cacheSizeMb,
    );
    return await remoteDataSource.updateSettings(model);
  }

  @override
  Future<List<ActivityLogEntity>> getActivityHistory() async {
    return await remoteDataSource.getActivityHistory();
  }

  @override
  Future<ReferralEntity> getReferralInfo() async {
    return await remoteDataSource.getReferralInfo();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
    await localDataSource.clearCache();
  }

  @override
  Future<void> deactivateAccount() async {
    await remoteDataSource.deactivateAccount();
    await localDataSource.clearCache();
  }
}
