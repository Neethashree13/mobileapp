import '../../domain/entities/user_settings_entity.dart';

class UserSettingsModel extends UserSettingsEntity {
  const UserSettingsModel({
    bool isDarkMode = false,
    bool biometricsEnabled = true,
    int cacheSizeMb = 42,
  }) : super(
          isDarkMode: isDarkMode,
          biometricsEnabled: biometricsEnabled,
          cacheSizeMb: cacheSizeMb,
        );

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      biometricsEnabled: json['biometricsEnabled'] as bool? ?? true,
      cacheSizeMb: (json['cacheSizeMb'] as num?)?.toInt() ?? 42,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'biometricsEnabled': biometricsEnabled,
      'cacheSizeMb': cacheSizeMb,
    };
  }
}

