import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

// Repository Provider
final userProfileRepositoryProvider = Provider<IUserProfileRepository>((ref) {
  return UserProfileRepositoryImpl();
});

// Profile State & Notifier
class UserProfileState {
  final bool isLoading;
  final UserProfileEntity? profile;
  final String? error;

  const UserProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  UserProfileState copyWith({
    bool? isLoading,
    UserProfileEntity? profile,
    String? error,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final IUserProfileRepository _repository;

  UserProfileNotifier(this._repository) : super(const UserProfileState(isLoading: true)) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? bio,
    String? profilePhoto,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        bio: bio,
        profilePhoto: profilePhoto,
      );
      state = state.copyWith(isLoading: false, profile: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadPhoto(String photoUrl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.uploadProfilePhoto(photoUrl);
      state = state.copyWith(isLoading: false, profile: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return UserProfileNotifier(repo);
});

// Addresses State & Notifier
class AddressListState {
  final bool isLoading;
  final List<AddressEntity> addresses;
  final String? error;

  const AddressListState({
    this.isLoading = false,
    this.addresses = const [],
    this.error,
  });

  AddressListState copyWith({
    bool? isLoading,
    List<AddressEntity>? addresses,
    String? error,
  }) {
    return AddressListState(
      isLoading: isLoading ?? this.isLoading,
      addresses: addresses ?? this.addresses,
      error: error,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressListState> {
  final IUserProfileRepository _repository;

 AddressNotifier(this._repository)
    : super(const AddressListState(isLoading: false));

 Future<void> loadAddresses() async {
  debugPrint('========== LOAD ADDRESSES START ==========');

  state = state.copyWith(
    isLoading: true,
    error: null,
  );

  try {
    final addresses = await _repository.getAddresses();

    debugPrint(
      'LOAD ADDRESSES SUCCESS: ${addresses.length} addresses',
    );

    state = state.copyWith(
      isLoading: false,
      addresses: addresses,
      error: null,
    );

    debugPrint(
      'STATE NOW HAS: ${state.addresses.length} addresses',
    );
  } catch (e) {
    debugPrint(
      'LOAD ADDRESSES ERROR: $e',
    );

    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }

  debugPrint('========== LOAD ADDRESSES END ==========');
}

  Future<bool> addAddress(AddressEntity address) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final saved = await _repository.addAddress(address);
      final current = state.addresses;
      final updatedList = [saved, ...current.where((a) => a.id != saved.id)];
      state = state.copyWith(isLoading: false, addresses: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAddress(String id, AddressEntity address) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateAddress(id, address);
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAddress(id);
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.setDefaultAddress(id);
      state = state.copyWith(isLoading: false, addresses: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<AddressEntity?> reverseGeocode(double lat, double lng) async {
    try {
      return await _repository.reverseGeocode(lat, lng);
    } catch (_) {
      return null;
    }
  }
}

final userAddressesProvider = StateNotifierProvider<AddressNotifier, AddressListState>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return AddressNotifier(repo);
});

// Preferences State & Notifier
class PreferencesNotifier extends StateNotifier<AsyncValue<UserPreferencesEntity>> {
  final IUserProfileRepository _repository;

  PreferencesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await _repository.getPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updatePreferences(UserPreferencesEntity updated) async {
    try {
      final result = await _repository.updatePreferences(updated);
      state = AsyncValue.data(result);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final userPreferencesProvider = StateNotifierProvider<PreferencesNotifier, AsyncValue<UserPreferencesEntity>>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return PreferencesNotifier(repo);
});

// Settings Notifier
class SettingsNotifier extends StateNotifier<AsyncValue<UserSettingsEntity>> {
  final IUserProfileRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateSettings(UserSettingsEntity updated) async {
    try {
      final result = await _repository.updateSettings(updated);
      state = AsyncValue.data(result);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final userSettingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettingsEntity>>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return SettingsNotifier(repo);
});

// Activity History & Referrals
final activityHistoryProvider = FutureProvider<List<ActivityLogEntity>>((ref) async {
  final repo = ref.watch(userProfileRepositoryProvider);
  return await repo.getActivityHistory();
});

final referralInfoProvider = FutureProvider<ReferralEntity>((ref) async {
  final repo = ref.watch(userProfileRepositoryProvider);
  return await repo.getReferralInfo();
});
