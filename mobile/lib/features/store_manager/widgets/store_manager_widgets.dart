import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/store_manager_models.dart';

// ---------------------------------------------------------
// 1. Status Badge
// ---------------------------------------------------------
class StatusBadge extends StatelessWidget {
  final String label;
  final Color baseColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.baseColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: baseColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: baseColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. KPI Card
// ---------------------------------------------------------
class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. Order Card
// ---------------------------------------------------------
class OrderCard extends StatelessWidget {
  final StoreOrder order;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (order.status) {
      case OrderFulfillmentStatus.pending:
        statusColor = order.isPriority ? Colors.red : Colors.orange;
        statusLabel = "Waiting in Queue";
        statusIcon = LucideIcons.hourglass;
        break;
      case OrderFulfillmentStatus.picking:
        statusColor = Colors.blue;
        statusLabel = "Picking Items";
        statusIcon = LucideIcons.packageCheck;
        break;
      case OrderFulfillmentStatus.packing:
        statusColor = Colors.purple;
        statusLabel = "In Packing Queue";
        statusIcon = LucideIcons.archive;
        break;
      case OrderFulfillmentStatus.readyForPickup:
        statusColor = Colors.teal;
        statusLabel = "Ready for Dispatch";
        statusIcon = LucideIcons.bike;
        break;
      case OrderFulfillmentStatus.completed:
        statusColor = Colors.green;
        statusLabel = "Completed";
        statusIcon = LucideIcons.checkCircle;
        break;
    }

    final duration = DateTime.now().difference(order.orderTime);
    String timeAgo = duration.inMinutes < 60
        ? "${duration.inMinutes}m ago"
        : "${duration.inHours}h ago";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15),
          width: order.isPriority ? 1.5 : 1,
        ),
      ),
      color: order.isPriority
          ? (isDark ? const Color(0xFF2D1619) : const Color(0xFFFFECEE))
          : (isDark ? const Color(0xFF161A22) : Colors.white),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (order.isPriority) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "PRIORITY",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (order.isScheduled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "SCHEDULED",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Items Total",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${order.totalItemsCount} items • ₹${order.totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (order.isScheduled && order.scheduledTime != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text(
                      "Delivery Slot: ${order.scheduledTime}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: statusLabel,
                    baseColor: statusColor,
                    icon: statusIcon,
                  ),
                  if (actionButton != null) actionButton!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. Inventory Card
// ---------------------------------------------------------
class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onAddStock;
  final VoidCallback? onReportIssue;

  const InventoryCard({
    super.key,
    required this.item,
    this.onAddStock,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    String statusLabel;
    switch (item.status) {
      case InventoryStatus.normal:
        badgeColor = Colors.green;
        statusLabel = "In Stock";
        break;
      case InventoryStatus.lowStock:
        badgeColor = Colors.orange;
        statusLabel = "Low Stock";
        break;
      case InventoryStatus.outOfStock:
        badgeColor = Colors.red;
        statusLabel = "Out of Stock";
        break;
      case InventoryStatus.damaged:
        badgeColor = Colors.deepOrange;
        statusLabel = "Damaged Reported";
        break;
      case InventoryStatus.expired:
        badgeColor = Colors.brown;
        statusLabel = "Expired Reported";
        break;
      case InventoryStatus.transferring:
        badgeColor = Colors.blue;
        statusLabel = "In Transit";
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15),
        ),
      ),
      color: isDark ? const Color(0xFF161A22) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with ReferrerPolicy safe load
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 68,
                    height: 68,
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                    child: const Icon(LucideIcons.image, size: 24),
                  );
                },
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
                      StatusBadge(label: statusLabel, baseColor: badgeColor),
                      Text(
                        item.sku,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "${item.shelfLocation}  •  ",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Price: ₹${item.price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Stock Count: ${item.currentStock} ${item.unit}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: item.currentStock <= item.lowStockThreshold
                              ? Colors.red
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      Row(
                        children: [
                          if (onReportIssue != null) ...[
                            IconButton(
                              onPressed: onReportIssue,
                              icon: const Icon(LucideIcons.alertTriangle, size: 18),
                              color: Colors.amber,
                              tooltip: "Report issue",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (onAddStock != null) ...[
                            ElevatedButton.icon(
                              onPressed: onAddStock,
                              icon: const Icon(LucideIcons.plus, size: 14),
                              label: const Text("Add Stock", style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. Shelf Card
// ---------------------------------------------------------
class ShelfCard extends StatelessWidget {
  final WarehouseShelf shelf;
  final VoidCallback? onTap;

  const ShelfCard({
    super.key,
    required this.shelf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color progressColor;
    if (shelf.capacityPercent < 50) {
      progressColor = Colors.green;
    } else if (shelf.capacityPercent < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.withOpacity(0.15),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.layers, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shelf.code,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Capacity: ${shelf.capacityPercent}%",
                    style: TextStyle(
                      fontSize: 12,
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: shelf.capacityPercent / 100,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Text(
                "Contents:",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: shelf.itemNames.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. Progress Stepper
// ---------------------------------------------------------
class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(steps.length, (index) {
        final isDone = index < currentStep;
        final isActive = index == currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDone
                          ? Colors.green
                          : (isActive ? primary : (isDark ? Colors.white10 : Colors.grey[200])),
                      child: isDone
                          ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? primary
                            : (isDone ? Colors.green : (isDark ? Colors.grey[500] : Colors.grey[600])),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 24,
                  height: 2,
                  color: isDone ? Colors.green : (isDark ? Colors.white10 : Colors.grey[300]),
                  margin: const EdgeInsets.only(bottom: 14),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------
// 7. Barcode Placeholder
// ---------------------------------------------------------
class BarcodePlaceholder extends StatelessWidget {
  final String value;
  final String? label;

  const BarcodePlaceholder({
    super.key,
    required this.value,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Generate pseudo barcode bars
          SizedBox(
            height: 48,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(40, (index) {
                final isSpace = index % 3 == 0 || index == 11 || index == 21 || index == 29;
                final width = (index % 4 == 0) ? 4.0 : 2.0;
                
                return isSpace
                    ? const SizedBox(width: 3)
                    : Container(
                        width: width,
                        height: double.infinity,
                        color: isDark ? Colors.white70 : Colors.black87,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 8. Empty State
// ---------------------------------------------------------
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = LucideIcons.packageOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 9. Loading State
// ---------------------------------------------------------
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({
    super.key,
    this.message = "Loading store activities...",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 10. Error State
// ---------------------------------------------------------
class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Something Went Wrong",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
