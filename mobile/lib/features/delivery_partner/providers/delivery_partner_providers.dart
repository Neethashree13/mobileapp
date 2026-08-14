import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_partner_models.dart';

// Duty Status (Online / Offline)
final deliveryPartnerDutyStatusProvider = StateProvider<bool>((ref) => true);

// Available Orders State
class AvailableOrdersNotifier extends StateNotifier<List<DeliveryOrder>> {
  AvailableOrdersNotifier() : super(_initialAvailableOrders);

  static final List<DeliveryOrder> _initialAvailableOrders = [
    const DeliveryOrder(
      orderId: 'FC-9482',
      customerName: 'Arav Sharma',
      customerPhone: '+91 94821 02931',
      customerAddress: 'Apt 4B, Shanti Enclave, Sector 45, Gurgaon',
      storeName: 'FlashCart Superstore (DLF Phase 3)',
      storePhone: '+91 124 492019',
      storeAddress: 'DLF Cyber City, Phase 3, Gurgaon',
      items: [
        ProductItem(name: 'Amul Gold Milk 1L', quantity: 2, spec: 'Fresh dairy'),
        ProductItem(name: 'Harpic Liquid Cleaner 500ml', quantity: 1, spec: 'Homecare'),
        ProductItem(name: 'Fortune Soyabean Oil 1L', quantity: 1, spec: 'Pantry essentials'),
        ProductItem(name: 'Aashirvaad Atta 5kg', quantity: 1, spec: 'Staples'),
      ],
      expectedEarnings: 75.0,
      distance: 1.8,
      status: DeliveryStatus.available,
      etaMinutes: 12,
      pickupOtp: '4820',
      deliveryOtp: '1902',
      specialInstructions: 'Ring doorbell twice. Do not leave at reception.',
      latitude: 28.4950,
      longitude: 77.0890,
    ),
    const DeliveryOrder(
      orderId: 'FC-1052',
      customerName: 'Priya Iyer',
      customerPhone: '+91 90284 81920',
      customerAddress: 'Villa 12, Orchid Greenwoods, Sector 56, Gurgaon',
      storeName: 'FlashCart Superstore (DLF Phase 3)',
      storePhone: '+91 124 492019',
      storeAddress: 'DLF Cyber City, Phase 3, Gurgaon',
      items: [
        ProductItem(name: 'Organic Hass Avocados Pack of 2', quantity: 1, spec: 'Fresh produce'),
        ProductItem(name: 'Blueberries Box 125g', quantity: 2, spec: 'Fresh produce'),
        ProductItem(name: 'Epigamia Greek Yogurt Strawberry', quantity: 3, spec: 'Chilled dairy'),
      ],
      expectedEarnings: 120.0,
      distance: 3.4,
      status: DeliveryStatus.available,
      etaMinutes: 18,
      pickupOtp: '8491',
      deliveryOtp: '7412',
      specialInstructions: 'Leave in the delivery locker near main security gate.',
      latitude: 28.4820,
      longitude: 77.0910,
    ),
    const DeliveryOrder(
      orderId: 'FC-4209',
      customerName: 'Vikram Mehra',
      customerPhone: '+91 88294 01928',
      customerAddress: 'Tower C, Flat 1402, Crestview Apartments, Sector 48, Gurgaon',
      storeName: 'FlashCart Gourmet (Sector 49)',
      storePhone: '+91 124 482012',
      storeAddress: 'Iris Tech Park, Sector 49, Gurgaon',
      items: [
        ProductItem(name: 'Premium Ribeye Steak 350g', quantity: 2, spec: 'Gourmet meats'),
        ProductItem(name: 'Extra Virgin Olive Oil 500ml', quantity: 1, spec: 'Pantry imports'),
        ProductItem(name: 'Sea Salt Grinder 100g', quantity: 1, spec: 'Condiments'),
      ],
      expectedEarnings: 210.0,
      distance: 5.2,
      status: DeliveryStatus.available,
      etaMinutes: 25,
      pickupOtp: '3920',
      deliveryOtp: '4029',
      specialInstructions: 'Call upon arrival at the gate, guards require authorization.',
      latitude: 28.4730,
      longitude: 77.0780,
    ),
  ];

