import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  String _detectedCardBrand = 'Generic Card';
  IconData _cardBrandIcon = Icons.credit_card_rounded;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      final val = _cardNumberController.text;
      setState(() {
        if (val.startsWith('4')) {
          _detectedCardBrand = 'VISA';
          _cardBrandIcon = Icons.payment_rounded;
        } else if (val.startsWith('5')) {
          _detectedCardBrand = 'MASTERCARD';
          _cardBrandIcon = Icons.credit_card_rounded;
        } else {
          _detectedCardBrand = 'Generic Card';
          _cardBrandIcon = Icons.credit_card_outlined;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final isDark = ref.watch(settingsProvider).isDarkMode;

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Wallet Balance Card
              _buildSectionTitle('SAVED BALANCES', isDark),
              _buildWalletBalanceRow(walletState, isDark),
              const SizedBox(height: 20),

              // 2. UPI payments
              _buildSectionTitle('UPI INSTANT PAYMENTS', isDark),
              _buildUPIMethods(isDark),
              const SizedBox(height: 20),

              // 3. Saved Cards
              _buildSectionTitle('SAVED CARDS', isDark),
              _buildSavedCards(isDark),
              const SizedBox(height: 20),

              // 4. Add New Credit/Debit Card Form
              _buildSectionTitle('ADD NEW CARD', isDark),
              _buildAddCardForm(isDark),
              const SizedBox(height: 20),

              // 5. Net Banking
              _buildSectionTitle('POPULAR BANKS (NET BANKING)', isDark),
              _buildNetBankingGrid(isDark),
              const SizedBox(height: 20),

              // 6. Cash on Delivery
              _buildSectionTitle('OFFLINE METHOD', isDark),
              _buildCodTile(isDark),
              const SizedBox(height: 32),
            ],
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

  Widget _buildWalletBalanceRow(WalletState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FlashCart Wallet Credits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Instant refunds & secure cashbacks', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Text(
            '\$${state.balance.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent),
          )
        ],
      ),
    );
  }

  Widget _buildUPIMethods(bool isDark) {
    final upis = [
      {'name': 'Paytm UPI', 'subtitle': 'Pay instantly with linked bank', 'logo': '🅿️'},
      {'name': 'Google Pay', 'subtitle': 'Secure 1-tap checkout via GPay', 'logo': '🇬'},
      {'name': 'PhonePe', 'subtitle': 'Integrated regional transfers', 'logo': '🟣'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: upis.map((upi) {
          return ListTile(
            onTap: () => _simulatePayment(upi['name']!, true),
            leading: CircleAvatar(
              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              child: Text(upi['logo']!, style: const TextStyle(fontSize: 16)),
            ),
            title: Text(upi['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(upi['subtitle']!, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavedCards(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, color: Colors.orangeAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Visa Premium Credit Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Masked **** **** **** 4829', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _simulatePayment('Saved Visa Card', true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('PAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_cardBrandIcon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Detected: $_detectedCardBrand',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder(), hintText: '4000 1234 5678 9010'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNameController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Cardholder Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cardExpiryController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cardCvvController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_cardNumberController.text.isEmpty || _cardNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete credit card fields')),
                );
                return;
              }
              _simulatePayment('New $_detectedCardBrand Card', true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add & Securely Pay', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildNetBankingGrid(bool isDark) {
    final banks = [
      {'name': 'HDFC Bank', 'emoji': '🏦'},
      {'name': 'ICICI Bank', 'emoji': '🏢'},
      {'name': 'SBI Core', 'emoji': '🏛️'},
      {'name': 'Axis Bank', 'emoji': '🏫'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: banks.length,
      itemBuilder: (context, index) {
        final bank = banks[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            onTap: () => _simulatePayment(bank['name']!, true),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(bank['emoji']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bank['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodTile(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: () => _simulatePayment('Cash on Delivery', true),
        leading: const CircleAvatar(backgroundColor: Color(0xFF042C22), child: Text('💵')),
        title: const Text('Cash On Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: const Text('Pay with cash, cards, or UPI during hand-over', style: TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  void _simulatePayment(String method, bool makeSuccessful) {
    // 1. Show processing overlay dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _buildProcessingOverlay(method);
      },
    );

    // 2. Resolve payment outcome after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // close processing dialog
      if (makeSuccessful) {
        _showSuccessDialog();
      } else {
        _showFailureDialog();
      }
    });
  }

  Widget _buildProcessingOverlay(String method) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF10B981)),
            const SizedBox(height: 24),
            Text(
              'Processing secure transfer via $method...',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please do not close this window or lock your screen.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
              SizedBox(height: 12),
              Text('Payment Succeeded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
          content: const Text(
            'Your checkout transaction has been processed securely. Your delivery partner is packing the items.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
              ),
              child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 48),
              SizedBox(height: 12),
              Text('Transaction Failed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
          content: const Text(
            'The secure gateway rejected the card authorization. Please check card inputs or try Paytm/Google Pay UPI.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}
