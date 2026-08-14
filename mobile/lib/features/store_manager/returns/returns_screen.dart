import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/store_manager_providers.dart';
import '../models/store_manager_models.dart';
import '../widgets/store_manager_widgets.dart';

class ReturnsScreen extends ConsumerWidget {
  const ReturnsScreen({super.key});

  void _processReturnDialog(BuildContext context, WidgetRef ref, ReturnedItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Inspect Return: ${item.id}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item: ${item.productName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text("Reason: ${item.reason}", style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text("Perform physical product inspection. Select matching outcome to process refund:"),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                // Reject return
                ref.read(storeManagerReturnsProvider.notifier).processRefund(item.id, ReturnStatus.rejected);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Return rejected. Item does not meet return policy.")),
                );
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Reject"),
            ),
            ElevatedButton(
              onPressed: () {
                // Pass inspection but log damaged
                ref.read(storeManagerReturnsProvider.notifier).processRefund(item.id, ReturnStatus.inspectedDamaged);
                // Also automatically deduct stock in central inventory
                final inventory = ref.read(storeManagerInventoryProvider);
                final matchedInvItem = inventory.firstWhere((i) => i.name.contains(item.productName) || item.productName.contains(i.name), orElse: () => inventory.first);
                ref.read(storeManagerInventoryProvider.notifier).reportDamagedOrExpired(matchedInvItem.id, item.quantity, false);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as Defective. Stock log updated & refund initiated.")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text("Damaged/Dispose"),
            ),
            ElevatedButton(
              onPressed: () {
                // Pass inspection & restock
                ref.read(storeManagerReturnsProvider.notifier).processRefund(item.id, ReturnStatus.refunded);
                final inventory = ref.read(storeManagerInventoryProvider);
                final matchedInvItem = inventory.firstWhere((i) => i.name.contains(item.productName) || item.productName.contains(i.name), orElse: () => inventory.first);
                ref.read(storeManagerInventoryProvider.notifier).addStock(matchedInvItem.id, item.quantity);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Inspected OK. Item restocked to shelf & wallet refunded!")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Restock & Refund"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(storeManagerReturnsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Returns & Quality Audit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: returns.isEmpty
          ? const EmptyState(
              title: "Zero Pending Returns",
              subtitle: "All returned merchandise has been inspected and cataloged.",
              icon: LucideIcons.thumbsUp,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: returns.length,
              itemBuilder: (context, index) {
                final item = returns[index];
                
                Color statusColor;
                String statusLabel;
                switch (item.status) {
                  case ReturnStatus.pendingInspection:
                    statusColor = Colors.orange;
                    statusLabel = "Awaiting Inspection";
                    break;
                  case ReturnStatus.inspectedPassed:
                    statusColor = Colors.green;
                    statusLabel = "Passed (Unopened)";
                    break;
                  case ReturnStatus.inspectedDamaged:
                    statusColor = Colors.redAccent;
                    statusLabel = "Defective (Logged)";
                    break;
                  case ReturnStatus.refunded:
                    statusColor = Colors.teal;
                    statusLabel = "Refunded & Settled";
                    break;
                  case ReturnStatus.rejected:
                    statusColor = Colors.grey;
                    statusLabel = "Refund Rejected";
                    break;
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15)),
                  ),
                  color: isDark ? const Color(0xFF161A22) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusBadge(label: statusLabel, baseColor: statusColor),
                                  Text(
                                    item.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Reason: ${item.reason}",
                                style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Order ID: ${item.orderId}  •  Refund: ₹${item.refundAmount.toStringAsFixed(0)}",
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                              if (item.status == ReturnStatus.pendingInspection) ...[
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _processReturnDialog(context, ref, item),
                                      icon: const Icon(LucideIcons.clipboardCheck, size: 14),
                                      label: const Text("Begin Quality Check", style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                  ],
                                )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
