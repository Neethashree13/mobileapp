import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/delivery_partner_providers.dart';
import '../widgets/delivery_partner_widgets.dart';

class WalletTab extends ConsumerStatefulWidget {
  const WalletTab({super.key});

  @override
  ConsumerState<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends ConsumerState<WalletTab> {
  String _payoutMethod = 'Bank Transfer'; // or 'UPI'
  final _bankAccountController = TextEditingController(text: 'HDFC Bank **** 9482');
  final _upiController = TextEditingController(text: 'rider99@paytm');
  double _completedTransfers = 12480.00;

  @override
  void dispose() {
    _bankAccountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _triggerCashout(double currentBalance) {
    if (currentBalance == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Wallet balance is zero. Complete deliveries to earn money!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(LucideIcons.checkCircle, size: 48, color: Colors.teal),
        title: const Text('Confirm Cashout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Do you want to instantly cash out ₹${currentBalance.toStringAsFixed(1)} to your registered ${_payoutMethod == 'Bank Transfer' ? _bankAccountController.text : _upiController.text}?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _completedTransfers += currentBalance;
              });
              // Reset earnings today list
              ref.read(deliveryPartnerEarningsProvider.notifier).withdrawWalletBalance();
              
              // Success dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Transfer Initiated ⚡'),
                  content: const Text('Success! Your funds will arrive in your bank account within 5-10 minutes. Transaction ID: TXN-WID-90481.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great!'))],
                ),
              );
            },
            child: const Text('Transfer Now'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earnings = ref.watch(deliveryPartnerEarningsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayEarnings = ref.read(deliveryPartnerEarningsProvider.notifier).todayEarnings;
    final pendingPayout = todayEarnings * 0.15;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rider Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reusable Wallet Card
            WalletCard(
              balance: todayEarnings,
              pending: pendingPayout,
              completed: _completedTransfers,
              onWithdraw: () => _triggerCashout(todayEarnings),
            ),
            const SizedBox(height: 24),

            // Payout Configurations
            const Text('Deposit Credentials', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodButton('Bank Transfer', LucideIcons.building),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodButton('UPI', LucideIcons.smartphone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_payoutMethod == 'Bank Transfer') ...[
                    TextField(
                      controller: _bankAccountController,
                      decoration: const InputDecoration(
                        labelText: 'Registered Bank Account',
                        prefixIcon: Icon(LucideIcons.building2, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Bank Account: HDFC Bank, Cyber City Branch, IFSC: HDFC0001092', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ] else ...[
                    TextField(
                      controller: _upiController,
                      decoration: const InputDecoration(
                        labelText: 'Registered UPI ID',
                        prefixIcon: Icon(LucideIcons.atSign, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Linked to primary phone number biometric setup', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cashout logs / Security info
            const Text('Payout Security Policy', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.shieldCheck, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All instant cashouts are guarded by Gurgaon bank APIs. FlashCart completes double-encryption validation on bank channels. Cashouts are free of surcharge up to ₹50,000 monthly.',
                      style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton(String method, IconData icon) {
    final isSelected = _payoutMethod == method;
    return ElevatedButton.icon(
      onPressed: () => setState(() => _payoutMethod = method),
      icon: Icon(icon, size: 14),
      label: Text(method, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.12),
        foregroundColor: isSelected ? Colors.white : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
