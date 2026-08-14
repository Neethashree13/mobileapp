import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class PackingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinishPacking;
  const PackingScreen({super.key, required this.onFinishPacking});

  @override
  ConsumerState<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends ConsumerState<PackingScreen> {
  final Map<String, bool> _verifiedItems = {};
  
  // Packaging process checklist
  bool _coldItemsInsulated = false;
  bool _ecoTagApplied = false;
  bool _receiptPlaced = false;
  
  bool _isPrintingLabel = false;
  bool _labelPrinted = false;

  void _addSubstituteProduct(StoreOrder order, OrderItem missingItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Select Substitute Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Replace '${missingItem.productName}' with a premium equivalent:"),
              const SizedBox(height: 14),
              _buildSubstituteOption("Amul Gold Pasteurised Milk (1L)", "In Stock (Cold Zone)", () {
                _applySubstitution(order, missingItem, "Amul Gold Pasteurised Milk (1L)", "Cold Zone C - Rack 1 - Level 1", "8901234560012");
                Navigator.pop(context);
              }),
              _buildSubstituteOption("Organic Country Milk (500ml)", "In Stock (Cold Zone)", () {
                _applySubstitution(order, missingItem, "Organic Country Milk (500ml)", "Cold Zone C - Rack 1 - Level 3", "8901234560034");
                Navigator.pop(context);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _applySubstitution(StoreOrder order, OrderItem item, String subName, String subLocation, String subBarcode) {
    // Modify picked details to the replacement item in provider
    ref.read(storeManagerOrdersProvider.notifier).updatePickedQuantity(order.id, item.id, 0); // Reset old
    final updatedItem = item.copyWith(
      productName: "[SUBSTITUTE] $subName",
      shelfLocation: subLocation,
      pickedQuantity: item.quantity,
      isPicked: true,
      barcode: subBarcode,
    );
    
    // Replace item in active packing order and trigger sync
    final updatedItems = order.items.map((i) => i.id == item.id ? updatedItem : i).toList();
    final updatedOrder = order.copyWith(items: updatedItems);
    
    ref.read(storeManagerActivePackingProvider.notifier).setActive(updatedOrder);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Substituted $subName successfully!")),
    );
  }

  Widget _buildSubstituteOption(String name, String stockInfo, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(stockInfo, style: const TextStyle(fontSize: 11, color: Colors.green)),
        trailing: const Icon(LucideIcons.plus, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _simulatePrintLabel() async {
    setState(() => _isPrintingLabel = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isPrintingLabel = false;
      _labelPrinted = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dispatch label printed & applied!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeOrder = ref.watch(storeManagerActivePackingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activeOrder == null) {
      return const Scaffold(
        body: EmptyState(
          title: "No Active Packing Session",
          subtitle: "Select an order ready for packing to load the packing desk.",
          icon: LucideIcons.archive,
        ),
      );
    }

    // Initialize item checklist states
    for (var item in activeOrder.items) {
      if (!_verifiedItems.containsKey(item.id)) {
        _verifiedItems[item.id] = false;
      }
    }

    final hasMissingItems = activeOrder.items.any((i) => i.pickedQuantity == 0);
    final allItemsVerified = activeOrder.items.every((item) {
      // If item is completely missing, it doesn't need checklist verification
      if (item.pickedQuantity == 0) return true;
      return _verifiedItems[item.id] == true;
    });

    final readyToDispatch = allItemsVerified && _coldItemsInsulated && _ecoTagApplied && _receiptPlaced && _labelPrinted;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Packing Station • ${activeOrder.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Awaiting box carton allocation", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.red),
            onPressed: () {
              ref.read(storeManagerActivePackingProvider.notifier).clear();
            },
            tooltip: "Close Packing Session",
          )
        ],
      ),
      body: Row(
        children: [
          // Left Column: Items Verification Checklist (flex 5)
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1. Verify Picked Quantities", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeOrder.items.length,
                    itemBuilder: (context, index) {
                      final item = activeOrder.items[index];
                      final isMissing = item.pickedQuantity == 0;
                      final isChecked = _verifiedItems[item.id] ?? false;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15)),
                        ),
                        color: isMissing
                            ? (isDark ? const Color(0xFF2A1515) : const Color(0xFFFFEEEE))
                            : (isChecked ? (isDark ? const Color(0xFF13221B) : const Color(0xFFEEFBF4)) : (isDark ? const Color(0xFF161A22) : Colors.white)),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 44,
                                  height: 44,
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
                                        color: isMissing ? Colors.red : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    isMissing
                                        ? Row(
                                            children: [
                                              const Text("Item Missing!", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () => _addSubstituteProduct(activeOrder, item),
                                                child: const Text("Replace with substitute", style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                              )
                                            ],
                                          )
                                        : Text(
                                            "Qty: ${item.pickedQuantity} / ${item.quantity}  •  ${item.shelfLocation}",
                                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                          ),
                                  ],
                                ),
                              ),
                              if (!isMissing)
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (val) {
                                    setState(() {
                                      _verifiedItems[item.id] = val ?? false;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Right Column: Pack Checklist & Label Printer (flex 4)
          Expanded(
            flex: 4,
            child: Container(
              color: isDark ? const Color(0xFF0F111A) : Colors.grey[50],
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("2. Quality & Packing Steps", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Verification items list
                  _buildPackingCheckItem(
                    "Cold Insulation Sleeve",
                    "Pack milk & cold dairy items in thermal liners.",
                    _coldItemsInsulated,
                    (val) => setState(() => _coldItemsInsulated = val ?? false),
                  ),
                  _buildPackingCheckItem(
                    "Apply Eco-friendly Tag",
                    "Secure carton handle with flashcart branded tie-ons.",
                    _ecoTagApplied,
                    (val) => setState(() => _ecoTagApplied = val ?? false),
                  ),
                  _buildPackingCheckItem(
                    "Place Printed Invoice Receipt",
                    "Fold and drop receipt in the outer container slot.",
                    _receiptPlaced,
                    (val) => setState(() => _receiptPlaced = val ?? false),
                  ),
                  const Divider(height: 32),

                  const Text("3. Bag Labeling Station", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  _labelPrinted
                      ? BarcodePlaceholder(value: activeOrder.barcode, label: "Bag label applied")
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(LucideIcons.printer, size: 32, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text("Bag Label Ready", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              const Text("Print the dispatch barcode and paste it onto the bag carton.", style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: _isPrintingLabel ? null : _simulatePrintLabel,
                                icon: const Icon(LucideIcons.printer, size: 16),
                                label: Text(_isPrintingLabel ? "Printing Label..." : "Print Box Label"),
                              ),
                            ],
                          ),
                        ),
                  
                  const Spacer(),
                  ElevatedButton(
                    onPressed: readyToDispatch
                        ? () {
                            ref.read(storeManagerOrdersProvider.notifier).finishPacking(activeOrder.id);
                            ref.read(storeManagerActivePackingProvider.notifier).clear();
                            widget.onFinishPacking();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Order ${activeOrder.id} packed! Ready for rider handoff."),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Ready for Rider Dispatch", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingCheckItem(String title, String desc, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
