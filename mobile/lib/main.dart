// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flashcart_ai/features/auth/presentation/login_screen.dart';
// import 'package:flashcart_ai/features/customer/presentation/customer_home_screen.dart';
// import 'package:flashcart_ai/features/rider/presentation/rider_dashboard_screen.dart';

// // Firebase background message listener
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   try {
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp();
//     }
//     print("Background FCM message received: ${message.messageId}");
//   } catch (e) {
//     print("Error in background FCM handler: $e");
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Gracefully catch all unhandled asynchronous and platform-channel errors
//   PlatformDispatcher.instance.onError = (error, stack) {
//     print("⚠️ Handled background error gracefully: $error");
//     return true; // Mark as handled to prevent crashes or freezes
//   };
  
//   // Safe Firebase Client SDK bootstrap
//   // Initialize natively reading google-services.json / GoogleService-Info.plist
//   try {
//     await Firebase.initializeApp();
//     print("✅ Firebase initialized successfully using native configuration.");
//   } catch (e) {
//     print("⚠️ Firebase initialization failed: $e");
//   }

//   // Once Firebase is initialized, configure messaging
//   try {
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
//     final messaging = FirebaseMessaging.instance;
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   } catch (e) {
//     print("⚠️ Firebase Messaging failed to initialize: $e");
//   }

//   runApp(
//     const ProviderScope(
//       child: FlashCartApp(),
//     ),
//   );
// }

// class FlashCartApp extends StatelessWidget {
//   const FlashCartApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FlashCart AI',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: const Color(0xFF10B981), // Emerald green primary
//         scaffoldBackgroundColor: const Color(0xFF07080A),
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF10B981),
//           secondary: Color(0xFF3B82F6),
//           surface: Color(0xFF0F1115),
//           background: Color(0xFF07080A),
//         ),
//         fontFamily: 'Inter',
//         useMaterial3: true,
//       ),
//       home: const AppNavigationShell(),
//     );
//   }
// }

// class AppNavigationShell extends StatefulWidget {
//   const AppNavigationShell({super.key});

//   @override
//   State<AppNavigationShell> createState() => _AppNavigationShellState();
// }

// class _AppNavigationShellState extends State<AppNavigationShell> {
//   bool _showSplash = true;
//   bool _isLoggedIn = false;
//   String _activeRole = 'customer'; // 'customer' or 'rider'

//   @override
//   void initState() {
//     super.initState();
//     _checkSessionAndSplash();
//   }

//   Future<void> _checkSessionAndSplash() async {
//     // Check session persistence
//     try {
//       if (Firebase.apps.isNotEmpty) {
//         final currentUser = FirebaseAuth.instance.currentUser;
//         if (currentUser != null) {
//           setState(() {
//             _isLoggedIn = true;
//           });
//         }
//       }
//     } catch (e) {
//       print("⚠️ Session check error: $e");
//     }

//     // Delay for 2 seconds to show Splash logo/animations
//     await Future.delayed(const Duration(seconds: 2));
//     if (mounted) {
//       setState(() {
//         _showSplash = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_showSplash) {
//       return Scaffold(
//         backgroundColor: const Color(0xFF07080A),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Splash Logo & Animation
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0F1115),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2), width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF10B981).withOpacity(0.15),
//                       blurRadius: 30,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.bolt,
//                   color: Color(0xFF10B981),
//                   size: 80,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'FLASHCART AI',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 4,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Sub-10 Minute Delivery • Green Logistics',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 48),
//               const SizedBox(
//                 width: 32,
//                 height: 32,
//                 child: CircularProgressIndicator(
//                   color: Color(0xFF10B981),
//                   strokeWidth: 2.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (!_isLoggedIn) {
//       return LoginScreen(
//         onLoginSuccess: () {
//           setState(() {
//             _isLoggedIn = true;
//           });
//         },
//       );
//     }

//     if (_activeRole == 'rider') {
//       return RiderDashboardScreen(
//         onSwitchToCustomer: () {
//           setState(() {
//             _activeRole = 'customer';
//           });
//         },
//         onLogout: () {
//           setState(() {
//             _isLoggedIn = false;
//             _activeRole = 'customer';
//           });
//         },
//       );
//     }

//     // Default: Customer Storefront
//     return CustomerHomeScreen(
//       onSwitchToRider: () {
//         setState(() {
//           _activeRole = 'rider';
//         });
//       },
//       onLogout: () {
//         setState(() {
//           _isLoggedIn = false;
//         });
//       },
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashcart_ai/core/theme/app_theme.dart';
import 'package:flashcart_ai/core/navigation/app_navigation.dart';

// Firebase background message listener
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    print("Background FCM message received: ${message.messageId}");
  } catch (e) {
    print("Error in background FCM handler: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Gracefully catch all unhandled asynchronous and platform-channel errors
  PlatformDispatcher.instance.onError = (error, stack) {
    print("⚠️ Handled background error gracefully: $error");
    return true; // Mark as handled to prevent crashes or freezes
  };
  
  // Safe Firebase Client SDK bootstrap
  // Initialize natively reading google-services.json / GoogleService-Info.plist
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully using native configuration.");
  } catch (e) {
    print("⚠️ Firebase initialization failed: $e");
  }

  // Once Firebase is initialized, configure messaging
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    print("⚠️ Firebase Messaging failed to initialize: $e");
  }

  runApp(
    const ProviderScope(
      child: FlashCartApp(),
    ),
  );
}

class FlashCartApp extends StatelessWidget {
  const FlashCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlashCart AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically load light or dark based on system setting
      routerConfig: AppNavigation.router,
    );
  }
}