  void removeOrder(String orderId) {
    state = state.where((order) => order.orderId != orderId).toList();
  }

  void restoreOrder(DeliveryOrder order) {
    if (!state.any((o) => o.orderId == order.orderId)) {
      state = [order.copyWith(status: DeliveryStatus.available), ...state];
    }
  }
}

final deliveryPartnerAvailableOrdersProvider =
    StateNotifierProvider<AvailableOrdersNotifier, List<DeliveryOrder>>((ref) {
  return AvailableOrdersNotifier();
});

// Active Order Provider
class ActiveOrderNotifier extends StateNotifier<DeliveryOrder?> {
  final Ref _ref;
  ActiveOrderNotifier(this._ref) : super(null);

  void acceptOrder(DeliveryOrder order) {
    final acceptedOrder = order.copyWith(status: DeliveryStatus.accepted);
    state = acceptedOrder;
    _ref.read(deliveryPartnerAvailableOrdersProvider.notifier).removeOrder(order.orderId);
  }

  void updateStatus(DeliveryStatus newStatus) {
    if (state != null) {
      state = state!.copyWith(status: newStatus);
    }
  }

  void cancelActiveOrder() {
    if (state != null) {
      _ref.read(deliveryPartnerAvailableOrdersProvider.notifier).restoreOrder(state!);
      state = null;
    }
  }

  void completeActiveOrder(double tip, double bonus) {
    if (state != null) {
      final order = state!;
      final totalEarned = order.expectedEarnings + tip + bonus;

      // Add to earnings provider
      _ref.read(deliveryPartnerEarningsProvider.notifier).addEarnings(
            id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Delivery for ${order.customerName}',
            amount: totalEarned,
            type: 'Delivery',
            orderId: order.orderId,
          );

      // Trigger performance update
      _ref.read(deliveryPartnerPerformanceProvider.notifier).incrementCompleted();

      // Send positive notification
      _ref.read(deliveryPartnerNotificationsProvider.notifier).addNotification(
            title: 'Earnings Credited! 🎉',
            body: '₹${totalEarned.toStringAsFixed(1)} credited for Order ${order.orderId}. Included Tip: ₹${tip.toStringAsFixed(1)}, Bonus: ₹${bonus.toStringAsFixed(1)}',
            type: NotificationType.paymentAlert,
          );

      state = null;
    }
  }
}

final deliveryPartnerActiveOrderProvider =
    StateNotifierProvider<ActiveOrderNotifier, DeliveryOrder?>((ref) {
  return ActiveOrderNotifier(ref);
});

// Earnings Provider
class EarningsNotifier extends StateNotifier<List<EarningTransaction>> {
  EarningsNotifier() : super(_initialTransactions);

  static final List<EarningTransaction> _initialTransactions = [
    EarningTransaction(
      id: 'TXN-001',
      title: 'Delivery for Rohan Kapur',
      amount: 85.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: 'Delivery',
      orderId: 'FC-8491',
    ),
    EarningTransaction(
      id: 'TXN-002',
      title: 'Monsoon Peak Incentive Bonus',
      amount: 40.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'Bonus',
      orderId: 'FC-8491',
    ),
    EarningTransaction(
      id: 'TXN-003',
      title: 'Delivery for Neha Sen',
      amount: 65.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: 'Delivery',
      orderId: 'FC-7214',
    ),
    EarningTransaction(
      id: 'TXN-004',
      title: 'Generous Tip',
      amount: 50.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: 'Tip',
      orderId: 'FC-7214',
    ),
    EarningTransaction(
      id: 'TXN-005',
      title: 'Delivery for Aarav Bose',
      amount: 90.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Delivery',
      orderId: 'FC-5021',
    ),
  ];

