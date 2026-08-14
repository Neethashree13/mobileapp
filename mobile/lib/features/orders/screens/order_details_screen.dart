import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_timeline_widget.dart';
import '../../home/models/home_models.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final dynamic order;
  final String? orderId;

  const OrderDetailsScreen({
    super.key,
    this.order,
    this.orderId,
  });

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isCancelling = false;

  Future<void> _handleCancelOrder(OrderModel targetOrder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order?'),
        content: Text('Are you sure you want to cancel order ${targetOrder.orderNumber}? Refund will be processed automatically if paid.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    final controller = ref.read(ordersControllerProvider.notifier);
    final success = await controller.cancelOrder(targetOrder.id);

    if (mounted) {
      setState(() {
        _isCancelling = false;
      });
      if (success) {
        ref.invalidate(ordersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.order != null) {
      if (widget.order is OrderModel) {
        return _buildDetailsUI(context, widget.order as OrderModel, isDark);
      }
    }

    final id = (widget.order != null ? (widget.order as dynamic).id?.toString() : null) ?? widget.orderId ?? '';
    final asyncOrder = ref.watch(orderDetailsProvider(id));

    return asyncOrder.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Text(
            'Error loading order: ${err.toString()}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      data: (order) => _buildDetailsUI(context, order, isDark),
    );
  }

  Widget _buildDetailsUI(BuildContext context, OrderModel order, bool isDark) {
    final canCancel = order.status.isCancellable;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Order ${order.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: order.status.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: order.status.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: order.status.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text(
                          order.status.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: order.status.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated Delivery: ${order.estimatedDeliveryTime}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Vertical Timeline
            _buildSectionCard(
              isDark: isDark,
              title: 'Order Tracking Timeline',
              icon: Icons.timeline_rounded,
              child: OrderTimelineWidget(currentStatus: order.status),
            ),
            const SizedBox(height: 20),

            // Ordered Products List
            _buildSectionCard(
              isDark: isDark,
              title: 'Ordered Products (${order.items.length})',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: order.items.map((item) {
                  final fallbackImg = Product.getCategoryFallbackImage(item.productName, 'grocery');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            child: Image.network(
                              item.image.isNotEmpty && item.image.startsWith('http')
                                  ? item.image
                                  : fallbackImg,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.network(fallbackImg, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.quantity} x ₹${item.price.toStringAsFixed(2)} (${item.unit})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Address Card
            _buildSectionCard(
              isDark: isDark,
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    order.deliveryAddress.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.deliveryAddress.fullAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        order.deliveryAddress.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Details & Order Summary Card
            _buildSectionCard(
              isDark: isDark,
              title: 'Payment & Summary',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _buildSummaryRow(isDark, 'Payment Method', order.paymentMethod.label),
                  _buildSummaryRow(isDark, 'Payment Status', order.paymentStatus.label, valueColor: order.paymentStatus == PaymentStatusEnum.Paid ? const Color(0xFF10B981) : Colors.amber),
                  const Divider(height: 20),
                  _buildSummaryRow(isDark, 'Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                  if (order.discount > 0)
                    _buildSummaryRow(isDark, 'Discount', '-₹${order.discount.toStringAsFixed(2)}', valueColor: Colors.green),
                  _buildSummaryRow(isDark, 'Delivery Fee', '₹${order.deliveryFee.toStringAsFixed(2)}'),
                  _buildSummaryRow(isDark, 'Tax', '₹${order.tax.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '₹${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Order Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: canCancel && !_isCancelling
                    ? () => _handleCancelOrder(order)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCancel ? Colors.redAccent : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  disabledForegroundColor: Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isCancelling
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(canCancel ? Icons.cancel_outlined : Icons.block_rounded),
                label: Text(
                  _isCancelling
                      ? 'Cancelling...'
                      : (canCancel
                          ? 'Cancel Order'
                          : 'Cancellation Closed (${order.status.label})'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(bool isDark, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
