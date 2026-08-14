import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/delivery_partner_providers.dart';
import '../widgets/delivery_partner_widgets.dart';

class DeliveryDashboardTab extends ConsumerWidget {
  final Function(int) onTabChange;

  const DeliveryDashboardTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(deliveryPartnerDutyStatusProvider);
    final activeOrder = ref.watch(deliveryPartnerActiveOrderProvider);
    final availableOrders = ref.watch(deliveryPartnerAvailableOrdersProvider);
    final earningsList = ref.watch(deliveryPartnerEarningsProvider);
    final stats = ref.watch(deliveryPartnerPerformanceProvider);

    // Calculate today's earnings sum and completed order count
    final earningsNotifier = ref.read(deliveryPartnerEarningsProvider.notifier);
    final todayAmount = earningsNotifier.todayEarnings;
    final todayCount = stats.totalCompleted;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Online / Offline Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isOnline)
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Active On Duty' : 'Offline / Rest Mode',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnline ? 'Ready to accept local deliveries' : 'Go online to receive nearby orders',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: isOnline,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    ref.read(deliveryPartnerDutyStatusProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Order Prominent Banner (if any)
          if (activeOrder != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.navigation, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'En-Route: Gig In Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Order ID: ${activeOrder.orderId} (${activeOrder.items.length} items)',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onTabChange(1), // Route to Orders tab/workflow
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Navigation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Earnings Quick Dashboard Card
          EarningsCard(
            todayAmount: todayAmount,
            todayCount: todayCount,
            onDetailsTap: () => onTabChange(2), // Route to Earnings detailed tab
          ),
          const SizedBox(height: 16),

          // Stats Bento Grid (Rating, Acceptance, Completion)
          Row(
            children: [
              Expanded(
                child: PerformanceCard(
                  label: 'RIDER RATING',
                  value: '${stats.customerRating} ★',
                  percentage: stats.customerRating / 5.0,
                  icon: LucideIcons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PerformanceCard(
                  label: 'ACCEPTANCE RATE',
                  value: '${(stats.acceptanceRate * 100).toStringAsFixed(0)}%',
                  percentage: stats.acceptanceRate,
                  icon: LucideIcons.thumbsUp,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PerformanceCard(
                  label: 'COMPLETION RATE',
                  value: '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                  percentage: stats.completionRate,
                  icon: LucideIcons.shieldCheck,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161A22) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF242C3B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TODAY\'S SHIFT',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          const Text(
                            '3h 45m',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Shift: Morning Slot', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions Row
          const Text(
            'Quick Rider Services',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickActionItem(
                icon: LucideIcons.wallet,
                label: 'Wallet',
                color: Colors.teal,
                onTap: () => onTabChange(3), // Wallet Tab
              ),
              _QuickActionItem(
                icon: LucideIcons.lineChart,
                label: 'Analytics',
                color: Colors.indigo,
                onTap: () => onTabChange(4), // Performance Tab
              ),
              _QuickActionItem(
                icon: LucideIcons.alertOctagon,
                label: 'SOS Alert',
                color: Colors.redAccent,
                onTap: () {
                  // Direct trigger of SOS popup
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const _SOSBottomSheet(),
                  );
                },
              ),
              _QuickActionItem(
                icon: LucideIcons.helpCircle,
                label: 'Support',
                color: Colors.blueGrey,
                onTap: () {
                  // Open quick support details
                  onTabChange(5); // Profile / Support Hub
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // List of Nearby Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Local Delivery Gigs Nearby',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () => onTabChange(1), // Route to Order Board
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(LucideIcons.chevronRight, size: 14),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          if (!isOnline)
            const EmptyStateWidget(
              title: 'Rider is Offline',
              message: 'Toggle on your duty switch at the top of the screen to unlock and browse nearby delivery gigs.',
              icon: LucideIcons.cloudOff,
            )
          else if (availableOrders.isEmpty)
            const EmptyStateWidget(
              title: 'Looking for jobs...',
              message: 'Currently no new orders in your sector. We will notify you immediately once a restaurant or grocery gig becomes available.',
              icon: LucideIcons.search,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableOrders.take(2).length,
              itemBuilder: (context, index) {
                final order = availableOrders[index];
                return OrderCard(
                  order: order,
                  onAccept: () {
                    ref.read(deliveryPartnerActiveOrderProvider.notifier).acceptOrder(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚡ Accepted Order ${order.orderId}! Opened Navigation Screen.'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                    onTabChange(1); // switch to navigation/workflow tab
                  },
                  onReject: () {
                    ref.read(deliveryPartnerAvailableOrdersProvider.notifier).removeOrder(order.orderId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order gig ignored.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SOSBottomSheet extends StatefulWidget {
  const _SOSBottomSheet();

  @override
  State<_SOSBottomSheet> createState() => _SOSBottomSheetState();
}

class _SOSBottomSheetState extends State<_SOSBottomSheet> {
  int _counter = 5;
  bool _sosDispatched = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 5; i > 0; i--) {
      if (!mounted || _sosDispatched) return;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _counter--;
        });
      }
    }
    if (mounted && _counter == 0) {
      setState(() {
        _sosDispatched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          if (!_sosDispatched) ...[
            const Icon(LucideIcons.alertTriangle, size: 64, color: Colors.redAccent),
            const SizedBox(height: 18),
            const Text(
              'Emergency SOS Beacon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Rider safety is paramount. We will automatically broadcast your live location, dispatch an emergency response vehicle, and call local authorities in:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: _counter / 5.0,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
                    ),
                  ),
                  Text(
                    '$_counter',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            const Icon(LucideIcons.shieldAlert, size: 64, color: Colors.teal),
            const SizedBox(height: 18),
            const Text(
              'SOS Beacon Dispatched!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Our FlashCart Emergency Desk is dialing your number immediately. Emergency medics and nearby logistics personnel have been notified of your exact GPS coordinate.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.check),
                    label: const Text('I am Safe Now'),
                  ),
                ),
              ],
            )
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
