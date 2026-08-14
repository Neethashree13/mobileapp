// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';
// import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';
// import 'package:flashcart_ai/features/profile/domain/entities/user_profile_entity.dart';

// class UserProfileScreen extends ConsumerStatefulWidget {
//   const UserProfileScreen({super.key});

//   @override
//   ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
//   bool _isEditing = false;
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _bioController;

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController();
//     _lastNameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _bioController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   void _populateControllers(UserProfileEntity profile) {
//     if (!_isEditing) {
//       _firstNameController.text = profile.firstName;
//       _lastNameController.text = profile.lastName;
//       _emailController.text = profile.email;
//       _phoneController.text = profile.phoneNumber;
//       _bioController.text = profile.bio ?? 'FlashCart AI Customer';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileState = ref.watch(userProfileProvider);
//     final settingsState = ref.watch(settingsProvider);
//     final isDark = settingsState.isDarkMode;
//     final orders = ref.watch(ordersProvider);
//     final wishlist = ref.watch(wishlistProvider);

//     final profile = profileState.profile;

//     if (profile != null) {
//       _populateControllers(profile);
//     }

//     return Theme(
//       data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
//         appBar: AppBar(
//           title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
//           elevation: 0,
//           actions: [
//             if (profileState.isLoading)
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
//                 ),
//               )
//             else
//               IconButton(
//                 icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, color: const Color(0xFF10B981)),
//                 onPressed: () async {
//                   if (_isEditing) {
//                     final success = await ref.read(userProfileProvider.notifier).updateProfile(
//                       firstName: _firstNameController.text.trim(),
//                       lastName: _lastNameController.text.trim(),
//                       phoneNumber: _phoneController.text.trim(),
//                       bio: _bioController.text.trim(),
//                     );
//                     if (mounted) {
//                       setState(() => _isEditing = false);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(success ? 'Profile updated successfully!' : 'Failed to update profile'),
//                           backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
//                         ),
//                       );
//                     }
//                   } else {
//                     setState(() => _isEditing = true);
//                   }
//                 },
//               )
//           ],
//         ),
//         body: RefreshIndicator(
//           onRefresh: () => ref.read(userProfileProvider.notifier).loadProfile(),
//           color: const Color(0xFF10B981),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // 1. Profile Header & Photo
//                 if (profile != null) ...[
//                   _buildProfileHeader(profile, isDark),
//                   const SizedBox(height: 16),

//                   // 2. Completion Progress Bar
//                   _buildCompletionBanner(profile.completionPercentage, isDark),
//                   const SizedBox(height: 24),

//                   // 3. Metrics Row
//                   _buildMetricsRow(orders.length, wishlist.length, profile.walletBalance, profile.streakCount, isDark),
//                   const SizedBox(height: 24),

//                   // 4. Info Fields Form
//                   _buildSectionTitle('PERSONAL DETAILS', isDark),
//                   _buildAccountDetailsForm(profile, isDark),
//                   const SizedBox(height: 24),
//                 ],

