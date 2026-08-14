class UserProfileEntity {
  final String id;
  final String firebaseUid;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final double walletBalance;
  final int streakCount;
  final String? profilePhoto;
  final String? profileImage;
  final String? gender;
  final String? bio;
  final String? lastLogin;
  final int completionPercentage;
  final String referralCode;
  final bool isVerified;
  final bool isActive;

  const UserProfileEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.walletBalance,
    required this.streakCount,
    this.profilePhoto,
    this.profileImage,
    this.gender,
    this.bio,
    this.lastLogin,
    this.completionPercentage = 0,
    this.referralCode = '',
    this.isVerified = true,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserProfileEntity copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    double? walletBalance,
    int? streakCount,
    String? profilePhoto,
    String? profileImage,
    String? gender,
    String? bio,
    String? lastLogin,
    int? completionPercentage,
    String? referralCode,
    bool? isVerified,
    bool? isActive,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      walletBalance: walletBalance ?? this.walletBalance,
      streakCount: streakCount ?? this.streakCount,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      lastLogin: lastLogin ?? this.lastLogin,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      referralCode: referralCode ?? this.referralCode,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}
