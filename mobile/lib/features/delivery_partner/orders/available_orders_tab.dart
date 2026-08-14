import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../providers/delivery_partner_providers.dart';
import '../models/delivery_partner_models.dart';
import '../widgets/delivery_partner_widgets.dart';

// Import overlays
import '../navigation/delivery_navigation_overlay.dart';
import '../pickup/pickup_workflow_overlay.dart';
import '../delivery/delivery_workflow_overlay.dart';

class AvailableOrdersTab extends ConsumerStatefulWidget {
  const AvailableOrdersTab({super.key});

  @override
  ConsumerState<AvailableOrdersTab> createState() => _AvailableOrdersTabState();
}

class _AvailableOrdersTabState extends ConsumerState<AvailableOrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(deliveryPartnerDutyStatusProvider);
    final activeOrder = ref.watch(deliveryPartnerActiveOrderProvider);
    final availableOrders = ref.watch(deliveryPartnerAvailableOrdersProvider);

    // If there is an active delivery, we render the live routing/workflow panel!
    if (activeOrder != null) {
      return _buildActiveWorkflowContainer(activeOrder);
    }

    if (!isOnline) {
      return const Scaffold(
        body: EmptyStateWidget(
          title: 'You are Offline',
          message: 'Please toggle your Duty Status "Online" from the Dashboard tab to search, receive and accept delivery orders.',
          icon: LucideIcons.cloudOff,
        ),
      );
    }

    // Split orders into nearby (distance < 3km), scheduled (fake), and priority (distance >= 3km or high earning)
    final nearbyGigs = availableOrders.where((o) => o.distance < 4).toList();
    final priorityGigs = availableOrders.where((o) => o.distance >= 4 || o.expectedEarnings >= 150).toList();
    final scheduledGigs = <DeliveryOrder>[]; // Empty mock scheduled list

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Delivery Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            Tab(text: 'Nearby (${nearbyGigs.length})'),
            Tab(text: 'Priority (${priorityGigs.length})'),
            Tab(text: 'Scheduled (${scheduledGigs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(nearbyGigs),
          _buildOrdersList(priorityGigs),
          _buildOrdersList(scheduledGigs, isScheduled: true),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<DeliveryOrder> orders, {bool isScheduled = false}) {
    if (orders.isEmpty) {
      return EmptyStateWidget(
        title: isScheduled ? 'No Scheduled Gigs' : 'All Clear!',
        message: isScheduled 
            ? 'You don\'t have any pre-booked or scheduled delivery slots for today.'
            : 'You have completed or reviewed all local orders in this sector. Awesome work!',
        icon: isScheduled ? LucideIcons.calendar : LucideIcons.checkSquare,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onAccept: () {
            ref.read(deliveryPartnerActiveOrderProvider.notifier).acceptOrder(order);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚡ Accepted Order ${order.orderId}! Navigation started.'),
                backgroundColor: Colors.teal,
              ),
            );
          },
          onReject: () {
            ref.read(deliveryPartnerAvailableOrdersProvider.notifier).removeOrder(order.orderId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gig offer dismissed.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  // Active Workflow Engine (Navigation, Store Pickup, and Customer Delivery overlays)
  Widget _buildActiveWorkflowContainer(DeliveryOrder activeOrder) {
    switch (activeOrder.status) {
      case DeliveryStatus.accepted:
        // Rider is en-route to store
        return DeliveryNavigationOverlay(
          activeOrder: activeOrder,
          title: 'Navigate to Hub Store',
          subtitle: activeOrder.storeAddress,
          ctaLabel: 'Confirm Arrival at Store',
          onNext: () {
            ref.read(deliveryPartnerActiveOrderProvider.notifier).updateStatus(DeliveryStatus.reachedStore);
          },
        );

      case DeliveryStatus.reachedStore:
        // Rider is verifying items at the store
        return PickupWorkflowOverlay(
          activeOrder: activeOrder,
          onNext: () {
            ref.read(deliveryPartnerActiveOrderProvider.notifier).updateStatus(DeliveryStatus.pickedUp);
          },
        );

      case DeliveryStatus.pickedUp:
        // Rider has loaded items and is en-route to customer
        return DeliveryNavigationOverlay(
          activeOrder: activeOrder,
          title: 'Navigate to Customer',
          subtitle: activeOrder.customerAddress,
          ctaLabel: 'Confirm Arrival at Customer',
          onNext: () {
            ref.read(deliveryPartnerActiveOrderProvider.notifier).updateStatus(DeliveryStatus.reachedCustomer);
          },
        );

      case DeliveryStatus.reachedCustomer:
        // Rider is at customer's doorstep completing verification
        return DeliveryWorkflowOverlay(
          activeOrder: activeOrder,
          onNext: (double tip, double bonus) {
            ref.read(deliveryPartnerActiveOrderProvider.notifier).completeActiveOrder(tip, bonus);
          },
        );

      default:
        return const Scaffold(
          body: Center(child: Text('Loading workflow...')),
        );
    }
  }
}
