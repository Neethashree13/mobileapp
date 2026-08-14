import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shopping_providers.dart';
import '../../../profile/presentation/providers/user_profile_providers.dart';
import '../../../profile/domain/entities/user_preferences_entity.dart';
import '../../../profile/domain/entities/user_settings_entity.dart';
import '../../../../core/storage/secure_storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final List<String> _availableDietary = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Keto',
    'Nut-Free',
    'Dairy-Free',
    'Halal'
  ];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final prefsAsync = ref.watch(userPreferencesProvider);
    final shoppingSettings = ref.watch(settingsProvider);
    final isDark = shoppingSettings.isDarkMode;

    final settings = settingsAsync.asData?.value ?? const UserSettingsEntity();
    final preferences = prefsAsync.asData?.value ?? const UserPreferencesEntity();

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Visual Style & Theme
            _buildGroupTitle('VISUAL STYLE & THEME', isDark),
            _buildCardContainer([
              SwitchListTile.adaptive(
                title: const Text('Dark Mode Theme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Easy on the eyes for night shopping', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: settings.isDarkMode || shoppingSettings.isDarkMode,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleTheme();
                  ref.read(userSettingsProvider.notifier).updateSettings(settings.copyWith(isDarkMode: val));
                },
              ),
            ], isDark),
            const SizedBox(height: 16),

            // 2. Notification Preferences
            _buildGroupTitle('PUSH ALERTS & NOTIFICATIONS', isDark),
            _buildCardContainer([
              SwitchListTile.adaptive(
                title: const Text('Order Status & Delivery Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Get live rider tracking notifications', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: preferences.orderUpdates,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(orderUpdates: val));
                },
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SwitchListTile.adaptive(
                title: const Text('Promotional & Coupon Vouchers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Receive weekly discount alerts', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: preferences.promotionalAlerts,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(promotionalAlerts: val));
                },
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SwitchListTile.adaptive(
                title: const Text('SMS Text Messages', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('SMS notifications for order receipts', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: preferences.smsNotifications,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(smsNotifications: val));
                },
              ),
            ], isDark),
            const SizedBox(height: 16),

            // 3. Dietary Preferences Filter
            _buildGroupTitle('DIETARY PREFERENCES', isDark),
            _buildCardContainer([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected dietary tags filter AI recommendations & product listings:', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableDietary.map((diet) {
                        final isSelected = preferences.dietary.contains(diet);
                        return FilterChip(
                          label: Text(diet, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (val) {
                            final currentList = List<String>.from(preferences.dietary);
                            if (val) {
                              currentList.add(diet);
                            } else {
                              currentList.remove(diet);
                            }
                            ref.read(userPreferencesProvider.notifier).updatePreferences(
                                  preferences.copyWith(dietary: currentList),
                                );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ], isDark),
            const SizedBox(height: 16),

            // 4. Privacy & Data Settings
            _buildGroupTitle('PRIVACY & PERMISSIONS', isDark),
            _buildCardContainer([
              SwitchListTile.adaptive(
                title: const Text('Location Tracking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Allow location access for 10-min fast delivery', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: preferences.locationTracking,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(locationTracking: val));
                },
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              SwitchListTile.adaptive(
                title: const Text('Personalized Ads', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Show smart product offers based on interests', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: preferences.personalizedAds,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(personalizedAds: val));
                },
              ),
            ], isDark),
            const SizedBox(height: 16),

            // 5. Localization
            _buildGroupTitle('LOCALIZATION & LANGUAGE', isDark),
            _buildCardContainer([
              ListTile(
                title: const Text('App Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(preferences.language, style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => _showLanguageSelector(context, preferences),
              ),
            ], isDark),
            const SizedBox(height: 16),

            // 6. Security & Biometrics
            _buildGroupTitle('SECURITY LOCKS', isDark),
            _buildCardContainer([
              SwitchListTile.adaptive(
                title: const Text('Enable Biometric Authentication', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Require FaceID / TouchID for app access & payment', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                value: settings.biometricsEnabled,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  ref.read(userSettingsProvider.notifier).updateSettings(settings.copyWith(biometricsEnabled: val));
                },
              ),
            ], isDark),
            const SizedBox(height: 24),

            // 7. Danger Zone
            _buildGroupTitle('DANGER ZONE & ACCOUNT MANAGEMENT', isDark),
            _buildCardContainer([
              ListTile(
                leading: const Icon(Icons.pause_circle_outline_rounded, color: Colors.orangeAccent),
                title: const Text('Deactivate Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                subtitle: const Text('Temporarily pause your FlashCart account', style: TextStyle(fontSize: 11, color: Colors.grey)),
                onTap: () => _showDeactivateDialog(context),
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: const Text('Delete Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                subtitle: const Text('Permanently remove your profile and saved data', style: TextStyle(fontSize: 11, color: Colors.grey)),
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ], isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, UserPreferencesEntity preferences) {
    final languages = ['English (US)', 'Hindi (हिन्दी)', 'Kannada (ಕನ್ನಡ)', 'Tamil (தமிழ்)', 'Telugu (తెలుగు)', 'Spanish (Español)'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ...languages.map((lang) => ListTile(
                    title: Text(lang, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: preferences.language == lang ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)) : null,
                    onTap: () {
                      ref.read(userPreferencesProvider.notifier).updatePreferences(preferences.copyWith(language: lang));
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Account?'),
        content: const Text('Your profile will be deactivated temporarily. You can reactivate anytime by logging back in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userProfileRepositoryProvider).deactivateAccount();
              await SecureStorageService().clearTokens();
              if (mounted) {
                context.go('/login-options');
              }
            },
            child: const Text('DEACTIVATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account Permanently?'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone and all your points, wallet balance, and addresses will be wiped.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userProfileRepositoryProvider).deleteAccount();
              await SecureStorageService().clearTokens();
              if (mounted) {
                context.go('/login-options');
              }
            },
            child: const Text('DELETE PERMANENTLY', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
