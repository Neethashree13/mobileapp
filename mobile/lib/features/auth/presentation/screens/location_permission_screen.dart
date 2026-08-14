// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flashcart_ai/core/widgets/custom_button.dart';
// import 'package:flashcart_ai/features/auth/presentation/providers/auth_provider.dart';
// import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';
// import 'package:flashcart_ai/features/profile/domain/entities/address_entity.dart';

// class LocationPermissionScreen extends ConsumerStatefulWidget {
//   const LocationPermissionScreen({super.key});

//   @override
//   ConsumerState<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
// }

// class _LocationPermissionScreenState extends ConsumerState<LocationPermissionScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//   bool _isLoading = false;
//   bool _permissionDenied = false;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: false);

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   /// Option A: Use Current Location (GPS + Reverse Geocoding)
//   Future<void> _handleUseCurrentLocation() async {
//     setState(() {
//       _isLoading = true;
//       _permissionDenied = false;
//     });

//     double lat = 12.9279;
//     double lng = 77.6250;

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (serviceEnabled) {
//         LocationPermission permission = await Geolocator.checkPermission();
//         if (permission == LocationPermission.denied) {
//           permission = await Geolocator.requestPermission();
//         }
//         if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
//           Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//             timeLimit: const Duration(seconds: 5),
//           );
//           lat = position.latitude;
//           lng = position.longitude;
//         }
//       }
//     } catch (_) {
//       // Geolocator unavailable or timeout in web environment, fallback to default coords
//     }

//     try {
//       // Fetch geocoded address via backend API
//       final geocoded = await ref.read(userAddressesProvider.notifier).reverseGeocode(lat, lng);

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });

//         // Open address form with geocoded values populated for user review & edit
//         _showAddressFormModal(
//           context,
//           initialAddress: geocoded,
//           isFromGps: true,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _permissionDenied = true;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Location permission denied or unavailable. Location access helps provide accurate 10-minute delivery.',
//             ),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }

//   /// Option B: Enter Address Manually
//   void _handleEnterAddressManually() {
//     _showAddressFormModal(context, isFromGps: false);
//   }

//   /// Bottom Sheet Address Form
//   void _showAddressFormModal(
//     BuildContext context, {
//     AddressEntity? initialAddress,
//     bool isFromGps = false,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Theme.of(context).brightness == Brightness.dark
//           ? const Color(0xFF1E293B)
//           : Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return _AddressFormBottomSheet(
//           initialAddress: initialAddress,
//           isFromGps: isFromGps,
//         onSave: (AddressEntity newAddress) async {
//   try {
//     debugPrint('========== SAVING ADDRESS ==========');
//     debugPrint('Address ID: ${newAddress.id}');
//     debugPrint('City: ${newAddress.city}');
//     debugPrint('State: ${newAddress.state}');
//     debugPrint('PIN: ${newAddress.postalCode}');
//     debugPrint('Latitude: ${newAddress.latitude}');
//     debugPrint('Longitude: ${newAddress.longitude}');

//     await ref
//         .read(userAddressesProvider.notifier)
//         .addAddress(newAddress);

//     debugPrint('========== ADDRESS SAVE SUCCESS ==========');

//     if (mounted) {
//       Navigator.of(context).pop();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Delivery address saved! Showing products available for ${newAddress.city}, ${newAddress.postalCode}.',
//           ),
//           backgroundColor: const Color(0xFF10B981),
//           duration: const Duration(seconds: 3),
//         ),
//       );

//       context.go('/home');
//     }

//     return true;
//   } catch (e, stackTrace) {
//     debugPrint('========== ADDRESS SAVE FAILED ==========');
//     debugPrint('ERROR: $e');
//     debugPrint('STACK TRACE: $stackTrace');

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save address: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }

