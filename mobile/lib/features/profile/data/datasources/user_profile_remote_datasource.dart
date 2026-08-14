// import 'package:flutter/foundation.dart';
// import 'package:dio/dio.dart';

// import '../../../../core/network/api_client.dart';
// import '../models/user_profile_model.dart';
// import '../models/address_model.dart';
// import '../models/user_preferences_model.dart';
// import '../models/user_settings_model.dart';
// import '../models/activity_log_model.dart';
// class UserProfileRemoteDataSource {
//   final Dio _dio;

//   UserProfileRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

//   Future<UserProfileModel> getProfile() async {
//     final response = await _dio.get('/api/users/me/profile');
//     if (response.data != null && response.data['profile'] != null) {
//       return UserProfileModel.fromJson(response.data['profile']);
//     }
//     throw Exception('Failed to load profile');
//   }

//   Future<UserProfileModel> updateProfile({
//     String? firstName,
//     String? lastName,
//     String? phoneNumber,
//     String? gender,
//     String? bio,
//     String? profilePhoto,
//   }) async {
//     final response = await _dio.put(
//       '/api/users/me/profile',
//       data: {
//         if (firstName != null) 'firstName': firstName,
//         if (lastName != null) 'lastName': lastName,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (gender != null) 'gender': gender,
//         if (bio != null) 'bio': bio,
//         if (profilePhoto != null) 'profilePhoto': profilePhoto,
//       },
//     );
//     if (response.data != null && response.data['profile'] != null) {
//       return UserProfileModel.fromJson(response.data['profile']);
//     }
//     throw Exception('Failed to update profile');
//   }

//   Future<UserProfileModel> uploadProfilePhoto(String photoUrl) async {
//     final response = await _dio.post(
//       '/api/users/me/profile/photo',
//       data: {'photoUrl': photoUrl},
//     );
//     if (response.data != null && response.data['profile'] != null) {
//       return UserProfileModel.fromJson(response.data['profile']);
//     }
//     throw Exception('Failed to upload profile photo');
//   }

// Future<List<AddressModel>> getAddresses() async {
//   try {
//     final response = await _dio.get('/api/users/me/addresses');

//     debugPrint('========================================');
//     debugPrint('GET ADDRESSES STATUS: ${response.statusCode}');
//     debugPrint('GET ADDRESSES RESPONSE: ${response.data}');
//     debugPrint('========================================');

//     if (response.data != null &&
//         response.data['addresses'] != null) {
//       final list = response.data['addresses'] as List;

//       final addresses = list
//           .map((item) => AddressModel.fromJson(item))
//           .toList();

//       debugPrint('PARSED ADDRESSES COUNT: ${addresses.length}');

//       return addresses;
//     }

//     debugPrint('NO addresses field found in response');

//     return [];
//   } catch (e, stackTrace) {
//     debugPrint('GET ADDRESSES ERROR: $e');
//     debugPrint('STACK TRACE: $stackTrace');

//     rethrow;
//   }
// }

//   Future<List<AddressModel>> getRecentlyUsedAddresses() async {
//     try {
//       final response = await _dio.get('/api/users/me/addresses/recently-used');
//       if (response.data != null && response.data['addresses'] != null) {
//         final list = response.data['addresses'] as List;
//         return list.map((item) => AddressModel.fromJson(item)).toList();
//       }
//     } catch (_) {}
//     return [];
//   }

//   Future<AddressModel> addAddress(AddressModel address) async {
//   try {
//     print('[ADD ADDRESS] Sending: ${address.toJson()}');

//     final response = await _dio.post(
//       '/api/users/me/addresses',
//       data: address.toJson(),
//     );

//     print('[ADD ADDRESS] Status: ${response.statusCode}');
//     print('[ADD ADDRESS] Response: ${response.data}');

//     if (response.data != null &&
//         response.data['address'] != null) {
//       return AddressModel.fromJson(
//         response.data['address'],
//       );
//     }

//     throw Exception('Address was not returned by server');
//   } catch (e, stackTrace) {
//     print('[ADD ADDRESS ERROR] $e');
//     print(stackTrace);
//     rethrow;
//   }
// }

//   Future<AddressModel> updateAddress(String id, AddressModel address) async {
//     try {
//       final response = await _dio.put(
//         '/api/users/me/addresses/$id',
//         data: address.toJson(),
//       );
//       if (response.data != null && response.data['address'] != null) {
//         return AddressModel.fromJson(response.data['address']);
//       }
//     } catch (_) {}
//     return address;
//   }

