// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import 'package:flashcart_ai/features/auth/presentation/providers/auth_provider.dart';
// import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';

// import 'package:flashcart_ai/core/widgets/custom_text_field.dart';
// import 'package:flashcart_ai/core/widgets/custom_button.dart';

// class EmailLoginScreen extends ConsumerStatefulWidget {
//   const EmailLoginScreen({super.key});

//   @override
//   ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
// }

// class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedEmail();
//   }

//   Future<void> _loadSavedEmail() async {
//     final storage = ref.read(secureStorageProvider);
//     final savedEmail = await storage.readSavedEmail();
//     final remember = await storage.readRememberMe();
//     if (remember && savedEmail != null) {
//       if (mounted) {
//         setState(() {
//           _emailController.text = savedEmail;
//           _rememberMe = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//  Future<void> _submit() async {
//   ref.read(authProvider.notifier).clearMessages();

//   if (!_formKey.currentState!.validate()) {
//     return;
//   }

//   debugPrint('========== START LOGIN ==========');

//   final success = await ref.read(authProvider.notifier).loginWithEmail(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//         rememberMe: _rememberMe,
//       );

//   debugPrint('LOGIN SUCCESS: $success');

//   if (!success || !mounted) {
//     debugPrint('LOGIN FAILED OR SCREEN UNMOUNTED');
//     return;
//   }

//   debugPrint('========== LOGIN SUCCESS ==========');
//   debugPrint('Loading addresses...');

//   try {
//     await ref.read(userAddressesProvider.notifier).loadAddresses();

//     if (!mounted) return;

//     final addressState = ref.read(userAddressesProvider);

//     debugPrint('========== ADDRESS CHECK ==========');
//     debugPrint('Is Loading: ${addressState.isLoading}');
//     debugPrint('Address Count: ${addressState.addresses.length}');
//     debugPrint('Addresses: ${addressState.addresses}');
//     debugPrint('Address Error: ${addressState.error}');
//     debugPrint('===================================');

//     // If API returned an error, go to location screen.
//     // This allows a new user to continue setup.
//     if (addressState.error != null) {
//       debugPrint(
//         'ADDRESS API ERROR -> Opening Location Permission Screen',
//       );

//       context.go('/location-permission');
//       return;
//     }

//     // User already has an address.
//     if (addressState.addresses.isNotEmpty) {
//       debugPrint(
//         'NAVIGATION -> Existing address found -> HOME',
//       );

//       context.go('/home');
//       return;
//     }

//     // User has no address.
//     debugPrint(
//       'NAVIGATION -> No address found -> LOCATION PERMISSION',
//     );

//     context.go('/location-permission');
//   } catch (e, stackTrace) {
//     debugPrint('ADDRESS LOAD EXCEPTION: $e');
//     debugPrint('$stackTrace');

//     if (!mounted) return;

//     debugPrint(
//       'NAVIGATION -> Address check failed -> LOCATION PERMISSION',
//     );

//     context.go('/location-permission');
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final authState = ref.watch(authProvider);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_new,
//             color: isDark ? Colors.white : Colors.black,
//             size: 20,
//           ),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 450),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Welcome Back',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: -0.5,
//                         color: isDark ? Colors.white : const Color(0xFF111827),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Sign in with your email address and password to continue shopping with sub-10 min delivery.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         height: 1.5,
//                         color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Backend Error Message Display
//                     if (authState.errorMessage != null) ...[
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.red.withOpacity(0.3)),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.error_outline, color: Colors.red, size: 20),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 authState.errorMessage!,
//                                 style: const TextStyle(
//                                   color: Colors.red,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     CustomTextField(
//                       controller: _emailController,
//                       label: 'Email Address',
//                       hintText: 'alex@flashcart.ai',
//                       keyboardType: TextInputType.emailAddress,
//                       prefixIcon: Icon(Icons.email_outlined),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return 'Please enter your email address';
//                         }
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
//                           return 'Please enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     CustomTextField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       hintText: '••••••••••••',
//                       isPassword: true,
//                       prefixIcon: Icon(Icons.lock_outline),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (val.trim().length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _rememberMe,
//                               activeColor: theme.primaryColor,
//                               onChanged: (val) {
//                                 setState(() {
//                                   _rememberMe = val ?? false;
//                                 });
//                               },
//                             ),
//                             Text(
//                               'Remember Me',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
//                               ),
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () => context.push('/forgot-password'),
//                           child: Text(
//                             'Forgot Password?',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: theme.primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),
//                     CustomButton(
//                       text: 'Sign In',
//                       isLoading: authState.isLoading,
//                       onPressed: _submit,
//                     ),

//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have an account? ",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () => context.push('/register'),
//                           child: Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: theme.primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  String? _detectedEmail;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final storage = ref.read(secureStorageProvider);
    final savedEmail = await storage.readSavedEmail();
    final authState = ref.read(authProvider);
    final profileState = ref.read(userProfileProvider);

    String resolved = '';
    if (savedEmail != null && savedEmail.isNotEmpty) {
      resolved = savedEmail;
    } else if (authState.user?.email != null && authState.user!.email.isNotEmpty) {
      resolved = authState.user!.email;
    } else if (profileState.profile?.email != null && profileState.profile!.email.isNotEmpty) {
      resolved = profileState.profile!.email;
    } else {
     resolved = authState.user?.email ?? '';
    }

    if (mounted) {
      setState(() {
        _detectedEmail = resolved;
        _emailController.text = resolved;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    ref.read(authProvider.notifier).clearMessages();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          rememberMe: _rememberMe,
        );

    if (success && mounted) {
      // First Login Setup Check: Check if delivery address already exists
      await ref.read(userAddressesProvider.notifier).loadAddresses();
      final addresses = ref.read(userAddressesProvider).addresses;

      if (mounted) {
        if (addresses.isNotEmpty) {
          // Returning user: address already exists -> skip setup and go to Home
          context.go('/home');
        } else {
          // First time user / No address found -> go to address setup
          context.go('/location-permission');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with your email address and password to continue shopping with sub-10 min delivery.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_detectedEmail != null && _detectedEmail!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _emailController.text = _detectedEmail!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_circle_rounded, color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Active User Email Account:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    Text(
                                      _detectedEmail!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.touch_app_rounded, color: Color(0xFF10B981), size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      const SizedBox(height: 16),
                    ],

                    // Backend Error Message Display
                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'alex@flashcart.ai',
                      keyboardType: TextInputType.emailAddress,
                     prefixIcon: const Icon(Icons.email_outlined),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: '••••••••••••',
                      isPassword: true,
                     prefixIcon: const Icon(Icons.lock_outline),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: theme.primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Sign In',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