//                 // 5. Navigation Hub
//                 _buildSectionTitle('ACCOUNT HUB & SETTINGS', isDark),
//                 _buildNavigationHub(context, isDark, profile?.referralCode),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey[500],
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader(UserProfileEntity profile, bool isDark) {
//     final photoUrl = profile.profilePhoto ?? profile.profileImage;
//     return Column(
//       children: [
//         Stack(
//           children: [
//             CircleAvatar(
//               radius: 54,
//               backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
//               backgroundImage: (photoUrl != null && photoUrl.startsWith('http')) ? NetworkImage(photoUrl) : null,
//               child: (photoUrl == null || !photoUrl.startsWith('http'))
//                   ? Text(
//                       profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '👤',
//                       style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
//                     )
//                   : null,
//             ),
//             Positioned(
//               bottom: 4,
//               right: 4,
//               child: GestureDetector(
//                 onTap: () => _showPhotoUploadDialog(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
//                   child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
//                 ),
//               ),
//             )
//           ],
//         ),
//         const SizedBox(height: 12),
//         Text(
//           profile.fullName.isNotEmpty ? profile.fullName : 'Arav Sharma',
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           profile.email,
//           style: TextStyle(color: Colors.grey[400], fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompletionBanner(int percentage, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Profile Completion',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '$percentage%',
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               value: percentage / 100.0,
//               minHeight: 8,
//               backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
//               color: const Color(0xFF10B981),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricsRow(int totalOrders, int wishlistItems, double balance, int streak, bool isDark) {
//     return Row(
//       children: [
//         _buildMetricItem('$totalOrders', 'Orders', isDark),
//         const SizedBox(width: 8),
//         _buildMetricItem('$wishlistItems', 'Wishlist', isDark),
//         const SizedBox(width: 8),
//         _buildMetricItem('₹${balance.toStringAsFixed(0)}', 'Wallet', isDark, color: Colors.blueAccent),
//         const SizedBox(width: 8),
//         _buildMetricItem('🔥 $streak', 'Streak', isDark, color: Colors.orangeAccent),
//       ],
//     );
//   }

//   Widget _buildMetricItem(String val, String label, bool isDark, {Color? color}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1E293B) : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
//         ),
//         child: Column(
//           children: [
//             Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? const Color(0xFF10B981))),
//             const SizedBox(height: 4),
//             Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAccountDetailsForm(UserProfileEntity profile, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _firstNameController,
//                   enabled: _isEditing,
//                   style: const TextStyle(fontSize: 13),
//                   decoration: const InputDecoration(labelText: 'First Name', border: UnderlineInputBorder()),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextField(
//                   controller: _lastNameController,
//                   enabled: _isEditing,
//                   style: const TextStyle(fontSize: 13),
//                   decoration: const InputDecoration(labelText: 'Last Name', border: UnderlineInputBorder()),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _emailController,
//             enabled: false,
//             style: const TextStyle(fontSize: 13),
//             decoration: const InputDecoration(labelText: 'Email Address (Verified)', border: UnderlineInputBorder()),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _phoneController,
//             enabled: _isEditing,
//             style: const TextStyle(fontSize: 13),
//             decoration: const InputDecoration(labelText: 'Phone Number', border: UnderlineInputBorder()),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _bioController,
//             enabled: _isEditing,
//             style: const TextStyle(fontSize: 13),
//             decoration: const InputDecoration(labelText: 'Bio / Note', border: UnderlineInputBorder()),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationHub(BuildContext context, bool isDark, String? referralCode) {
//     final links = [
//       {'title': 'Manage Saved Addresses', 'icon': Icons.room_rounded, 'color': Colors.orangeAccent, 'route': '/address-management'},
//       {'title': 'Refer & Earn Rewards', 'icon': Icons.card_giftcard_rounded, 'color': Colors.purpleAccent, 'route': '/referral-info'},
//       {'title': 'Activity History Logs', 'icon': Icons.history_rounded, 'color': Colors.teal, 'route': '/activity-history'},
//       {'title': 'My Order History', 'icon': Icons.assignment_rounded, 'color': const Color(0xFF10B981), 'route': '/orders'},
//       {'title': 'Wishlist Basket', 'icon': Icons.favorite_rounded, 'color': Colors.redAccent, 'route': '/wishlist'},
//       {'title': 'Flash Wallet Balance', 'icon': Icons.wallet_rounded, 'color': Colors.blueAccent, 'route': '/wallet'},
//       {'title': 'Preferences & Settings', 'icon': Icons.settings_rounded, 'color': Colors.grey, 'route': '/settings'},
//       {'title': 'AI Help Desk Support', 'icon': Icons.headset_mic_rounded, 'color': Colors.amber, 'route': '/help-center'},
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
//       ),
//       child: Column(
//         children: links.map((link) {
//           final color = link['color'] as Color;
//           return ListTile(
//             leading: Icon(link['icon'] as IconData, color: color, size: 20),
//             title: Text(link['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
//             trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
//             onTap: () {
//               context.push(link['route'] as String);
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }

