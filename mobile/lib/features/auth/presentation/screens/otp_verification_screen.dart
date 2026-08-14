// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../core/widgets/otp_input.dart';
// import '../providers/auth_provider.dart';
// import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';

// class OtpVerificationScreen extends ConsumerStatefulWidget {
//   final String phoneNumber;

//   const OtpVerificationScreen({
//     super.key,
//     required this.phoneNumber,
//   });

//   @override
//   ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
//   String _otpCode = '';

//   void _verifyOtp() async {
//     ref.read(authProvider.notifier).clearMessages();

//     if (_otpCode.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the full 6-digit OTP code'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final success = await ref.read(authProvider.notifier).verifyOtp(
//           phone: widget.phoneNumber,
//           otp: _otpCode,
//           rememberMe: true,
//         );

//     if (success && mounted) {
//       final state = ref.read(authProvider);
//       if (state.isNewUser) {
//         context.go('/profile-setup');
//       } else {
//         await ref.read(userAddressesProvider.notifier).loadAddresses();
//         final addresses = ref.read(userAddressesProvider).addresses;
//         if (mounted) {
//           if (addresses.isNotEmpty) {
//             context.go('/home');
//           } else {
//             context.go('/location-permission');
//           }
//         }
//       }
//     }
//   }

//   void _resendOtp() async {
//     ref.read(authProvider.notifier).clearMessages();
//     await ref.read(authProvider.notifier).sendOtp(phone: widget.phoneNumber);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('New OTP code dispatched to ${widget.phoneNumber}'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

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
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Verify OTP Code',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: -0.5,
//                       color: isDark ? Colors.white : const Color(0xFF111827),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'We sent a 6-digit pin code to ${widget.phoneNumber}. Enter it below to verify.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       height: 1.5,
//                       color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Display Error
//                   if (authState.errorMessage != null) ...[
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.red.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.error_outline, color: Colors.red, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               authState.errorMessage!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // OTP Input Widget
//                   OtpInput(
//                     length: 6,
//                     onCompleted: (pin) {
//                       setState(() {
//                         _otpCode = pin;
//                       });
//                       _verifyOtp();
//                     },
//                     onChanged: (pin) {
//                       setState(() {
//                         _otpCode = pin;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 32),
//                   CustomButton(
//                     text: 'Verify & Continue',
//                     isLoading: authState.isLoading,
//                     onPressed: _verifyOtp,
//                   ),

//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Didn't receive code? ",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: _resendOtp,
//                         child: Text(
//                           'Resend OTP',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
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
import '../../../../core/widgets/otp_input.dart';
import '../providers/auth_provider.dart';
import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _otpCode = '';

  void _verifyOtp() async {
    ref.read(authProvider.notifier).clearMessages();

    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit OTP code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(
          phone: widget.phoneNumber,
          otp: _otpCode,
          rememberMe: true,
        );

    if (success && mounted) {
      final state = ref.read(authProvider);
      if (state.isNewUser) {
        context.go('/profile-setup');
      } else {
        await ref.read(userAddressesProvider.notifier).loadAddresses();
        final addresses = ref.read(userAddressesProvider).addresses;
        if (mounted) {
          if (addresses.isNotEmpty) {
            context.go('/home');
          } else {
            context.go('/location-permission');
          }
        }
      }
    }
  }

  void _resendOtp() async {
    ref.read(authProvider.notifier).clearMessages();
    await ref.read(authProvider.notifier).sendOtp(phone: widget.phoneNumber);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New OTP code dispatched to ${widget.phoneNumber}'),
          backgroundColor: Colors.green,
        ),
      );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Verify OTP Code',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification pin to ${widget.phoneNumber}.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Hardcoded Test OTP banner & Fill Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Test OTP Code: 123456',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _otpCode = '123456';
                            });
                            _verifyOtp();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '⚡ Tap to Autofill Test OTP (123456) & Verify',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Error
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

                  // OTP Input Widget
                  OtpInput(
                    length: 6,
                    onCompleted: (pin) {
                      setState(() {
                        _otpCode = pin;
                      });
                      _verifyOtp();
                    },
                    onChanged: (pin) {
                      setState(() {
                        _otpCode = pin;
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Verify & Continue',
                    isLoading: authState.isLoading,
                    onPressed: _verifyOtp,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend OTP',
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
    );
  }
}
