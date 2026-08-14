import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'providers/store_manager_providers.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/order_queue_screen.dart';
import 'picking/picking_screen.dart';
import 'packing/packing_screen.dart';
import 'inventory/inventory_screen.dart';
import 'warehouse/warehouse_screen.dart';
import 'returns/returns_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class StoreManagerMainScreen extends ConsumerStatefulWidget {
  const StoreManagerMainScreen({super.key});

  @override
  ConsumerState<StoreManagerMainScreen> createState() => _StoreManagerMainScreenState();
}

class _StoreManagerMainScreenState extends ConsumerState<StoreManagerMainScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check active picking / packing states
    final activePickingOrder = ref.watch(storeManagerActivePickingProvider);
    final activePackingOrder = ref.watch(storeManagerActivePackingProvider);

    // Dynamic views list
    final List<Widget> tabViews = [
      DashboardScreen(onTabChange: (index) {
        setState(() {
          _currentTab = index;
        });
      }),
      OrderQueueScreen(
        onSelectPickingOrder: (order) {
          ref.read(storeManagerActivePickingProvider.notifier).setActive(order);
        },
        onSelectPackingOrder: (order) {
          ref.read(storeManagerActivePackingProvider.notifier).setActive(order);
        },
      ),
      const InventoryScreen(),
      const WarehouseScreen(),
      const ReturnsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    // Overlay picking / packing screen if active session exists
    Widget currentDisplay;
    if (activePickingOrder != null) {
      currentDisplay = PickingScreen(
        onFinishPicking: () {
          setState(() {
            _currentTab = 1; // Return to Order Queue tab
          });
        },
      );
    } else if (activePackingOrder != null) {
      currentDisplay = PackingScreen(
        onFinishPacking: () {
          setState(() {
            _currentTab = 1; // Return to Order Queue tab
          });
        },
      );
    } else {
      currentDisplay = tabViews[_currentTab];
    }

    // Header icons on mobile view
    final List<Widget> headerActions = [
      Stack(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              setState(() {
                _currentTab = 5; // Notifications tab
              });
            },
          ),
          // Check unread notifications count
          Consumer(
            builder: (context, ref, child) {
              final notifs = ref.watch(storeManagerNotificationsProvider);
              final unread = notifs.where((n) => !n.isRead).length;
              if (unread == 0) return const SizedBox();
              return Positioned(
                top: 6,
                right: 6,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.red,
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        ],
      ),
      IconButton(
        icon: const Icon(LucideIcons.user),
        onPressed: () {
          setState(() {
            _currentTab = 6; // Profile tab
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: (!isTablet && activePickingOrder == null && activePackingOrder == null && _currentTab < 5)
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.packageCheck, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text("FlashCart AI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              actions: headerActions,
              elevation: 0.5,
            )
          : null,
      body: Row(
        children: [
          // Left rail for tablets
          if (isTablet && activePickingOrder == null && activePackingOrder == null)
            NavigationRail(
              selectedIndex: _currentTab,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
              backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
              labelType: NavigationRailLabelType.all,
              leading: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.shieldCheck, size: 24, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(LucideIcons.layoutDashboard),
                  selectedIcon: Icon(LucideIcons.layoutDashboard, color: Colors.blueAccent),
                  label: Text("Dashboard", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.shoppingBag),
                  selectedIcon: Icon(LucideIcons.shoppingBag, color: Colors.blueAccent),
                  label: Text("Orders Queue", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.package),
                  selectedIcon: Icon(LucideIcons.package, color: Colors.blueAccent),
                  label: Text("Inventory", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.map),
                  selectedIcon: Icon(LucideIcons.map, color: Colors.blueAccent),
                  label: Text("Warehouse", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.rotateCcw),
                  selectedIcon: Icon(LucideIcons.rotateCcw, color: Colors.blueAccent),
                  label: Text("Returns", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.bell),
                  selectedIcon: Icon(LucideIcons.bell, color: Colors.blueAccent),
                  label: Text("Alerts", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: Icon(LucideIcons.user),
                  selectedIcon: Icon(LucideIcons.user, color: Colors.blueAccent),
                  label: Text("Profile", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          
          // Main Panel View
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: currentDisplay,
            ),
          ),
        ],
      ),
      
      // Bottom navigation bar for mobile phones
      bottomNavigationBar: (!isTablet && activePickingOrder == null && activePackingOrder == null)
          ? BottomNavigationBar(
              currentIndex: _currentTab > 4 ? 0 : _currentTab, // Keep focus inside range
              onTap: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.layoutDashboard),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.shoppingBag),
                  label: "Orders Queue",
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.package),
                  label: "Inventory",
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.map),
                  label: "Warehouse",
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.rotateCcw),
                  label: "Returns",
                ),
              ],
            )
          : null,
    );
  }
}
