class UserSettingsEntity {
  final bool isDarkMode;
  final bool biometricsEnabled;
  final int cacheSizeMb;

  const UserSettingsEntity({
    this.isDarkMode = false,
    this.biometricsEnabled = true,
    this.cacheSizeMb = 42,
  });

  UserSettingsEntity copyWith({
    bool? isDarkMode,
    bool? biometricsEnabled,
    int? cacheSizeMb,
  }) {
    return UserSettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
    );
  }
}
