import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

// Providers and widgets
import 'providers/delivery_partner_providers.dart';
import 'widgets/delivery_partner_widgets.dart';

// Tab screens
import 'dashboard/delivery_dashboard_tab.dart';
import 'orders/available_orders_tab.dart';
import 'earnings/earnings_tab.dart';
import 'wallet/wallet_tab.dart';
import 'performance/performance_tab.dart';
import 'profile/delivery_profile_tab.dart';

class DeliveryPartnerMainScreen extends ConsumerStatefulWidget {
  const DeliveryPartnerMainScreen({super.key});

  @override
  ConsumerState<DeliveryPartnerMainScreen> createState() => _DeliveryPartnerMainScreenState();
}

class _DeliveryPartnerMainScreenState extends ConsumerState<DeliveryPartnerMainScreen> {
  int _currentIndex = 0;
  bool _showProfilePage = false;

  void _triggerNotificationsPanel() {
    final notifications = ref.read(deliveryPartnerNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final activeNotifications = ref.watch(deliveryPartnerNotificationsProvider);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rider Alert Center',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(deliveryPartnerNotificationsProvider.notifier).markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All alerts marked as read.')),
                          );
                        },
                        child: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (activeNotifications.isEmpty)
                    const Expanded(
                      child: EmptyStateWidget(
                        title: 'All caught up!',
                        message: 'No new administrative announcements or system triggers found.',
                        icon: LucideIcons.bellOff,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: activeNotifications.length,
                        itemBuilder: (context, index) {
                          final item = activeNotifications[index];
                          return Opacity(
                            opacity: item.isRead ? 0.6 : 1.0,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: !item.isRead
                                    ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))
                                    : null,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.type == 'Gig' 
                                        ? LucideIcons.bike 
                                        : (item.type == 'Promo' ? LucideIcons.sparkles : LucideIcons.info),
                                    color: item.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(deliveryPartnerDutyStatusProvider);
    final notifications = ref.watch(deliveryPartnerNotificationsProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define tabs
    final List<Widget> tabs = [
      DeliveryDashboardTab(onTabChange: (index) {
        setState(() {
          _currentIndex = index;
          _showProfilePage = false;
        });
      }),
      const AvailableOrdersTab(),
      const EarningsTab(),
      const WalletTab(),
      const PerformanceTab(),
    ];

    if (_showProfilePage) {
      return DeliveryProfileTab(
        onLogout: () {
          // Reset duty status and logout to login flow
          ref.read(deliveryPartnerDutyStatusProvider.notifier).state = false;
          context.go('/delivery-partner/login');
        },
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(LucideIcons.bike, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FlashCart Rider',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification alerts bell
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, size: 18),
                onPressed: _triggerNotificationsPanel,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),

          // User Profile avatar
          GestureDetector(
            onTap: () {
              setState(() {
                _showProfilePage = true;
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16, left: 6),
              child: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
              ),
            ),
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _showProfilePage = false;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard, size: 18),
            activeIcon: Icon(LucideIcons.layoutDashboard, size: 20),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bike, size: 18),
            activeIcon: Icon(LucideIcons.bike, size: 20),
            label: 'Jobs Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.lineChart, size: 18),
            activeIcon: Icon(LucideIcons.lineChart, size: 20),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet, size: 18),
            activeIcon: Icon(LucideIcons.wallet, size: 20),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.sparkles, size: 18),
            activeIcon: Icon(LucideIcons.sparkles, size: 20),
            label: 'Scorecard',
          ),
        ],
      ),
    );
  }
}
