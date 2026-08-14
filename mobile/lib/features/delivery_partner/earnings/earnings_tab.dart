import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/delivery_partner_providers.dart';

class EarningsTab extends ConsumerWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(deliveryPartnerEarningsProvider);
    final stats = ref.watch(deliveryPartnerPerformanceProvider);
    final earningsNotifier = ref.read(deliveryPartnerEarningsProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayAmount = earningsNotifier.todayEarnings;
    final weeklyAmount = earningsNotifier.weeklyEarnings;
    final monthlyAmount = earningsNotifier.monthlyEarnings;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Earnings Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚡ Syncing billing ledger with Gurgaon corporate server...')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period selector (Bento Stats)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)] : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF312E81) : const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  const Text('TOTAL UNWITHDRAWN BALANCE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${todayAmount.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPeriodStat('Today', '₹${todayAmount.toStringAsFixed(0)}'),
                      Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3)),
                      _buildPeriodStat('This Week', '₹${weeklyAmount.toStringAsFixed(0)}'),
                      Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3)),
                      _buildPeriodStat('This Month', '₹${monthlyAmount.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Earnings Breakdowns Card
            const Text('Earnings Composition', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildCompositionRow(context, LucideIcons.bike, 'Base Cargo Deliveries', '₹${(todayAmount * 0.75).toStringAsFixed(1)}', Colors.blue),
                  const Divider(height: 24, thickness: 1, color: Color(0x1F808080)),
                  _buildCompositionRow(context, LucideIcons.zap, 'Peak Hours & Distance Incentives', '₹${(todayAmount * 0.15).toStringAsFixed(1)}', Colors.orange),
                  const Divider(height: 24, thickness: 1, color: Color(0x1F808080)),
                  _buildCompositionRow(context, LucideIcons.heart, 'Appreciation Customer Tips', '₹${(todayAmount * 0.10).toStringAsFixed(1)}', Colors.pink),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ledger Transaction list
            const Text('Historic Ledger Entries', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text('No earnings entries found for this shift.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  IconData icon = LucideIcons.bike;
                  Color iconColor = Colors.blue;

                  if (txn.type == 'Bonus') {
                    icon = LucideIcons.zap;
                    iconColor = Colors.orange;
                  } else if (txn.type == 'Tip') {
                    icon = LucideIcons.heart;
                    iconColor = Colors.pink;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161A22) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
                              child: Icon(icon, size: 16, color: iconColor),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(txn.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Order: ${txn.orderId} • ${txn.type}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '+₹${txn.amount.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStat(String label, String amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildCompositionRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