  double get todayEarnings {
    final today = DateTime.now();
    return state
        .where((t) =>
            t.timestamp.year == today.year &&
            t.timestamp.month == today.month &&
            t.timestamp.day == today.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get weeklyEarnings {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return state
        .where((t) => t.timestamp.isAfter(weekAgo))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyEarnings {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return state
        .where((t) => t.timestamp.isAfter(monthAgo))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get pendingPayout {
    return todayEarnings * 0.15; // Simulated pending payout holds
  }

  void addEarnings({
    required String id,
    required String title,
    required double amount,
    required String type,
    required String orderId,
  }) {
    state = [
      EarningTransaction(
        id: id,
        title: title,
        amount: amount,
        timestamp: DateTime.now(),
        type: type,
        orderId: orderId,
      ),
      ...state
    ];
  }

  void withdrawWalletBalance() {
    state = [];
  }
}

final deliveryPartnerEarningsProvider =
    StateNotifierProvider<EarningsNotifier, List<EarningTransaction>>((ref) {
  return EarningsNotifier();
});

// Notifications Provider
class NotificationsNotifier extends StateNotifier<List<RiderNotification>> {
  NotificationsNotifier() : super(_initialNotifications);

  static final List<RiderNotification> _initialNotifications = [
    RiderNotification(
      id: 'NT-1',
      title: '🔴 Critical Safety Advisory',
      body: 'Heavy rainfall reported in cyber city sector. Ride slow and always wear your high-visibility rain poncho. Safety is #1.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.emergency,
      isRead: false,
    ),
    RiderNotification(
      id: 'NT-2',
      title: '₹50 Guarantee Active! ⚡',
      body: 'Earn extra flat ₹50 bonus on every delivery completed between 7:00 PM and 11:00 PM tonight. Go online!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.promotion,
      isRead: false,
    ),
    RiderNotification(
      id: 'NT-3',
      title: 'Incentive Payout Credited',
      body: 'Your weekly performance bonus of ₹250.0 has been transferred to your registered bank account. Tap to view bank stub.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.paymentAlert,
      isRead: true,
    ),
    RiderNotification(
      id: 'NT-4',
      title: 'System Upgrade Announcement',
      body: 'The Delivery app will undergo a scheduled server update on 24th July, 2:00 AM - 4:00 AM. Services will be offline during this time.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.announcement,
      isRead: true,
    ),
  ];

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) {
    state = [
      RiderNotification(
        id: 'NT-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        isRead: false,
      ),
      ...state
    ];
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final deliveryPartnerNotificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<RiderNotification>>((ref) {
  return NotificationsNotifier();
});

// Performance Stats Provider
class PerformanceStats {
  final double acceptanceRate;
  final double completionRate;
  final double customerRating;
  final int totalCompleted;
  final int lateDeliveries;
  final int cancelledDeliveries;

  PerformanceStats({
    required this.acceptanceRate,
    required this.completionRate,
    required this.customerRating,
    required this.totalCompleted,
    required this.lateDeliveries,
    required this.cancelledDeliveries,
  });

  PerformanceStats copyWith({
    double? acceptanceRate,
    double? completionRate,
    double? customerRating,
    int? totalCompleted,
    int? lateDeliveries,
    int? cancelledDeliveries,
  }) {
    return PerformanceStats(
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      completionRate: completionRate ?? this.completionRate,
      customerRating: customerRating ?? this.customerRating,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      lateDeliveries: lateDeliveries ?? this.lateDeliveries,
      cancelledDeliveries: cancelledDeliveries ?? this.cancelledDeliveries,
    );
  }
}

class PerformanceNotifier extends StateNotifier<PerformanceStats> {
  PerformanceNotifier()
      : super(PerformanceStats(
          acceptanceRate: 0.96,
          completionRate: 0.98,
          customerRating: 4.88,
          totalCompleted: 24,
          lateDeliveries: 1,
          cancelledDeliveries: 0,
        ));

  void incrementCompleted() {
    state = state.copyWith(
      totalCompleted: state.totalCompleted + 1,
      completionRate: (state.totalCompleted + 1) / (state.totalCompleted + 1 + state.cancelledDeliveries),
    );
  }

  void updateRates(double acceptance, double completion, double rating) {
    state = state.copyWith(
      acceptanceRate: acceptance,
      completionRate: completion,
      customerRating: rating,
    );
  }
}

final deliveryPartnerPerformanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceStats>((ref) {
  return PerformanceNotifier();
});
