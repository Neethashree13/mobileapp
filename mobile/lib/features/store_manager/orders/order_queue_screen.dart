import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class OrderQueueScreen extends ConsumerStatefulWidget {
  final Function(StoreOrder) onSelectPickingOrder;
  final Function(StoreOrder) onSelectPackingOrder;
  const OrderQueueScreen({
    super.key,
    required this.onSelectPickingOrder,
    required this.onSelectPackingOrder,
  });

  @override
  ConsumerState<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends ConsumerState<OrderQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  
  String _searchQuery = "";
  bool _filterPriorityOnly = false;
  bool _filterScheduledOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<StoreOrder> _filterAndSearch(List<StoreOrder> originalList) {
    return originalList.where((order) {
      // Search matches ID or customer name
      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter matches
      final matchesPriority = !_filterPriorityOnly || order.isPriority;
      final matchesScheduled = !_filterScheduledOnly || order.isScheduled;

      return matchesSearch && matchesPriority && matchesScheduled;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(storeManagerOrdersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Separate queues
    final pendingAndPicking = allOrders
        .where((o) => o.status == OrderFulfillmentStatus.pending || o.status == OrderFulfillmentStatus.picking)
        .toList();
    final packing = allOrders
        .where((o) => o.status == OrderFulfillmentStatus.packing)
        .toList();
    final readyAndCompleted = allOrders
        .where((o) => o.status == OrderFulfillmentStatus.readyForPickup || o.status == OrderFulfillmentStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fulfillment Queue",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: "Picking (${pendingAndPicking.length})"),
            Tab(text: "Packing (${packing.length})"),
            Tab(text: "Ready (${readyAndCompleted.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filters Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search by Order ID, customer...",
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilterChip(
                      label: const Text("Priority Orders"),
                      selected: _filterPriorityOnly,
                      onSelected: (val) => setState(() => _filterPriorityOnly = val),
                      selectedColor: Colors.red.withOpacity(0.15),
                      checkmarkColor: Colors.red,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _filterPriorityOnly ? Colors.red : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text("Scheduled"),
                      selected: _filterScheduledOnly,
                      onSelected: (val) => setState(() => _filterScheduledOnly = val),
                      selectedColor: Colors.blueAccent.withOpacity(0.15),
                      checkmarkColor: Colors.blueAccent,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _filterScheduledOnly ? Colors.blueAccent : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Main Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Picking List
                _buildOrderList(pendingAndPicking, (order) {
                  if (order.status == OrderFulfillmentStatus.pending) {
                    // Start picking first
                    ref.read(storeManagerOrdersProvider.notifier).startPicking(order.id);
                  }
                  widget.onSelectPickingOrder(order);
                }, "Start picking this order"),

                // Tab 2: Packing List
                _buildOrderList(packing, (order) {
                  widget.onSelectPackingOrder(order);
                }, "Open packing desk"),

                // Tab 3: Ready / Completed
                _buildOrderList(readyAndCompleted, (order) {
                  if (order.status == OrderFulfillmentStatus.readyForPickup) {
                    _showHandoffDialog(context, order);
                  }
                }, "Complete handoff"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<StoreOrder> rawList, Function(StoreOrder) onAction, String actionText) {
    final filteredList = _filterAndSearch(rawList);

    if (filteredList.isEmpty) {
      return const EmptyState(
        title: "No Orders Found",
        subtitle: "There are no orders matching your current filter settings.",
        icon: LucideIcons.packageOpen,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final order = filteredList[index];
        return OrderCard(
          order: order,
          onTap: () => onAction(order),
          actionButton: order.status == OrderFulfillmentStatus.completed
              ? const Icon(LucideIcons.checkCircle, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => onAction(order),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: order.status == OrderFulfillmentStatus.readyForPickup
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    order.status == OrderFulfillmentStatus.readyForPickup
                        ? "Handoff to Rider"
                        : (order.status == OrderFulfillmentStatus.pending ? "Start Picking" : "Resume"),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
        );
      },
    );
  }

  void _showHandoffDialog(BuildContext context, StoreOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Rider Handoff: ${order.id}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Verify the dispatch box label matches this order ID before giving it to the rider."),
              const SizedBox(height: 18),
              BarcodePlaceholder(value: order.barcode, label: "Dispatch label barcode"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(storeManagerOrdersProvider.notifier).handoffToRider(order.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Order ${order.id} handed off successfully!")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Confirm Handoff"),
            ),
          ],
        );
      },
    );
  }
}
