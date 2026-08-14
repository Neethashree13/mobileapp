import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(storeManagerNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Alerts & Broadcasts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(storeManagerNotificationsProvider.notifier).markAllRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All notifications marked as read!")),
                );
              },
              icon: const Icon(LucideIcons.checkCheck, size: 16),
              label: const Text("Mark All Read", style: TextStyle(fontSize: 12)),
            )
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              title: "Inbox Clean",
              subtitle: "No critical alerts or general announcements reported today.",
              icon: LucideIcons.bellRing,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                
                IconData notifIcon;
                Color notifColor;
                switch (notif.category) {
                  case NotificationCategory.newOrder:
                    notifIcon = LucideIcons.shoppingCart;
                    notifColor = Colors.blueAccent;
                    break;
                  case NotificationCategory.stockAlert:
                    notifIcon = LucideIcons.alertTriangle;
                    notifColor = Colors.orange;
                    break;
                  case NotificationCategory.supervisorAnnouncement:
                    notifIcon = LucideIcons.megaphone;
                    notifColor = Colors.purple;
                    break;
                }

                final duration = DateTime.now().difference(notif.timestamp);
                String timeText = duration.inMinutes < 60
                    ? "${duration.inMinutes}m ago"
                    : "${duration.inHours}h ago";

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: notif.isRead
                          ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1))
                          : notifColor.withOpacity(0.4),
                      width: notif.isRead ? 1 : 1.5,
                    ),
                  ),
                  color: notif.isRead
                      ? (isDark ? const Color(0xFF161A22) : Colors.white)
                      : (isDark ? notifColor.withOpacity(0.08) : notifColor.withOpacity(0.04)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notifColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(notifIcon, color: notifColor, size: 20),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeText,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: notif.isRead
                              ? (isDark ? Colors.grey[400] : Colors.grey[700])
                              : (isDark ? Colors.white70 : Colors.black87),
                          height: 1.4,
                        ),
                      ),
                    ),
                    trailing: !notif.isRead
                        ? IconButton(
                            icon: const Icon(LucideIcons.check, color: Colors.green, size: 18),
                            onPressed: () {
                              ref.read(storeManagerNotificationsProvider.notifier).markAsRead(notif.id);
                            },
                            tooltip: "Mark as read",
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
