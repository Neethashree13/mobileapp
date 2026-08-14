import '../../domain/entities/user_preferences_entity.dart';

class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({
    bool emailNotifications = true,
    bool pushNotifications = true,
    bool smsNotifications = false,
    bool promotionalAlerts = true,
    bool orderUpdates = true,
    bool deliveryAlerts = true,
    String language = 'English (US)',
    List<String> dietary = const ['Vegetarian', 'Gluten-Free'],
    bool shareDataWithPartners = false,
    bool personalizedAds = true,
    bool locationTracking = true,
  }) : super(
          emailNotifications: emailNotifications,
          pushNotifications: pushNotifications,
          smsNotifications: smsNotifications,
          promotionalAlerts: promotionalAlerts,
          orderUpdates: orderUpdates,
          deliveryAlerts: deliveryAlerts,
          language: language,
          dietary: dietary,
          shareDataWithPartners: shareDataWithPartners,
          personalizedAds: personalizedAds,
          locationTracking: locationTracking,
        );

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      promotionalAlerts: json['promotionalAlerts'] ?? true,
      orderUpdates: json['orderUpdates'] ?? true,
      deliveryAlerts: json['deliveryAlerts'] ?? true,
      language: json['language']?.toString() ?? 'English (US)',
      dietary: json['dietary'] != null ? List<String>.from(json['dietary']) : const ['Vegetarian', 'Gluten-Free'],
      shareDataWithPartners: json['shareDataWithPartners'] ?? false,
      personalizedAds: json['personalizedAds'] ?? true,
      locationTracking: json['locationTracking'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'promotionalAlerts': promotionalAlerts,
      'orderUpdates': orderUpdates,
      'deliveryAlerts': deliveryAlerts,
      'language': language,
      'dietary': dietary,
      'shareDataWithPartners': shareDataWithPartners,
      'personalizedAds': personalizedAds,
      'locationTracking': locationTracking,
    };
  }
}


