import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class PickingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinishPicking;
  const PickingScreen({super.key, required this.onFinishPicking});

  @override
  ConsumerState<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends ConsumerState<PickingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  
  String? _selectedItemId;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_progressController);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _simulateScan(StoreOrder order, OrderItem item) async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final currentPicked = item.pickedQuantity;
    if (currentPicked < item.quantity) {
      final newPicked = currentPicked + 1;
      // Update local provider
      ref.read(storeManagerActivePickingProvider.notifier).updateItemPicked(item.id, newPicked);
      // Synchronize back to central order queue state
      ref.read(storeManagerOrdersProvider.notifier).updatePickedQuantity(order.id, item.id, newPicked);
    }

    setState(() => _isScanning = false);

    // Auto-select next unpicked item
    final updatedOrder = ref.read(storeManagerActivePickingProvider);
    if (updatedOrder != null) {
      final nextUnpicked = updatedOrder.items.firstWhere(
        (i) => i.pickedQuantity < i.quantity,
        orElse: () => updatedOrder.items.first,
      );
      setState(() {
        _selectedItemId = nextUnpicked.id;
      });
    }
  }

  void _reportMissingItem(StoreOrder order, OrderItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Report Missing Item"),
          content: Text("Confirm that '${item.productName}' is out of stock at '${item.shelfLocation}'. This will flag the shelf location for immediate audit and prompt substitution options at packing."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Update picked quantity to 0 and trigger stock alert notification
                ref.read(storeManagerOrdersProvider.notifier).updatePickedQuantity(order.id, item.id, 0);
                ref.read(storeManagerActivePickingProvider.notifier).updateItemPicked(item.id, 0);
                
                // Add manager announcement notification
                ref.read(storeManagerNotificationsProvider.notifier).markAllRead(); // Dummy write
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Alert flagged for ${item.productName}! Shelf location logged for audit."),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("Flag Missing"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrder = ref.watch(storeManagerActivePickingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activeOrder == null) {
      return const Scaffold(
        body: EmptyState(
          title: "No Active Picking Session",
          subtitle: "Select an order from the Fulfillment Queue to begin shelf picking.",
          icon: LucideIcons.shoppingBag,
        ),
      );
    }

    // Auto-select first item if none selected
    if (_selectedItemId == null && activeOrder.items.isNotEmpty) {
      _selectedItemId = activeOrder.items.first.id;
    }

    final selectedItem = activeOrder.items.firstWhere(
      (i) => i.id == _selectedItemId,
      orElse: () => activeOrder.items.first,
    );

    final totalItemsToPick = activeOrder.totalItemsCount;
    final totalItemsPicked = activeOrder.pickedItemsCount;
    final isCompleted = totalItemsPicked == totalItemsToPick;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Picking Slot • ${activeOrder.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Customer: ${activeOrder.customerName}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.red),
            onPressed: () {
              ref.read(storeManagerActivePickingProvider.notifier).clear();
            },
            tooltip: "Cancel Picking Session",
          )
        ],
      ),
      body: Column(
        children: [
          // Pick Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF161A22) : Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Picking Progress",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    Text(
                      "$totalItemsPicked / $totalItemsToPick Items Checked",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: activeOrder.pickProgress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white.withOpacity(0.10) : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Main body containing checklist & barcode scanner placeholder
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Items Checklist (flex 4)
                Expanded(
                  flex: 4,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: activeOrder.items.length,
                    itemBuilder: (context, index) {
                      final item = activeOrder.items[index];
                      final isSelected = item.id == _selectedItemId;
                      final isPicked = item.isPicked;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        color: isSelected
                            ? (isDark ? const Color(0xFF1C142E) : const Color(0xFFF3E8FF))
                            : (isDark ? const Color(0xFF161A22) : Colors.white),
                        child: InkWell(
                          onTap: () => setState(() => _selectedItemId = item.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          decoration: isPicked ? TextDecoration.lineThrough : null,
                                          color: isPicked ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.shelfLocation,
                                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Required: ${item.quantity}  •  Picked: ${item.pickedQuantity}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPicked ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isPicked ? LucideIcons.checkCircle2 : LucideIcons.circle,
                                  color: isPicked ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Column: Active Item Scan Desk (flex 5 - Hidden or scrollable depending on screen size)
                if (MediaQuery.of(context).size.width > 500)
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15)),
                        ),
                        color: isDark ? const Color(0xFF0F111A) : Colors.grey[50],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: isCompleted
                          ? _buildCongratulatoryDesk(activeOrder)
                          : _buildActiveScanDesk(activeOrder, selectedItem, isDark),
                    ),
                  ),
              ],
            ),
          ),

          // For small screens, show active desk at the bottom as a sheet if not completed
          if (MediaQuery.of(context).size.width <= 500)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161A22) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
              ),
              child: isCompleted
                  ? ElevatedButton(
                      onPressed: () {
                        ref.read(storeManagerOrdersProvider.notifier).finishPicking(activeOrder.id);
                        ref.read(storeManagerActivePickingProvider.notifier).clear();
                        widget.onFinishPicking();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                      child: const Text("All Done - Move to Packing Screen", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Active target: ${selectedItem.productName}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _reportMissingItem(activeOrder, selectedItem),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text("Flag Missing"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isScanning ? null : () => _simulateScan(activeOrder, selectedItem),
                                icon: const Icon(LucideIcons.barcode, size: 16),
                                label: Text(_isScanning ? "Scanning..." : "Simulate Scan"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            )
        ],
      ),
    );
  }

  Widget _buildActiveScanDesk(StoreOrder order, OrderItem item, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            item.imageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          item.productName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          "Location: ${item.shelfLocation}",
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 18),
        
        // Barcode Placeholder with Pulsing Scanning effect
        _isScanning
            ? ScaleTransition(
                scale: _pulseAnimation,
                child: BarcodePlaceholder(value: item.barcode, label: "Scanning Barcode..."),
              )
            : BarcodePlaceholder(value: item.barcode, label: "Target Product Barcode"),
            
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _reportMissingItem(order, item),
                icon: const Icon(LucideIcons.alertTriangle, size: 16),
                label: const Text("Item Missing"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : () => _simulateScan(order, item),
                icon: const Icon(LucideIcons.scanLine, size: 16),
                label: Text(_isScanning ? "Matching..." : "Simulate Scan"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCongratulatoryDesk(StoreOrder order) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.partyPopper,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Picking Complete!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "All items for this order are checked, scanned, and secure. Send this tote to the Packing Desk.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(storeManagerOrdersProvider.notifier).finishPicking(order.id);
                ref.read(storeManagerActivePickingProvider.notifier).clear();
                widget.onFinishPicking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Mark Ready for Packing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
