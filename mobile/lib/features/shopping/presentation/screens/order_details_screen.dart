import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  double _userRating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  List<TimelineStep>? _remoteTimeline;
  bool _isLoadingDetails = false;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDetailsAndTracking();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetailsAndTracking() async {
    setState(() => _isLoadingDetails = true);
    final notifier = ref.read(ordersProvider.notifier);
    await notifier.getOrderById(widget.order.id);
    final tracking = await notifier.getOrderTracking(widget.order.id);
    if (mounted) {
      setState(() {
        _remoteTimeline = tracking;
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsProvider).isDarkMode;
    final orderState = ref.watch(ordersProvider).firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Order Details #${orderState.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Delivery progress status timeline
              _buildSectionHeader('TRACK TIMELINE', isDark),
              _buildTimelineCard(orderState, isDark),
              const SizedBox(height: 16),

              // 2. Ordered Products
              _buildSectionHeader('ORDERED PRODUCTS', isDark),
              _buildProductsCard(orderState, isDark),
              const SizedBox(height: 16),

              // 3. Address & Delivery Information
              _buildSectionHeader('DELIVERY INFORMATION', isDark),
              _buildDeliveryInfoCard(orderState, isDark),
              const SizedBox(height: 16),

              // 4. Payment breakdown
              _buildSectionHeader('PAYMENT RECEIPT BREAKDOWN', isDark),
              _buildPaymentCard(orderState, isDark),
              const SizedBox(height: 20),

              // 5. Rate Order box
              if (orderState.status == OrderStatus.delivered) ...[
                _buildSectionHeader('RATE YOUR SHOPPING EXPERIENCE', isDark),
                _buildReviewSection(orderState, isDark),
                const SizedBox(height: 20),
              ],

              // 6. Action buttons for Refund or Returns
              _buildSupportActionsRow(orderState, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTimelineCard(OrderModel order, bool isDark) {
    if (_isLoadingDetails) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final List<TimelineStep> steps = [];

    if (_remoteTimeline != null && _remoteTimeline!.isNotEmpty) {
      steps.addAll(_remoteTimeline!);
    } else if (order.timeline != null && order.timeline!.isNotEmpty) {
      steps.addAll(order.timeline!);
    } else if (order.status == OrderStatus.cancelled) {
      steps.add(const TimelineStep(
        title: 'Order Cancelled',
        subtitle: 'Refund initiated back to origin account.',
        icon: Icons.cancel_outlined,
        isActive: true,
      ));
    } else if (order.status == OrderStatus.returned) {
      steps.add(const TimelineStep(
        title: 'Order Returned',
        subtitle: 'Products verified and returned to the depot.',
        icon: Icons.assignment_return_rounded,
        isActive: true,
      ));
    } else {
      steps.addAll([
        TimelineStep(
          title: 'Order Placed',
          subtitle: 'Store received your order receipt.',
          time: '12:04 PM',
          icon: Icons.receipt_long_rounded,
          isCompleted: true,
        ),
        TimelineStep(
          title: 'Products Packed & Dispatched',
          subtitle: 'Neat packing with eco-insulated seals.',
          time: '12:06 PM',
          icon: Icons.inventory_2_rounded,
          isCompleted: order.status == OrderStatus.delivered,
          isActive: order.status == OrderStatus.active,
        ),
        TimelineStep(
          title: 'Out for Fast EV Delivery',
          subtitle: 'Rider is en-route.',
          time: '12:08 PM',
          icon: Icons.electric_moped_rounded,
          isCompleted: order.status == OrderStatus.delivered,
          isActive: order.status == OrderStatus.active,
        ),
        TimelineStep(
          title: 'Arrived at Doorstep',
          subtitle: 'Handed over with sterilized guidelines.',
          time: order.status == OrderStatus.delivered ? '12:13 PM' : 'ETA 9 mins',
          icon: Icons.door_front_door_rounded,
          isActive: order.status == OrderStatus.delivered,
        ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineWidget(steps: steps),
          if (order.status == OrderStatus.active) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.map_rounded, size: 16, color: Colors.black),
              label: const Text('TRACK RIDER LIVE MAPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
              onPressed: () {
                context.push('/live-tracking', extra: order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderModel order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (context, idx) => const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(color: Color(0xFF334155))),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 52,
                  height: 52,
                  color: item.product.fallbackColor.withOpacity(0.12),
                  child: Image.network(
                    item.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${item.product.weight} • Qty: ${item.quantity}', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ),
              ),
              Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliveryInfoCard(OrderModel order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(order.deliveryAddress.icon, color: const Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                '${order.deliveryAddress.label} Address',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.deliveryAddress.recipientName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text('${order.deliveryAddress.addressLine1}, ${order.deliveryAddress.addressLine2}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text('Phone: ${order.deliveryAddress.phone}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const Divider(height: 24, color: Color(0xFF334155)),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Slot: ${order.deliverySlot}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ],
          ),
          if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.speaker_notes_rounded, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notes: "${order.deliveryInstructions}"',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderModel order, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildRow('Item Subtotal', '\$${order.subTotal.toStringAsFixed(2)}', isDark),
          _buildRow('Delivery Service Charges', order.deliveryCharges == 0.0 ? 'FREE' : '\$${order.deliveryCharges.toStringAsFixed(2)}', isDark, valueColor: order.deliveryCharges == 0.0 ? const Color(0xFF10B981) : null),
          _buildRow('Platform Fee', '\$${order.platformFee.toStringAsFixed(2)}', isDark),
          _buildRow('GST & Taxes', '\$${order.taxes.toStringAsFixed(2)}', isDark),
          if (order.discount > 0)
            _buildRow('Voucher Discount', '-\$${order.discount.toStringAsFixed(2)}', isDark, valueColor: const Color(0xFF10B981)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFF334155))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('\$${order.finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
            ],
          ),
          const Divider(height: 20, color: Color(0xFF334155)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Mode', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(order.paymentMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReviewSection(OrderModel order, bool isDark) {
    final reviewsNotifier = ref.read(ordersProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: order.rating != null
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < order.rating!.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 28,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Review: "${order.reviewText ?? "No text review written."}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isLit = index < _userRating;
                    return IconButton(
                      icon: Icon(
                        isLit ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _userRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Share feedback about the rider or product quality...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _userRating == 0.0
                      ? null
                      : () {
                          reviewsNotifier.addReview(order.id, _userRating, _reviewController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you! Review saved successfully'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('SUBMIT RATING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                )
              ],
            ),
    );
  }

  Widget _buildSupportActionsRow(OrderModel order, bool isDark) {
    if (order.status == OrderStatus.cancelled || order.status == OrderStatus.returned) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRefundReturnBottomSheet(context, order, true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRefundReturnBottomSheet(context, order, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              foregroundColor: isDark ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text('Return / Support', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showRefundReturnBottomSheet(BuildContext context, OrderModel order, bool isCancel) {
    final issues = isCancel
        ? ['Change of delivery address', 'Forgot to apply coupon', 'Delivery ETA is too long', 'Ordered wrong items by mistake']
        : ['Damaged green vegetables', 'Spilled packaging', 'Bad quality product', 'Missing item in final bag'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isCancel ? 'Request Order Cancellation' : 'Support / Request Return',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select the primary reason. Approved refunds are credited to your FlashCart wallet instantly.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...issues.map((issue) => ListTile(
                    title: Text(issue, style: const TextStyle(fontSize: 13)),
                    leading: const Icon(Icons.error_outline_rounded, size: 18),
                    onTap: () {
                      Navigator.pop(context); // close bottomsheet
                      _executeCancellationOrReturn(order, isCancel, issue);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _executeCancellationOrReturn(OrderModel order, bool isCancel, String reason) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    final notifier = ref.read(ordersProvider.notifier);
    if (isCancel) {
      final success = await notifier.cancelOrder(order.id, reason: reason);
      if (mounted) {
        setState(() => _isActionLoading = false);
        final err = ref.read(ordersProvider).errorMessage;
        if (!success || err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err ?? 'Failed to cancel order'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${order.id} cancelled successfully.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      notifier.updateOrderStatus(order.id, OrderStatus.returned);
      if (mounted) {
        setState(() => _isActionLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Return requested for #${order.id}. Support agent will reach out.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  Widget _buildRow(String label, String val, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          Text(
            val,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }
}
