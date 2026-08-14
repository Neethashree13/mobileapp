import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final isDark = ref.watch(settingsProvider).isDarkMode;

    final systemAlerts = notifications.where((n) => n.category == NotificationCategory.system || n.category == NotificationCategory.order).toList();
    final promoAlerts = notifications.where((n) => n.category == NotificationCategory.promo).toList();

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            if (notifications.any((n) => !n.isRead))
              IconButton(
                icon: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF10B981)),
                tooltip: 'Mark All Read',
                onPressed: () {
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read.')),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey),
              tooltip: 'Clear All',
              onPressed: () {
                ref.read(notificationsProvider.notifier).clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification log cleared.')),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF10B981),
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'System & Orders (${systemAlerts.length})'),
              Tab(text: 'Offers & Promos (${promoAlerts.length})'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationTab(systemAlerts, isDark),
            _buildNotificationTab(promoAlerts, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTab(List<NotificationModel> alerts, bool isDark) {
    if (alerts.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_rounded,
        title: 'Clear Airwaves!',
        description: 'No notifications in this category. We\'ll let you know when dispatch trucks roll out.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Dismissible(
          key: Key(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
          ),
          onDismissed: (direction) {
            ref.read(notificationsProvider.notifier).deleteNotification(alert.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notification deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: const Color(0xFF10B981),
                  onPressed: () {
                    // Quick state restore demo
                    ref.read(notificationsProvider.notifier).restoreNotification(alert);
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: NotificationTile(
              notification: alert,
              onTap: () {
                ref.read(notificationsProvider.notifier).markAsRead(alert.id);
              },
            ),
          ),
        );
      },
    );
  }
}