//   Future<void> deleteAddress(String id) async {
//     try {
//       await _dio.delete('/api/users/me/addresses/$id');
//     } catch (_) {}
//   }

//   Future<List<AddressModel>> setDefaultAddress(String id) async {
//     try {
//       final response = await _dio.put('/api/users/me/addresses/$id/default');
//       if (response.data != null && response.data['addresses'] != null) {
//         final list = response.data['addresses'] as List;
//         return list.map((item) => AddressModel.fromJson(item)).toList();
//       }
//     } catch (_) {}
//     return getAddresses();
//   }

//   Future<AddressModel> reverseGeocode(double latitude, double longitude) async {
//     try {
//       final response = await _dio.post(
//         '/api/users/me/addresses/reverse-geocode',
//         data: {'latitude': latitude, 'longitude': longitude},
//       );
//       if (response.data != null && response.data['address'] != null) {
//         return AddressModel.fromJson(response.data['address']);
//       }
//     } catch (_) {
//       // Fallback
//     }
//     return AddressModel(
//       id: 'geo_1',
//       title: 'Current Location',
//       addressLine1: 'Koramangala 4th Block, 80 Feet Road',
//       street: 'Koramangala 4th Block, 80 Feet Road',
//       houseNo: '',
//       landmark: '',
//       city: 'Bengaluru',
//       state: 'Karnataka',
//       postalCode: '560102',
//       latitude: latitude,
//       longitude: longitude,
//     );
//   }

//   Future<UserPreferencesModel> getPreferences() async {
//     final response = await _dio.get('/api/users/me/preferences');
//     if (response.data != null && response.data['preferences'] != null) {
//       return UserPreferencesModel.fromJson(response.data['preferences']);
//     }
//     return const UserPreferencesModel();
//   }

//   Future<UserPreferencesModel> updatePreferences(UserPreferencesModel preferences) async {
//     final response = await _dio.put(
//       '/api/users/me/preferences',
//       data: preferences.toJson(),
//     );
//     if (response.data != null && response.data['preferences'] != null) {
//       return UserPreferencesModel.fromJson(response.data['preferences']);
//     }
//     return preferences;
//   }

//   Future<UserSettingsModel> getSettings() async {
//     final response = await _dio.get('/api/users/me/settings');
//     if (response.data != null && response.data['settings'] != null) {
//       return UserSettingsModel.fromJson(response.data['settings']);
//     }
//     return const UserSettingsModel();
//   }

//   Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
//     final response = await _dio.put(
//       '/api/users/me/settings',
//       data: settings.toJson(),
//     );
//     if (response.data != null && response.data['settings'] != null) {
//       return UserSettingsModel.fromJson(response.data['settings']);
//     }
//     return settings;
//   }

//   Future<List<ActivityLogModel>> getActivityHistory() async {
//     final response = await _dio.get('/api/users/me/activity');
//     if (response.data != null && response.data['history'] != null) {
//       final list = response.data['history'] as List;
//       return list.map((item) => ActivityLogModel.fromJson(item)).toList();
//     }
//     return [];
//   }

//   Future<ReferralModel> getReferralInfo() async {
//     final response = await _dio.get('/api/users/me/referral');
//     if (response.data != null && response.data['referral'] != null) {
//       return ReferralModel.fromJson(response.data['referral']);
//     }
//     return const ReferralModel(
//       referralCode: 'FLASHCART99',
//       referralLink: 'https://flashcart.ai/ref/FLASHCART99',
//       totalReferrals: 8,
//       totalEarnings: 400.0,
//       rewardPoints: 1200,
//     );
//   }

//   Future<void> deleteAccount() async {
//     await _dio.delete('/api/users/me');
//   }

//   Future<void> deactivateAccount() async {
//     await _dio.post('/api/users/me/deactivate');
//   }
// }


import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';
import '../models/address_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_settings_model.dart';
import '../models/activity_log_model.dart';

class UserProfileRemoteDataSource {
  final Dio _dio;

  UserProfileRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient().http;

