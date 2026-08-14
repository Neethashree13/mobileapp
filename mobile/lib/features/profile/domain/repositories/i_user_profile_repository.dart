import '../entities/user_profile_entity.dart';
import '../entities/address_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../entities/user_settings_entity.dart';
import '../entities/activity_log_entity.dart';

abstract class IUserProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? bio,
    String? profilePhoto,
  });
  Future<UserProfileEntity> uploadProfilePhoto(String photoPathOrUrl);

  Future<List<AddressEntity>> getAddresses();
  Future<List<AddressEntity>> getRecentlyUsedAddresses();
  Future<AddressEntity> addAddress(AddressEntity address);
  Future<AddressEntity> updateAddress(String id, AddressEntity address);
  Future<void> deleteAddress(String id);
  Future<List<AddressEntity>> setDefaultAddress(String id);
  Future<AddressEntity> reverseGeocode(double latitude, double longitude);

  Future<UserPreferencesEntity> getPreferences();
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences);

  Future<UserSettingsEntity> getSettings();
  Future<UserSettingsEntity> updateSettings(UserSettingsEntity settings);

  Future<List<ActivityLogEntity>> getActivityHistory();
  Future<ReferralEntity> getReferralInfo();

  Future<void> deleteAccount();
  Future<void> deactivateAccount();
}
