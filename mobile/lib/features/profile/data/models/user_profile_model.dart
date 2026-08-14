import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.walletBalance,
    required super.streakCount,
    super.profilePhoto,
    super.profileImage,
    super.gender,
    super.bio,
    super.lastLogin,
    super.completionPercentage,
    super.referralCode,
    super.isVerified,
    super.isActive,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      profilePhoto: json['profilePhoto']?.toString() ?? json['profileImage']?.toString(),
      profileImage: json['profileImage']?.toString() ?? json['profilePhoto']?.toString(),
      gender: json['gender']?.toString(),
      bio: json['bio']?.toString(),
      lastLogin: json['lastLogin']?.toString(),
      completionPercentage: (json['completionPercentage'] as num?)?.toInt() ?? 0,
      referralCode: json['referralCode']?.toString() ?? '',
      isVerified: json['isVerified'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'walletBalance': walletBalance,
      'streakCount': streakCount,
      'profilePhoto': profilePhoto,
      'profileImage': profileImage,
      'gender': gender,
      'bio': bio,
      'lastLogin': lastLogin,
      'completionPercentage': completionPercentage,
      'referralCode': referralCode,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }
}
