/// Clean Domain User Entity for FlashCart AI Mobile
class UserEntity {
  final String id;
  final String email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? profilePhoto;
  final String? gender;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String authProvider;
  final double walletBalance;
  final int streakCount;

  UserEntity({
    required this.id,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.profilePhoto,
    this.gender,
    this.role = 'USER',
    this.isVerified = false,
    this.isActive = true,
    this.authProvider = 'LOCAL',
    this.walletBalance = 0.0,
    this.streakCount = 0,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return email.split('@').first;
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePhoto,
    String? gender,
    String? role,
    bool? isVerified,
    bool? isActive,
    String? authProvider,
    double? walletBalance,
    int? streakCount,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      authProvider: authProvider ?? this.authProvider,
      walletBalance: walletBalance ?? this.walletBalance,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}
