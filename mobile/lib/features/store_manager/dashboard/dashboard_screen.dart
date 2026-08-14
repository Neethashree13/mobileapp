import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int) onTabChange;
  const DashboardScreen({super.key, required this.onTabChange});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(storeManagerOrdersProvider);
    final inventory = ref.watch(storeManagerInventoryProvider);
    final staff = ref.watch(storeManagerActiveStaffProvider);

    // Calculate dynamic stats
    final waitingCount = orders.where((o) => o.status == OrderFulfillmentStatus.pending).length;
    final pickingCount = orders.where((o) => o.status == OrderFulfillmentStatus.picking).length;
    final packingCount = orders.where((o) => o.status == OrderFulfillmentStatus.packing).length;
    final readyCount = orders.where((o) => o.status == OrderFulfillmentStatus.readyForPickup).length;
    final lowStockCount = inventory.where((item) => item.status == InventoryStatus.lowStock || item.status == InventoryStatus.outOfStock).length;

    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dark Store Dashboard",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.storeDetails,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.radio, size: 14, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          "TERMINAL ONLINE",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Responsive Metrics Row
              isTablet
                  ? Row(
                      children: [
                        Expanded(child: _buildQueueMetric("Pending Queue", waitingCount.toString(), "Orders waiting", Colors.orange, () => widget.onTabChange(1))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildQueueMetric("Active Picking", pickingCount.toString(), "Items on shelf", Colors.blue, () => widget.onTabChange(2))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildQueueMetric("Ready to Pack", packingCount.toString(), "Awaiting carton", Colors.purple, () => widget.onTabChange(3))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildQueueMetric("Dispatch Ready", readyCount.toString(), "Rider assigned", Colors.teal, () => widget.onTabChange(1))),
                      ],
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                      children: [
                        _buildQueueMetric("Pending Queue", waitingCount.toString(), "Orders waiting", Colors.orange, () => widget.onTabChange(1)),
                        _buildQueueMetric("Active Picking", pickingCount.toString(), "In process", Colors.blue, () => widget.onTabChange(2)),
                        _buildQueueMetric("Ready to Pack", packingCount.toString(), "In queue", Colors.purple, () => widget.onTabChange(3)),
                        _buildQueueMetric("Dispatch Ready", readyCount.toString(), "Rider assigned", Colors.teal, () => widget.onTabChange(1)),
                      ],
                    ),
              const SizedBox(height: 24),

              // KPI Counters & Staff Stats Section
              const Text(
                "Fulfillment Key Performance Indicators (KPI)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              isTablet
                  ? Row(
                      children: [
                        Expanded(
                          child: KPICard(
                            title: "Average Pick Time",
                            value: "4m 12s",
                            subtitle: "⚡ Goal: Under 5 mins",
                            icon: LucideIcons.timer,
                            accentColor: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KPICard(
                            title: "Dispatch Accuracy",
                            value: "${staff.packingAccuracy}%",
                            subtitle: "🎯 Goal: Over 99.5%",
                            icon: LucideIcons.checkSquare,
                            accentColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KPICard(
                            title: "Low Stock Items",
                            value: lowStockCount.toString(),
                            subtitle: "⚠️ Requires restocking",
                            icon: LucideIcons.package2,
                            accentColor: Colors.redAccent,
                            onTap: () => widget.onTabChange(4),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        KPICard(
                          title: "Average Pick Time",
                          value: "4m 12s",
                          subtitle: "⚡ Goal: Under 5 mins",
                          icon: LucideIcons.timer,
                          accentColor: Colors.blueAccent,
                        ),
                        const SizedBox(height: 10),
                        KPICard(
                          title: "Dispatch Accuracy",
                          value: "${staff.packingAccuracy}%",
                          subtitle: "🎯 Goal: Over 99.5%",
                          icon: LucideIcons.checkSquare,
                          accentColor: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        KPICard(
                          title: "Low Stock Items",
                          value: lowStockCount.toString(),
                          subtitle: "⚠️ Requires restocking",
                          icon: LucideIcons.package2,
                          accentColor: Colors.redAccent,
                          onTap: () => widget.onTabChange(4),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Staff Performance Section
              const Text(
                "My Performance Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.10) : Colors.black12.withOpacity(0.05),
                  ),
                ),
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161A22) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(staff.avatarUrl),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${staff.role} • ${staff.shift}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPerformanceStat("Picked", "${staff.ordersPicked}", "Orders"),
                          _buildPerformanceStat("Accuracy", "${staff.packingAccuracy}%", "Zero errors"),
                          _buildPerformanceStat("Productivity", "${staff.productivityIndex}/10", "Top tier"),
                          _buildPerformanceStat("Attendance", "${staff.attendanceDays}d", "This month"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Low Stock Alert Highlights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Critical Inventory Alerts",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => widget.onTabChange(4),
                    child: const Text("View All Stock"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              inventory.any((item) => item.status == InventoryStatus.lowStock || item.status == InventoryStatus.outOfStock)
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inventory.where((item) => item.status == InventoryStatus.lowStock || item.status == InventoryStatus.outOfStock).length.clamp(0, 2),
                      itemBuilder: (context, index) {
                        final lowItems = inventory.where((item) => item.status == InventoryStatus.lowStock || item.status == InventoryStatus.outOfStock).toList();
                        return InventoryCard(
                          item: lowItems[index],
                          onAddStock: () {
                            ref.read(storeManagerInventoryProvider.notifier).addStock(lowItems[index].id, 50);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Restocked 50 units of ${lowItems[index].name}!")),
                            );
                          },
                        );
                      },
                    )
                  : const EmptyState(
                      title: "Inventory Healthy",
                      subtitle: "No products are currently critical or out of stock.",
                      icon: LucideIcons.sparkles,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueMetric(String label, String value, String subtitle, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.10) : Colors.black12.withOpacity(0.05),
        ),
      ),
      color: isDark ? const Color(0xFF161A22) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "active",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceStat(String title, String val, String sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