//     return false;
//   }
// },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'First-Time Setup',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 480),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Animated GPS Ripple Icon
//                   Center(
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             return Container(
//                               width: 130 * _pulseAnimation.value,
//                               height: 130 * _pulseAnimation.value,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: theme.primaryColor.withOpacity(0.12 * (2.0 - _pulseAnimation.value)),
//                               ),
//                             );
//                           },
//                         ),
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: theme.primaryColor.withOpacity(0.15),
//                             border: Border.all(
//                               color: theme.primaryColor.withOpacity(0.3),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.location_on_rounded,
//                               size: 52,
//                               color: theme.primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Prompt question
//                   Text(
//                     'How would you like to set your delivery address?',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: -0.5,
//                       height: 1.3,
//                       color: isDark ? Colors.white : const Color(0xFF111827),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Set your primary delivery address to unlock 10-minute dark store delivery, real-time inventory & local offers.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       height: 1.5,
//                       color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Location Permission Denied Warning Banner (if applicable)
//                   if (_permissionDenied) ...[
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.orange.withOpacity(0.3)),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: const [
//                               Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
//                               SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Location Permission Notice',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: Colors.orange,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Location access helps provide accurate sub-10 minute delivery. You can retry permission or manually type your full address below.',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // Option A: Use Current Location Card
//                   InkWell(
//                     onTap: _isLoading ? null : _handleUseCurrentLocation,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: const Color(0xFF10B981).withOpacity(0.5),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF10B981).withOpacity(0.15),
//                               shape: BoxShape.circle,
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Color(0xFF10B981),
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons.my_location_rounded,
//                                     color: Color(0xFF10B981),
//                                     size: 26,
//                                   ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Option A – Use Current Location',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF10B981),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Fetch GPS location & reverse geocode address automatically',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Icon(Icons.chevron_right_rounded, color: Color(0xFF10B981)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Option B: Enter Address Manually Card
//                   InkWell(
//                     onTap: _handleEnterAddressManually,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.edit_location_alt_rounded,
//                               color: isDark ? Colors.white : Colors.black87,
//                               size: 26,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Option B – Enter Address Manually',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                     color: isDark ? Colors.white : const Color(0xFF111827),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Fill in house number, street, landmark & PIN code',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.chevron_right_rounded,
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Address Form Bottom Sheet Widget (Supports both GPS Review & Manual Entry)
// class _AddressFormBottomSheet extends ConsumerStatefulWidget {
//   final AddressEntity? initialAddress;
//   final bool isFromGps;
//   final Future<bool> Function(AddressEntity address) onSave;

//   const _AddressFormBottomSheet({
//     this.initialAddress,
//     required this.isFromGps,
//     required this.onSave,
//   });

//   @override
//   ConsumerState<_AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
// }

// class _AddressFormBottomSheetState extends ConsumerState<_AddressFormBottomSheet> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController _fullNameController;
//   late TextEditingController _mobileController;
//   late TextEditingController _houseNoController;
//   late TextEditingController _streetController;
//   late TextEditingController _landmarkController;
//   late TextEditingController _cityController;
//   late TextEditingController _stateController;
//   late TextEditingController _pinCodeController;

//   AddressType _addressType = AddressType.home;
//   bool _isDefault = true;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     final init = widget.initialAddress;
//     final authState = ref.read(authProvider);
//     final user = authState.user;

//     // Resolve name
//     String nameVal = '';
//     if (init != null &&
//         init.title.isNotEmpty &&
//         !['Home', 'Work', 'Other', 'Current Location', 'Pinned Location'].contains(init.title)) {
//       nameVal = init.title;
//     } else if (user != null) {
//       nameVal = user.displayName;
//     }

//     // Resolve phone
//     String phoneVal = user?.phone ?? '';

//     // Resolve House / Flat No - leave empty if not specified by reverse geocode
//     String houseVal = init?.houseNo ?? '';

//     // Resolve Street / Area - remove raw GPS strings if present
//     String streetVal = init?.street ?? init?.addressLine1 ?? '';
//     if (streetVal.toLowerCase().contains('lat:') || streetVal.toLowerCase().contains('lng:') || streetVal.toLowerCase().contains('long:')) {
//       streetVal = '';
//     }

//     // Resolve Landmark
//     String landmarkVal = init?.landmark ?? init?.addressLine2 ?? '';

//     _fullNameController = TextEditingController(text: nameVal);
//     _mobileController = TextEditingController(text: phoneVal);
//     _houseNoController = TextEditingController(text: houseVal);
//     _streetController = TextEditingController(text: streetVal);
//     _landmarkController = TextEditingController(text: landmarkVal);
//     _cityController = TextEditingController(text: init?.city ?? 'Bengaluru');
//     _stateController = TextEditingController(text: init?.state ?? 'Karnataka');
//     _pinCodeController = TextEditingController(text: init?.postalCode ?? '560102');

//     if (init != null) {
//       _addressType = init.type;
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _mobileController.dispose();
//     _houseNoController.dispose();
//     _streetController.dispose();
//     _landmarkController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pinCodeController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate() || _isSaving) {
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     final newAddress = AddressEntity(
//       id: widget.initialAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
//       title: _addressType == AddressType.home
//           ? 'Home'
//           : (_addressType == AddressType.work ? 'Work' : 'Other'),
//       addressLine1: '${_houseNoController.text.trim()}, ${_streetController.text.trim()}',
//       addressLine2: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
//       houseNo: _houseNoController.text.trim(),
//       street: _streetController.text.trim(),
//       landmark: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
//       city: _cityController.text.trim(),
//       state: _stateController.text.trim(),
//       postalCode: _pinCodeController.text.trim(),
//       country: 'India',
//       latitude: widget.initialAddress?.latitude ?? 12.9279,
//       longitude: widget.initialAddress?.longitude ?? 77.6250,
//       isDefault: _isDefault,
//     );

//     final success = await widget.onSave(newAddress);
//     if (mounted && !success) {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Padding(
//       padding: EdgeInsets.only(
//         top: 20,
//         left: 20,
//         right: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Bottom sheet handle bar
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.isFromGps ? 'Review Geocoded Location' : 'Enter Delivery Address',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   )
//                 ],
//               ),
//               Text(
//                 widget.isFromGps
//                     ? 'Current GPS coordinates fetched. Please review and complete your address.'
//                     : 'Provide complete details for instant 10-minute dark store delivery.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Full Name & Phone
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _fullNameController,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'Full Name *',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _mobileController,
//                       keyboardType: TextInputType.phone,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'Mobile Number *',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // House / Flat Number & Street
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _houseNoController,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'House / Flat No *',
//                         hintText: 'e.g. 506, Tower B',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter house/flat no' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     flex: 2,
//                     child: TextFormField(
//                       controller: _streetController,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'Street / Area *',
//                         hintText: 'e.g. 80 Feet Road, Koramangala',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter street/area' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Landmark (Optional)
//               TextFormField(
//                 controller: _landmarkController,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                 decoration: InputDecoration(
//                   labelText: 'Landmark (Optional)',
//                   hintText: 'e.g. Near Metro Station',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // City, State, PIN Code
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _cityController,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'City *',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _stateController,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'State *',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _pinCodeController,
//                       keyboardType: TextInputType.number,
//                       style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
//                       decoration: InputDecoration(
//                         labelText: 'PIN Code *',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Address Type Selector (Home, Work, Other)
//               Text(
//                 'Address Tag',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.grey[300] : Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   _buildTypeChip('Home', AddressType.home, Icons.home_rounded),
//                   const SizedBox(width: 8),
//                   _buildTypeChip('Work', AddressType.work, Icons.business_rounded),
//                   const SizedBox(width: 8),
//                   _buildTypeChip('Other', AddressType.other, Icons.location_on_rounded),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Set as default checkbox
//               CheckboxListTile(
//                 contentPadding: EdgeInsets.zero,
//                 value: _isDefault,
//                 activeColor: const Color(0xFF10B981),
//                 title: Text(
//                   'Set as Default Delivery Address',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: isDark ? Colors.white : Colors.black,
//                   ),
//                 ),
//                 onChanged: (val) {
//                   setState(() {
//                     _isDefault = val ?? true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Save button
//               CustomButton(
//                 text: 'Save Address & Continue',
//                 isLoading: _isSaving,
//                 onPressed: _submitForm,
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTypeChip(String label, AddressType type, IconData icon) {
//     final isSelected = _addressType == type;
//     return ChoiceChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: isSelected ? Colors.white : const Color(0xFF10B981),
//           ),
//           const SizedBox(width: 6),
//           Text(label),
//         ],
//       ),
//       selected: isSelected,
//       selectedColor: const Color(0xFF10B981),
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.white : const Color(0xFF10B981),
//         fontWeight: FontWeight.bold,
//         fontSize: 12,
//       ),
//       onSelected: (selected) {
//         if (selected) {
//           setState(() {
//             _addressType = type;
//           });
//         }
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flashcart_ai/core/widgets/custom_button.dart';
import 'package:flashcart_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';
import 'package:flashcart_ai/features/profile/domain/entities/address_entity.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends ConsumerState<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Option A: Use Current Location (GPS + Reverse Geocoding)
  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    double lat = 12.9279;
    double lng = 77.6250;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Enable Location Services'),
              content: const Text('Device location is turned off. Please enable location services/GPS to detect your current delivery address.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Geolocator.openLocationSettings();
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Turn On Location'),
                ),
              ],
            ),
          );
          if (shouldOpen == true) {
            await Future.delayed(const Duration(seconds: 1));
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
          }
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text('Location permission is permanently denied. Please grant location permissions in App Settings to auto-detect your location.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {
      // Geolocator timeout or fallback to default coordinates
    }

    try {
      // Fetch geocoded address via backend API
      final geocoded = await ref.read(userAddressesProvider.notifier).reverseGeocode(lat, lng);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Open address form with geocoded values populated for user review & edit
        _showAddressFormModal(
          context,
          initialAddress: geocoded,
          isFromGps: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied or unavailable. Location access helps provide accurate 10-minute delivery.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Option B: Enter Address Manually
  void _handleEnterAddressManually() {
    _showAddressFormModal(context, isFromGps: false);
  }

  /// Bottom Sheet Address Form
  void _showAddressFormModal(
    BuildContext context, {
    AddressEntity? initialAddress,
    bool isFromGps = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _AddressFormBottomSheet(
          initialAddress: initialAddress,
          isFromGps: isFromGps,
          onSave: (AddressEntity newAddress) async {
            // Save address to local storage/backend database via provider
            try {
              await ref.read(userAddressesProvider.notifier).addAddress(newAddress);
            } catch (_) {}

            if (mounted) {
              Navigator.of(context).pop(); // Close bottom sheet after saving

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Delivery address saved! Showing products available for ${newAddress.city}, ${newAddress.postalCode}.',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  duration: const Duration(seconds: 3),
                ),
              );

              // Navigate directly to Home Screen after address saved
              context.go('/home');
              return true;
            }
            return false;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'First-Time Setup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated GPS Ripple Icon
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 130 * _pulseAnimation.value,
                              height: 130 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.12 * (2.0 - _pulseAnimation.value)),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withOpacity(0.15),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 52,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Prompt question
                  Text(
                    'How would you like to set your delivery address?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.3,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set your primary delivery address to unlock 10-minute dark store delivery, real-time inventory & local offers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location Permission Denied Warning Banner (if applicable)
                  if (_permissionDenied) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Location Permission Notice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Location access helps provide accurate sub-10 minute delivery. You can retry permission or manually type your full address below.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Option A: Use Current Location Card
                  InkWell(
                    onTap: _isLoading ? null : _handleUseCurrentLocation,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF10B981),
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    color: Color(0xFF10B981),
                                    size: 26,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Option A – Use Current Location',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fetch GPS location & reverse geocode address automatically',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option B: Enter Address Manually Card
                  InkWell(
                    onTap: _handleEnterAddressManually,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_location_alt_rounded,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Option B – Enter Address Manually',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fill in house number, street, landmark & PIN code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Address Form Bottom Sheet Widget (Supports both GPS Review & Manual Entry)
class _AddressFormBottomSheet extends ConsumerStatefulWidget {
  final AddressEntity? initialAddress;
  final bool isFromGps;
  final Future<bool> Function(AddressEntity address) onSave;

  const _AddressFormBottomSheet({
    this.initialAddress,
    required this.isFromGps,
    required this.onSave,
  });

  @override
  ConsumerState<_AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState extends ConsumerState<_AddressFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  late TextEditingController _houseNoController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;

  AddressType _addressType = AddressType.home;
  bool _isDefault = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialAddress;
    final authState = ref.read(authProvider);
    final user = authState.user;

    // Resolve name
    String nameVal = '';
    if (init != null &&
        init.title.isNotEmpty &&
        !['Home', 'Work', 'Other', 'Current Location', 'Pinned Location'].contains(init.title)) {
      nameVal = init.title;
    } else if (user != null) {
      nameVal = user.displayName;
    }

    // Resolve phone
    String phoneVal = user?.phone ?? '';

    // Resolve House / Flat No - leave empty if not specified by reverse geocode
    String houseVal = init?.houseNo ?? '';

    // Resolve Street / Area - remove raw GPS strings if present
    String streetVal = init?.street ?? init?.addressLine1 ?? '';
    if (streetVal.toLowerCase().contains('lat:') || streetVal.toLowerCase().contains('lng:') || streetVal.toLowerCase().contains('long:')) {
      streetVal = '';
    }

    // Resolve Landmark
    String landmarkVal = init?.landmark ?? init?.addressLine2 ?? '';

    _fullNameController = TextEditingController(text: nameVal);
    _mobileController = TextEditingController(text: phoneVal);
    _houseNoController = TextEditingController(text: houseVal);
    _streetController = TextEditingController(text: streetVal);
    _landmarkController = TextEditingController(text: landmarkVal);
    _cityController = TextEditingController(text: init?.city ?? 'Bengaluru');
    _stateController = TextEditingController(text: init?.state ?? 'Karnataka');
    _pinCodeController = TextEditingController(text: init?.postalCode ?? '560102');

    if (init != null) {
      _addressType = init.type;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newAddress = AddressEntity(
      id: widget.initialAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      title: _addressType == AddressType.home
          ? 'Home'
          : (_addressType == AddressType.work ? 'Work' : 'Other'),
      addressLine1: '${_houseNoController.text.trim()}, ${_streetController.text.trim()}',
      addressLine2: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
      houseNo: _houseNoController.text.trim(),
      street: _streetController.text.trim(),
      landmark: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _pinCodeController.text.trim(),
      country: 'India',
      latitude: widget.initialAddress?.latitude ?? 12.9279,
      longitude: widget.initialAddress?.longitude ?? 77.6250,
      isDefault: _isDefault,
    );

    final success = await widget.onSave(newAddress);
    if (mounted && !success) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isFromGps ? 'Review Geocoded Location' : 'Enter Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              Text(
                widget.isFromGps
                    ? 'Current GPS coordinates fetched. Please review and complete your address.'
                    : 'Provide complete details for instant 10-minute dark store delivery.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              // Full Name & Phone
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fullNameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // House / Flat Number & Street
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _houseNoController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'House / Flat No *',
                        hintText: 'e.g. 506, Tower B',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter house/flat no' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Street / Area *',
                        hintText: 'e.g. 80 Feet Road, Koramangala',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter street/area' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Landmark (Optional)
              TextFormField(
                controller: _landmarkController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Landmark (Optional)',
                  hintText: 'e.g. Near Metro Station',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // City, State, PIN Code
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'City *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'State *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _pinCodeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'PIN Code *',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address Type Selector (Home, Work, Other)
              Text(
                'Address Tag',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('Home', AddressType.home, Icons.home_rounded),
                  const SizedBox(width: 8),
                  _buildTypeChip('Work', AddressType.work, Icons.business_rounded),
                  const SizedBox(width: 8),
                  _buildTypeChip('Other', AddressType.other, Icons.location_on_rounded),
                ],
              ),
              const SizedBox(height: 12),

              // Set as default checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                activeColor: const Color(0xFF10B981),
                title: Text(
                  'Set as Default Delivery Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _isDefault = val ?? true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Save button
              CustomButton(
                text: 'Save Address & Continue',
                isLoading: _isSaving,
                onPressed: _submitForm,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, AddressType type, IconData icon) {
    final isSelected = _addressType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF10B981),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF10B981),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _addressType = type;
          });
        }
      },
    );
  }
}
