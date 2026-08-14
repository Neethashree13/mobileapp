class UserPreferencesEntity {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool promotionalAlerts;
  final bool orderUpdates;
  final bool deliveryAlerts;
  final String language;
  final List<String> dietary;
  final bool shareDataWithPartners;
  final bool personalizedAds;
  final bool locationTracking;

  const UserPreferencesEntity({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.promotionalAlerts = true,
    this.orderUpdates = true,
    this.deliveryAlerts = true,
    this.language = 'English (US)',
    this.dietary = const ['Vegetarian', 'Gluten-Free'],
    this.shareDataWithPartners = false,
    this.personalizedAds = true,
    this.locationTracking = true,
  });

  UserPreferencesEntity copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? promotionalAlerts,
    bool? orderUpdates,
    bool? deliveryAlerts,
    String? language,
    List<String>? dietary,
    bool? shareDataWithPartners,
    bool? personalizedAds,
    bool? locationTracking,
  }) {
    return UserPreferencesEntity(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      promotionalAlerts: promotionalAlerts ?? this.promotionalAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      deliveryAlerts: deliveryAlerts ?? this.deliveryAlerts,
      language: language ?? this.language,
      dietary: dietary ?? this.dietary,
      shareDataWithPartners: shareDataWithPartners ?? this.shareDataWithPartners,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      locationTracking: locationTracking ?? this.locationTracking,
    );
  }
}
