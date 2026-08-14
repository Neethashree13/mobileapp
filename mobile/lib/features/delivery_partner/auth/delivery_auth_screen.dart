import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../widgets/delivery_partner_widgets.dart';

class DeliveryAuthScreen extends StatefulWidget {
  const DeliveryAuthScreen({super.key});

  @override
  State<DeliveryAuthScreen> createState() => _DeliveryAuthScreenState();
}

class _DeliveryAuthScreenState extends State<DeliveryAuthScreen> {
  int _flowIndex = 0; // 0: Splash, 1: Login Form, 2: OTP Verification
  bool _rememberDevice = true;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailMode = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Simulate Splash Screen delay then route to Login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _flowIndex = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _triggerBiometric() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.fingerprint, size: 48, color: Theme.of(context).colorScheme.primary),
        title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Simulating fingerprint scanner... Touch the biometric scanner sensor of your mobile device to sign in securely.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/delivery-partner/dashboard');
            },
            child: const Text('Simulate Success'),
          ),
        ],
      ),
    );
  }

  void _triggerForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your registered email address below, and we will send you instructions to recover your rider console credentials.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.mail, size: 18),
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✉️ Reset instructions sent successfully! Please check your spam folder too.'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_flowIndex == 0) {
      return _buildSplashScreen(isDark);
    } else if (_flowIndex == 1) {
      return _buildLoginForm(isDark);
    } else {
      return _buildOtpScreen(isDark);
    }
  }

  Widget _buildSplashScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Hero(
                tag: 'app_logo',
                child: Icon(
                  LucideIcons.bike,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FlashCart AI',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            const Text(
              'DELIVERY PARTNER SYSTEMS',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Brand Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Hero(
                      tag: 'app_logo',
                      child: Icon(
                        LucideIcons.bike,
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Welcome back, Rider!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Login to start accepting delivery gigs',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Mode Selector (Phone vs Email)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isEmailMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isEmailMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Phone OTP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !_isEmailMode ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isEmailMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isEmailMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Email & Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isEmailMode ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone Input Field
                if (!_isEmailMode) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: '+91 ',
                      prefixIcon: Icon(LucideIcons.phone, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Email Form Fields
                if (_isEmailMode) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(LucideIcons.mail, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _triggerForgotPassword,
                      child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                // Remember Device & Biometric
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberDevice,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) => setState(() => _rememberDevice = val ?? true),
                        ),
                        const Text('Remember me', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.fingerprint, size: 28, color: Colors.blueAccent),
                      onPressed: _triggerBiometric,
                      tooltip: 'Login with Biometrics',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Action Button
                ElevatedButton(
                  onPressed: () {
                    if (!_isEmailMode) {
                      setState(() {
                        _flowIndex = 2; // Jump to OTP Verify
                      });
                    } else {
                      // Login directly via email
                      context.go('/delivery-partner/dashboard');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    !_isEmailMode ? 'Send Verification OTP' : 'Sign In Now',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => setState(() => _flowIndex = 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(LucideIcons.shieldAlert, size: 48, color: Colors.orange),
                const SizedBox(height: 18),
                const Text(
                  'Verify Security OTP',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We have sent a security verification OTP pin code to the phone number +91 ${_phoneController.text.isEmpty ? '9876543210' : _phoneController.text}.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Custom OTP Entry Widget
                OTPWidget(
                  length: 4,
                  onCompleted: (otp) {
                    // Success! Go to dashboard
                    context.go('/delivery-partner/dashboard');
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'Didn\'t receive OTP code?',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚡ OTP resent successfully to your device!'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  },
                  child: const Text(
                    'Resend via SMS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
