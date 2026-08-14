import '../../domain/entities/user_entity.dart';

/// Data Model for User
class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.phone,
    super.firstName,
    super.lastName,
    super.profilePhoto,
    super.gender,
    super.role,
    super.isVerified,
    super.isActive,
    super.authProvider,
    super.walletBalance,
    super.streakCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['userId'] ?? json['uuid'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString(),
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
      profilePhoto: json['profilePhoto']?.toString() ?? json['profile_photo']?.toString() ?? json['profileImage']?.toString(),
      gender: json['gender']?.toString(),
      role: (json['role'] ?? 'USER').toString(),
      isVerified: json['isVerified'] == true || json['is_verified'] == true,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      authProvider: (json['authProvider'] ?? json['auth_provider'] ?? 'LOCAL').toString(),
      walletBalance: double.tryParse(
  (json['walletBalance'] ?? json['wallet_balance'] ?? 0).toString()
) ?? 0.0,
      streakCount: (json['streakCount'] ?? json['streak_count'] ?? 0 as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'phoneNumber': phone,
      'firstName': firstName,
      'lastName': lastName,
      'profilePhoto': profilePhoto,
      'gender': gender,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'authProvider': authProvider,
      'walletBalance': walletBalance,
      'streakCount': streakCount,
    };
  }
}