//   void _showPhotoUploadDialog(BuildContext context) {
//     final photoController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Update Profile Photo'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Enter Image URL to set as profile photo:'),
//             const SizedBox(height: 12),
//             TextField(
//               controller: photoController,
//               decoration: const InputDecoration(
//                 hintText: 'https://images.unsplash.com/...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('CANCEL'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
//             onPressed: () async {
//               final url = photoController.text.trim();
//               if (url.isNotEmpty) {
//                 Navigator.pop(ctx);
//                 final success = await ref.read(userProfileProvider.notifier).uploadPhoto(url);
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(success ? 'Photo updated!' : 'Failed to update photo'),
//                       backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
//                     ),
//                   );
//                 }
//               }
//             },
//             child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';
import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';
import 'package:flashcart_ai/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfileEntity profile) {
  if (!_isEditing) {
    _firstNameController.text =
        profile.firstName.isNotEmpty ? profile.firstName : "";

    _lastNameController.text =
        profile.lastName.isNotEmpty ? profile.lastName : "";

    _emailController.text =
        profile.email.isNotEmpty ? profile.email : "";

    _phoneController.text =
        profile.phoneNumber.isNotEmpty ? profile.phoneNumber : "";

    _bioController.text = profile.bio ?? "";
  }
}

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final settingsState = ref.watch(settingsProvider);
    final isDark = settingsState.isDarkMode;
    final orders = ref.watch(ordersProvider);
    final wishlist = ref.watch(wishlistProvider);

    final profile = profileState.profile;

    if (profile != null) {
      _populateControllers(profile);
    }

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            if (profileState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                ),
              )
            else
              IconButton(
                icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, color: const Color(0xFF10B981)),
                onPressed: () async {
                  if (_isEditing) {
                    final success = await ref.read(userProfileProvider.notifier).updateProfile(
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      bio: _bioController.text.trim(),
                    );
                    if (mounted) {
                      setState(() => _isEditing = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Profile updated successfully!' : 'Failed to update profile'),
                          backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                        ),
                      );
                    }
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(userProfileProvider.notifier).loadProfile(),
          color: const Color(0xFF10B981),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Header & Photo
                if (profile != null) ...[
                  _buildProfileHeader(profile, isDark),
                  const SizedBox(height: 16),

                  // 2. Completion Progress Bar
                  _buildCompletionBanner(profile.completionPercentage, isDark),
                  const SizedBox(height: 24),

                  // 3. Metrics Row
                  _buildMetricsRow(orders.length, wishlist.length, profile.walletBalance, profile.streakCount, isDark),
                  const SizedBox(height: 24),

                  // 4. Info Fields Form
                  _buildSectionTitle('PERSONAL DETAILS', isDark),
                  _buildAccountDetailsForm(profile, isDark),
                  const SizedBox(height: 24),
                ],

                // 5. Navigation Hub
                _buildSectionTitle('ACCOUNT HUB & SETTINGS', isDark),
                _buildNavigationHub(context, isDark, profile?.referralCode),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
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

  Widget _buildProfileHeader(UserProfileEntity profile, bool isDark) {
    final photoUrl = profile.profilePhoto ?? profile.profileImage;
    
   String rawName = profile.fullName.trim();

if (rawName.contains('FBAUTH_UID') ||
    rawName.toLowerCase().startsWith('u_')) {
  rawName = '';
}
    
   String rawEmail = profile.email.isNotEmpty
    ? profile.email
    : 'No email available';

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
              backgroundImage: (photoUrl != null && photoUrl.startsWith('http')) ? NetworkImage(photoUrl) : null,
              child: (photoUrl == null || !photoUrl.startsWith('http'))
                  ? Text(
                      rawName.isNotEmpty ? rawName[0].toUpperCase() : 'N',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    )
                  : null,
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showPhotoUploadDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(
          rawName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          rawEmail,
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCompletionBanner(int percentage, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(int totalOrders, int wishlistItems, double balance, int streak, bool isDark) {
    return Row(
      children: [
        _buildMetricItem('$totalOrders', 'Orders', isDark),
        const SizedBox(width: 8),
        _buildMetricItem('$wishlistItems', 'Wishlist', isDark),
        const SizedBox(width: 8),
        _buildMetricItem('₹${balance.toStringAsFixed(0)}', 'Wallet', isDark, color: Colors.blueAccent),
        const SizedBox(width: 8),
        _buildMetricItem('🔥 $streak', 'Streak', isDark, color: Colors.orangeAccent),
      ],
    );
  }

  Widget _buildMetricItem(String val, String label, bool isDark, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? const Color(0xFF10B981))),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsForm(UserProfileEntity profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  enabled: _isEditing,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'First Name', border: UnderlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  enabled: _isEditing,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Last Name', border: UnderlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            enabled: false,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Email Address (Verified)', border: UnderlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            enabled: _isEditing,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Phone Number', border: UnderlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            enabled: _isEditing,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Bio / Note', border: UnderlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHub(BuildContext context, bool isDark, String? referralCode) {
    final links = [
      {'title': 'Manage Saved Addresses', 'icon': Icons.room_rounded, 'color': Colors.orangeAccent, 'route': '/address-management'},
      {'title': 'Refer & Earn Rewards', 'icon': Icons.card_giftcard_rounded, 'color': Colors.purpleAccent, 'route': '/referral-info'},
      {'title': 'Activity History Logs', 'icon': Icons.history_rounded, 'color': Colors.teal, 'route': '/activity-history'},
      {'title': 'My Order History', 'icon': Icons.assignment_rounded, 'color': const Color(0xFF10B981), 'route': '/orders'},
      {'title': 'Wishlist Basket', 'icon': Icons.favorite_rounded, 'color': Colors.redAccent, 'route': '/wishlist'},
      {'title': 'Flash Wallet Balance', 'icon': Icons.wallet_rounded, 'color': Colors.blueAccent, 'route': '/wallet'},
      {'title': 'Preferences & Settings', 'icon': Icons.settings_rounded, 'color': Colors.grey, 'route': '/settings'},
      {'title': 'AI Help Desk Support', 'icon': Icons.headset_mic_rounded, 'color': Colors.amber, 'route': '/help-center'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: links.map((link) {
          final color = link['color'] as Color;
          return ListTile(
            leading: Icon(link['icon'] as IconData, color: color, size: 20),
            title: Text(link['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              context.push(link['route'] as String);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPhotoUploadDialog(BuildContext context) {
    final photoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Profile Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Image URL to set as profile photo:'),
            const SizedBox(height: 12),
            TextField(
              controller: photoController,
              decoration: const InputDecoration(
                hintText: 'https://images.unsplash.com/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () async {
              final url = photoController.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ref.read(userProfileProvider.notifier).uploadPhoto(url);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Photo updated!' : 'Failed to update photo'),
                      backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
