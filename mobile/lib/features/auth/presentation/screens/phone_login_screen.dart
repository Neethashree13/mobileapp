// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../core/widgets/custom_text_field.dart';
// import '../providers/auth_provider.dart';

// class PhoneLoginScreen extends ConsumerStatefulWidget {
//   const PhoneLoginScreen({super.key});

//   @override
//   ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
// }

// class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _submit() async {
//     ref.read(authProvider.notifier).clearMessages();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final phone = _phoneController.text.trim();
//     final success = await ref.read(authProvider.notifier).sendOtp(phone: phone);

//     if (success && mounted) {
//       context.push('/otp-verify', extra: phone);
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
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Phone Authentication',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: -0.5,
//                         color: isDark ? Colors.white : const Color(0xFF111827),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Enter your 10-digit mobile number. We will dispatch a 6-digit SMS OTP verification pin.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         height: 1.5,
//                         color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Display Error
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
//                       controller: _phoneController,
//                       label: 'Mobile Number',
//                       hintText: '9876543210',
//                       keyboardType: TextInputType.phone,
//                       prefixIcon: const Icon(Icons.smartphone_outlined),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return 'Please enter your mobile phone number';
//                         }
//                         if (val.trim().length < 8) {
//                           return 'Please enter a valid phone number';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),
//                     CustomButton(
//                       text: 'Send SMS OTP',
//                       isLoading: authState.isLoading,
//                       onPressed: _submit,
//                     ),

//                     const SizedBox(height: 24),
//                     Center(
//                       child: TextButton(
//                         onPressed: () => context.push('/email-login'),
//                         child: Text(
//                           'Use Email & Password Instead',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                       ),
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

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    ref.read(authProvider.notifier).clearMessages();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final success = await ref.read(authProvider.notifier).sendOtp(phone: phone);

    if (success && mounted) {
      context.push('/otp-verify', extra: phone);
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
                      'Phone Authentication',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your 10-digit mobile number to log in.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read_rounded, color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Test Mode Active: ',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                  TextSpan(text: 'Enter any phone number & use test OTP '),
                                  TextSpan(
                                    text: '123456',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: ' on the next screen.'),
                                ],
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

                    CustomTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hintText: '9876543210',
                      keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.smartphone_outlined),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your mobile phone number';
                        }
                        if (val.trim().length < 8) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Send SMS OTP',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/email-login'),
                        child: Text(
                          'Use Email & Password Instead',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
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
