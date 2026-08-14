import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({super.key});

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen> {
  String _selectedZoneCode = "A";

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(storeManagerWarehouseZonesProvider);
    final shelves = ref.watch(storeManagerWarehouseShelvesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedZone = zones.firstWhere((z) => z.code == _selectedZoneCode);
    final zoneShelves = shelves.where((s) => s.zone == _selectedZoneCode).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Warehouse Map", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Store Blueprint Visual Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.black12.withOpacity(0.05)),
              ),
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.map, size: 18, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          "Dark Store Floor Plan Overview",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Graphical Grid blueprint
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withOpacity(0.24) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: zones.map((z) {
                          final isCurrent = z.code == _selectedZoneCode;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedZoneCode = z.code),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.withOpacity(0.2),
                                    width: isCurrent ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "ZONE ${z.code}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? Theme.of(context).colorScheme.primary
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${z.shelfCount} shelves",
                                      style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Zone Header
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "ZONE ${selectedZone.code}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedZone.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        selectedZone.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Shelf rack allocation list
            const Text(
              "Shelf Levels & Capacity Allocation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            zoneShelves.isEmpty
                ? const EmptyState(
                    title: "No Shelves Configured",
                    subtitle: "This zone layout is currently empty or awaiting rack assembly.",
                    icon: LucideIcons.layout,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: zoneShelves.length,
                    itemBuilder: (context, index) {
                      final shelf = zoneShelves[index];
                      return ShelfCard(
                        shelf: shelf,
                        onTap: () {
                          // Drilldown to shelf details alert
                          _showShelfDetail(context, shelf);
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showShelfDetail(BuildContext context, WarehouseShelf shelf) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Shelf Location: ${shelf.code}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Rack Location Detail:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text("• Zone: ${shelf.zone}\n• Rack Row: ${shelf.rackNumber}\n• Shelf Level: Height Level ${shelf.level}", style: const TextStyle(fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              Text("Current Items Stored (${shelf.itemNames.length}):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: shelf.itemNames.map((name) {
                  return Chip(
                    label: Text(name, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