  Future<UserProfileModel> getProfile() async {
    final response = await _dio.get('/api/users/me/profile');
    if (response.data != null && response.data['profile'] != null) {
      return UserProfileModel.fromJson(response.data['profile']);
    }
    throw Exception('Failed to load profile');
  }

  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? bio,
    String? profilePhoto,
  }) async {
    final response = await _dio.put(
      '/api/users/me/profile',
      data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (gender != null) 'gender': gender,
        if (bio != null) 'bio': bio,
        if (profilePhoto != null) 'profilePhoto': profilePhoto,
      },
    );
    if (response.data != null && response.data['profile'] != null) {
      return UserProfileModel.fromJson(response.data['profile']);
    }
    throw Exception('Failed to update profile');
  }

  Future<UserProfileModel> uploadProfilePhoto(String photoUrl) async {
    final response = await _dio.post(
      '/api/users/me/profile/photo',
      data: {'photoUrl': photoUrl},
    );
    if (response.data != null && response.data['profile'] != null) {
      return UserProfileModel.fromJson(response.data['profile']);
    }
    throw Exception('Failed to upload profile photo');
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dio.get('/api/users/me/addresses');
      if (response.data != null && response.data['addresses'] != null) {
        final list = response.data['addresses'] as List;
        return list.map((item) => AddressModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<AddressModel>> getRecentlyUsedAddresses() async {
    try {
      final response = await _dio.get('/api/users/me/addresses/recently-used');
      if (response.data != null && response.data['addresses'] != null) {
        final list = response.data['addresses'] as List;
        return list.map((item) => AddressModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await _dio.post(
        '/api/users/me/addresses',
        data: address.toJson(),
      );
      if (response.data != null && response.data['address'] != null) {
        return AddressModel.fromJson(response.data['address']);
      }
    } catch (e) {
      print('Remote addAddress error: $e');
    }
    return address;
  }

  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    try {
      final response = await _dio.put(
        '/api/users/me/addresses/$id',
        data: address.toJson(),
      );
      if (response.data != null && response.data['address'] != null) {
        return AddressModel.fromJson(response.data['address']);
      }
    } catch (_) {}
    return address;
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete('/api/users/me/addresses/$id');
    } catch (_) {}
  }

  Future<List<AddressModel>> setDefaultAddress(String id) async {
    try {
      final response = await _dio.put('/api/users/me/addresses/$id/default');
      if (response.data != null && response.data['addresses'] != null) {
        final list = response.data['addresses'] as List;
        return list.map((item) => AddressModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return getAddresses();
  }

  Future<AddressModel> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '/api/users/me/addresses/reverse-geocode',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      if (response.data != null && response.data['address'] != null) {
        return AddressModel.fromJson(response.data['address']);
      }
    } catch (_) {
      // Fallback
    }
    return AddressModel(
      id: 'geo_1',
      title: 'Current Location',
      addressLine1: 'Koramangala 4th Block, 80 Feet Road',
      street: 'Koramangala 4th Block, 80 Feet Road',
      houseNo: '',
      landmark: '',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560102',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<UserPreferencesModel> getPreferences() async {
    final response = await _dio.get('/api/users/me/preferences');
    if (response.data != null && response.data['preferences'] != null) {
      return UserPreferencesModel.fromJson(response.data['preferences']);
    }
    return const UserPreferencesModel();
  }

  Future<UserPreferencesModel> updatePreferences(UserPreferencesModel preferences) async {
    final response = await _dio.put(
      '/api/users/me/preferences',
      data: preferences.toJson(),
    );
    if (response.data != null && response.data['preferences'] != null) {
      return UserPreferencesModel.fromJson(response.data['preferences']);
    }
    return preferences;
  }

  Future<UserSettingsModel> getSettings() async {
    final response = await _dio.get('/api/users/me/settings');
    if (response.data != null && response.data['settings'] != null) {
      return UserSettingsModel.fromJson(response.data['settings']);
    }
    return const UserSettingsModel();
  }

  Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
    final response = await _dio.put(
      '/api/users/me/settings',
      data: settings.toJson(),
    );
    if (response.data != null && response.data['settings'] != null) {
      return UserSettingsModel.fromJson(response.data['settings']);
    }
    return settings;
  }

  Future<List<ActivityLogModel>> getActivityHistory() async {
    final response = await _dio.get('/api/users/me/activity');
    if (response.data != null && response.data['history'] != null) {
      final list = response.data['history'] as List;
      return list.map((item) => ActivityLogModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<ReferralModel> getReferralInfo() async {
    final response = await _dio.get('/api/users/me/referral');
    if (response.data != null && response.data['referral'] != null) {
      return ReferralModel.fromJson(response.data['referral']);
    }
    return const ReferralModel(
      referralCode: 'FLASHCART99',
      referralLink: 'https://flashcart.ai/ref/FLASHCART99',
      totalReferrals: 8,
      totalEarnings: 400.0,
      rewardPoints: 1200,
    );
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/api/users/me');
  }

  Future<void> deactivateAccount() async {
    await _dio.post('/api/users/me/deactivate');
  }
}
