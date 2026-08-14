import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderTimelineStepItem {
  final OrderStatusEnum status;
  final String title;
  final String description;
  final IconData icon;

  const OrderTimelineStepItem({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OrderTimelineWidget extends StatelessWidget {
  final OrderStatusEnum currentStatus;

  const OrderTimelineWidget({
    super.key,
    required this.currentStatus,
  });

  static const List<OrderTimelineStepItem> _allSteps = [
    OrderTimelineStepItem(
      status: OrderStatusEnum.Placed,
      title: 'Order Placed',
      description: 'Your order has been received by FlashCart AI Engine',
      icon: Icons.check_circle_outline_rounded,
    ),
    OrderTimelineStepItem(
      status: OrderStatusEnum.Confirmed,
      title: 'Confirmed',
      description: 'Inventory reserved & fulfillment store notified',
      icon: Icons.verified_outlined,
    ),
    OrderTimelineStepItem(
      status: OrderStatusEnum.Preparing,
      title: 'Preparing',
      description: 'Store associate picking items from shelves',
      icon: Icons.inventory_2_outlined,
    ),
    OrderTimelineStepItem(
      status: OrderStatusEnum.Packed,
      title: 'Packed',
      description: 'Items sealed & eco-friendly packed for dispatch',
      icon: Icons.card_giftcard_outlined,
    ),
    OrderTimelineStepItem(
      status: OrderStatusEnum.OutForDelivery,
      title: 'Out for Delivery',
      description: 'Assigned to Express Delivery Rider',
      icon: Icons.delivery_dining_outlined,
    ),
    OrderTimelineStepItem(
      status: OrderStatusEnum.Delivered,
      title: 'Delivered',
      description: 'Package delivered safely to your address',
      icon: Icons.home_work_outlined,
    ),
  ];

  int _getStepIndex(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.Placed:
        return 0;
      case OrderStatusEnum.Confirmed:
        return 1;
      case OrderStatusEnum.Preparing:
        return 2;
      case OrderStatusEnum.Packed:
        return 3;
      case OrderStatusEnum.OutForDelivery:
        return 4;
      case OrderStatusEnum.Delivered:
        return 5;
      case OrderStatusEnum.Cancelled:
      case OrderStatusEnum.Returned:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentIndex = _getStepIndex(currentStatus);

    if (currentStatus == OrderStatusEnum.Cancelled || currentStatus == OrderStatusEnum.Returned) {
      final isCancelled = currentStatus == OrderStatusEnum.Cancelled;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isCancelled ? Colors.red : Colors.grey).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (isCancelled ? Colors.red : Colors.grey).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isCancelled ? Icons.cancel_outlined : Icons.assignment_return_outlined,
              color: isCancelled ? Colors.red : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    isCancelled ? 'Order Cancelled' : 'Order Returned',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isCancelled ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCancelled
                        ? 'This order has been cancelled and refund initiated if applicable.'
                        : 'This order has been returned to the dark store.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_allSteps.length, (index) {
        final step = _allSteps[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isFuture = index > currentIndex;

        Color circleColor;
        Color iconColor;
        if (isCompleted) {
          circleColor = const Color(0xFF10B981); // Green
          iconColor = Colors.white;
        } else if (isCurrent) {
          circleColor = const Color(0xFF3B82F6); // Blue
          iconColor = Colors.white;
        } else {
          circleColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0); // Grey
          iconColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
        }

        final isLast = index == _allSteps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              // Column for Circle & Line
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : step.icon,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: index < currentIndex
                            ? const Color(0xFF10B981)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Step details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isCurrent
                                      ? const Color(0xFF3B82F6)
                                      : (isDark ? Colors.grey[400] : Colors.grey[600])),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'In Progress',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
