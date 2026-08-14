import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All"; // "All", "Low Stock", "Out of Stock"

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStockDialog(InventoryItem item) {
    final qtyController = TextEditingController(text: "50");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add Stock: ${item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter unit quantity to add to current stock (${item.currentStock} ${item.unit}):"),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity to Add",
                  suffixText: item.unit,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty > 0) {
                  ref.read(storeManagerInventoryProvider.notifier).addStock(item.id, qty);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Successfully added $qty ${item.unit} to ${item.name}!")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showIssueDialog(InventoryItem item) {
    final qtyController = TextEditingController(text: "1");
    bool isExpired = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Report Stock Damage / Expiry"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Report defective or unsellable stock units for '${item.name}'."),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Defective Quantity",
                      suffixText: item.unit,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Classification:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(10),
                        constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
                        isSelected: [!isExpired, isExpired],
                        onPressed: (index) {
                          setModalState(() {
                            isExpired = index == 1;
                          });
                        },
                        children: const [
                          Text("Damaged", style: TextStyle(fontSize: 12)),
                          Text("Expired", style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text) ?? 0;
                    if (qty > 0) {
                      ref.read(storeManagerInventoryProvider.notifier).reportDamagedOrExpired(item.id, qty, isExpired);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.amber[800],
                          content: Text("Reported $qty ${item.unit} of ${item.name} as ${isExpired ? 'Expired' : 'Damaged'}."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800], foregroundColor: Colors.white),
                  child: const Text("Report Issue"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showTransferDialog(InventoryItem item) {
    final qtyController = TextEditingController(text: "10");
    String selectedZone = "Cold Zone C";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Internal Stock Transfer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Initiate a physical stock relocation transfer for '${item.name}'."),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantity to Transfer",
                      suffixText: item.unit,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedZone,
                    decoration: InputDecoration(
                      labelText: "Destination Zone",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Produce Section A", child: Text("Produce Section A")),
                      DropdownMenuItem(value: "Bakery Section B", child: Text("Bakery Section B")),
                      DropdownMenuItem(value: "Cold Zone C", child: Text("Cold Zone C")),
                      DropdownMenuItem(value: "Dry Grocery D", child: Text("Dry Grocery D")),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        selectedZone = val ?? "Cold Zone C";
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text) ?? 0;
                    if (qty > 0) {
                      ref.read(storeManagerInventoryProvider.notifier).transferStock(item.id, qty, selectedZone);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Initiated transfer of $qty ${item.unit} to $selectedZone.")),
                      );
                    }
                  },
                  child: const Text("Schedule Relocation"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(storeManagerInventoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter list
    final filteredInventory = inventory.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesChip = _selectedFilter == "All" ||
          (_selectedFilter == "Low Stock" && item.status == InventoryStatus.lowStock) ||
          (_selectedFilter == "Out of Stock" && item.status == InventoryStatus.outOfStock);

      return matchesSearch && matchesChip;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search + Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search stock name, SKU, category...",
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip("All"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Low Stock"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Out of Stock"),
                  ],
                ),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: filteredInventory.isEmpty
                ? const EmptyState(
                    title: "No Catalog Items Found",
                    subtitle: "No items match your search or filters.",
                    icon: LucideIcons.package2,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredInventory.length,
                    itemBuilder: (context, index) {
                      final item = filteredInventory[index];
                      return InkWell(
                        onLongPress: () => _showTransferDialog(item),
                        child: InventoryCard(
                          item: item,
                          onAddStock: () => _showAddStockDialog(item),
                          onReportIssue: () => _showIssueDialog(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : (isDark ? Colors.white : Colors.black87),
      ),
    );
  }
}
