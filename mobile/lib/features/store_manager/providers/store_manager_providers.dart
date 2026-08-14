import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_manager_models.dart';

// ---------------------------------------------------------
// Login State Provider
// ---------------------------------------------------------
class LoginState {
  final bool isLoggedIn;
  final String? employeeId;
  final String? error;
  final bool isVerifyingOtp;
  final String? tempEmployeeId;

  const LoginState({
    this.isLoggedIn = false,
    this.employeeId,
    this.error,
    this.isVerifyingOtp = false,
    this.tempEmployeeId,
  });

  LoginState copyWith({
    bool? isLoggedIn,
    String? employeeId,
    String? error,
    bool? isVerifyingOtp,
    String? tempEmployeeId,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      employeeId: employeeId ?? this.employeeId,
      error: error ?? this.error,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      tempEmployeeId: tempEmployeeId ?? this.tempEmployeeId,
    );
  }
}

class StoreManagerLoginNotifier extends StateNotifier<LoginState> {
  StoreManagerLoginNotifier() : super(const LoginState());

  void login(String employeeId, String password) async {
    state = state.copyWith(error: null);
    if (employeeId.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(error: "Employee ID and Password cannot be empty.");
      return;
    }
    // Simulate API request delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Accept any standard credentials for demo purposes
    if (password.length < 4) {
      state = state.copyWith(error: "Password must be at least 4 characters.");
    } else {
      state = state.copyWith(
        isVerifyingOtp: true,
        tempEmployeeId: employeeId,
      );
    }
  }

  bool verifyOtp(String otp) {
    if (otp == "123456" || otp == "000000" || otp.length == 6) {
      state = state.copyWith(
        isLoggedIn: true,
        employeeId: state.tempEmployeeId,
        isVerifyingOtp: false,
      );
      return true;
    } else {
      state = state.copyWith(error: "Invalid OTP. Use any 6-digit number.");
      return false;
    }
  }

  void logout() {
    state = const LoginState();
  }

  void cancelOtp() {
    state = state.copyWith(isVerifyingOtp: false, error: null);
  }
}

final storeManagerLoginProvider = StateNotifierProvider<StoreManagerLoginNotifier, LoginState>((ref) {
  return StoreManagerLoginNotifier();
});

// ---------------------------------------------------------
// Active Staff Member Profile Provider
// ---------------------------------------------------------
final storeManagerActiveStaffProvider = Provider<StaffMember>((ref) {
  final loginState = ref.watch(storeManagerLoginProvider);
  return StaffMember(
    id: "SM-402",
    name: "Vikram Malhotra",
    employeeId: loginState.employeeId ?? "EMP-92044",
    role: "Senior Warehouse Executive",
    shift: "Morning Shift (06:00 AM - 02:00 PM)",
    storeDetails: "Dark Store #14 - HSR Layout Sector 3, Bengaluru",
    avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
    ordersPicked: 48,
    packingAccuracy: 99.4,
    productivityIndex: 9.8,
    attendanceDays: 24,
  );
});

// ---------------------------------------------------------
// Order Queue State Management
// ---------------------------------------------------------
class StoreManagerOrdersNotifier extends StateNotifier<List<StoreOrder>> {
  StoreManagerOrdersNotifier() : super(_initialOrders);

  static final List<StoreOrder> _initialOrders = [
    StoreOrder(
      id: "FC-9023",
      customerName: "Rohan Deshmukh",
      totalAmount: 495.0,
      status: OrderFulfillmentStatus.pending,
      isPriority: true,
      orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
      barcode: "ORD-FC-9023",
      items: [
        const OrderItem(
          id: "item_1",
          productName: "Fresh Organic Bananas",
          imageUrl: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120&q=80",
          quantity: 2,
          shelfLocation: "Aisle A - Rack 3 - Shelf 1",
          barcode: "8901234567890",
        ),
        const OrderItem(
          id: "item_2",
          productName: "Farm Fresh Milk (Tone)",
          imageUrl: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=120&q=80",
          quantity: 1,
          shelfLocation: "Cold Zone C - Rack 1 - Level 2",
          barcode: "8901234567891",
        ),
        const OrderItem(
          id: "item_3",
          productName: "Greek Yogurt Blueberry",
          imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=120&q=80",
          quantity: 3,
          shelfLocation: "Cold Zone C - Rack 2 - Level 1",
          barcode: "8901234567892",
        ),
      ],
    ),
    StoreOrder(
      id: "FC-9024",
      customerName: "Anjali Sharma",
      totalAmount: 189.0,
      status: OrderFulfillmentStatus.picking,
      orderTime: DateTime.now().subtract(const Duration(minutes: 8)),
      barcode: "ORD-FC-9024",
      items: [
        const OrderItem(
          id: "item_4",
          productName: "Fresh Avocado Pack",
          imageUrl: "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&q=80",
          quantity: 1,
          shelfLocation: "Aisle A - Rack 4 - Shelf 2",
          pickedQuantity: 0,
          barcode: "8901234567893",
        ),
      ],
    ),
    StoreOrder(
      id: "FC-9021",
      customerName: "Karan Johar",
      totalAmount: 850.0,
      status: OrderFulfillmentStatus.packing,
      isScheduled: true,
      scheduledTime: "04:00 PM - 05:00 PM",
      orderTime: DateTime.now().subtract(const Duration(hours: 1)),
      barcode: "ORD-FC-9021",
      items: [
        const OrderItem(
          id: "item_5",
          productName: "Sourdough Whole Wheat Bread",
          imageUrl: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=120&q=80",
          quantity: 1,
          shelfLocation: "Aisle B - Rack 1 - Shelf 3",
          pickedQuantity: 1,
          isPicked: true,
          barcode: "8901234567894",
        ),
        const OrderItem(
          id: "item_6",
          productName: "Premium Coffee Beans",
          imageUrl: "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=120&q=80",
          quantity: 1,
          shelfLocation: "Aisle D - Rack 2 - Shelf 1",
          pickedQuantity: 1,
          isPicked: true,
          barcode: "8901234567895",
        ),
      ],
    ),
    StoreOrder(
      id: "FC-9020",
      customerName: "Priyanka Chopra",
      totalAmount: 460.0,
      status: OrderFulfillmentStatus.readyForPickup,
      orderTime: DateTime.now().subtract(const Duration(minutes: 40)),
      barcode: "ORD-FC-9020",
      items: [
        const OrderItem(
          id: "item_7",
          productName: "Sugar-free Oat Milk",
          imageUrl: "https://images.unsplash.com/photo-1553456558-aff63285bdd1?w=120&q=80",
          quantity: 2,
          shelfLocation: "Aisle D - Rack 1 - Shelf 2",
          pickedQuantity: 2,
          isPicked: true,
          barcode: "8901234567896",
        ),
      ],
    ),
  ];

  void startPicking(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderFulfillmentStatus.picking);
      }
      return o;
    }).toList();
  }

  void updatePickedQuantity(String orderId, String itemId, int pickedQty) {
    state = state.map((o) {
      if (o.id == orderId) {
        final updatedItems = o.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(
              pickedQuantity: pickedQty,
              isPicked: pickedQty == item.quantity,
            );
          }
          return item;
        }).toList();
        return o.copyWith(items: updatedItems);
      }
      return o;
    }).toList();
  }

  void finishPicking(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderFulfillmentStatus.packing);
      }
      return o;
    }).toList();
  }

  void finishPacking(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderFulfillmentStatus.readyForPickup);
      }
      return o;
    }).toList();
  }

  void handoffToRider(String orderId) {
    state = state.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderFulfillmentStatus.completed);
      }
      return o;
    }).toList();
  }

  void addOrder(StoreOrder order) {
    state = [order, ...state];
  }
}

final storeManagerOrdersProvider = StateNotifierProvider<StoreManagerOrdersNotifier, List<StoreOrder>>((ref) {
  return StoreManagerOrdersNotifier();
});

// Helper derived providers
final storeManagerPickingQueueProvider = Provider<List<StoreOrder>>((ref) {
  final orders = ref.watch(storeManagerOrdersProvider);
  return orders.where((o) => o.status == OrderFulfillmentStatus.pending || o.status == OrderFulfillmentStatus.picking).toList();
});

final storeManagerPackingQueueProvider = Provider<List<StoreOrder>>((ref) {
  final orders = ref.watch(storeManagerOrdersProvider);
  return orders.where((o) => o.status == OrderFulfillmentStatus.packing).toList();
});

final storeManagerDispatchQueueProvider = Provider<List<StoreOrder>>((ref) {
  final orders = ref.watch(storeManagerOrdersProvider);
  return orders.where((o) => o.status == OrderFulfillmentStatus.readyForPickup).toList();
});

// Currently Active Picking Order Provider
class ActivePickingNotifier extends StateNotifier<StoreOrder?> {
  ActivePickingNotifier() : super(null);

  void setActive(StoreOrder order) {
    state = order;
  }

  void clear() {
    state = null;
  }

  void updateItemPicked(String itemId, int qty) {
    if (state == null) return;
    final updatedItems = state!.items.map((i) {
      if (i.id == itemId) {
        return i.copyWith(pickedQuantity: qty, isPicked: qty == i.quantity);
      }
      return i;
    }).toList();
    state = state!.copyWith(items: updatedItems);
  }
}

final storeManagerActivePickingProvider = StateNotifierProvider<ActivePickingNotifier, StoreOrder?>((ref) {
  return ActivePickingNotifier();
});

// Currently Active Packing Order Provider
class ActivePackingNotifier extends StateNotifier<StoreOrder?> {
  ActivePackingNotifier() : super(null);

  void setActive(StoreOrder order) {
    state = order;
  }

  void clear() {
    state = null;
  }
}

final storeManagerActivePackingProvider = StateNotifierProvider<ActivePackingNotifier, StoreOrder?>((ref) {
  return ActivePackingNotifier();
});

// ---------------------------------------------------------
// Inventory State Management
// ---------------------------------------------------------
class StoreManagerInventoryNotifier extends StateNotifier<List<InventoryItem>> {
  StoreManagerInventoryNotifier() : super(_initialInventory);

  static final List<InventoryItem> _initialInventory = [
    InventoryItem(
      id: "inv_1",
      name: "Fresh Organic Bananas",
      sku: "SKU-FR-BAN-10",
      category: "Fruits & Vegetables",
      currentStock: 15,
      lowStockThreshold: 20,
      unit: "1 kg",
      price: 69.0,
      status: InventoryStatus.lowStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      shelfLocation: "Aisle A - Rack 3 - Shelf 1",
      imageUrl: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120&q=80",
    ),
    InventoryItem(
      id: "inv_2",
      name: "Fresh Avocado Pack",
      sku: "SKU-FR-AVO-02",
      category: "Fruits & Vegetables",
      currentStock: 42,
      lowStockThreshold: 15,
      unit: "2 pcs",
      price: 189.0,
      status: InventoryStatus.normal,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      shelfLocation: "Aisle A - Rack 4 - Shelf 2",
      imageUrl: "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&q=80",
    ),
    InventoryItem(
      id: "inv_3",
      name: "Sourdough Whole Wheat Bread",
      sku: "SKU-BK-SOU-400",
      category: "Bakery & Dairy",
      currentStock: 2,
      lowStockThreshold: 10,
      unit: "400g",
      price: 85.0,
      status: InventoryStatus.lowStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
      shelfLocation: "Aisle B - Rack 1 - Shelf 3",
      imageUrl: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=120&q=80",
    ),
    InventoryItem(
      id: "inv_4",
      name: "Farm Fresh Milk (Tone)",
      sku: "SKU-DY-MIL-500",
      category: "Bakery & Dairy",
      currentStock: 60,
      lowStockThreshold: 30,
      unit: "500ml",
      price: 32.0,
      status: InventoryStatus.normal,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
      shelfLocation: "Cold Zone C - Rack 1 - Level 2",
      imageUrl: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=120&q=80",
    ),
    InventoryItem(
      id: "inv_5",
      name: "Premium Coffee Beans",
      sku: "SKU-BV-COF-250",
      category: "Beverages",
      currentStock: 0,
      lowStockThreshold: 8,
      unit: "250g",
      price: 499.0,
      status: InventoryStatus.outOfStock,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      shelfLocation: "Aisle D - Rack 2 - Shelf 1",
      imageUrl: "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=120&q=80",
    ),
  ];

  void addStock(String id, int qty) {
    state = state.map((item) {
      if (item.id == id) {
        final newStock = item.currentStock + qty;
        InventoryStatus newStatus = InventoryStatus.normal;
        if (newStock == 0) {
          newStatus = InventoryStatus.outOfStock;
        } else if (newStock <= item.lowStockThreshold) {
          newStatus = InventoryStatus.lowStock;
        }
        return item.copyWith(
          currentStock: newStock,
          status: newStatus,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();
  }

  void reportDamagedOrExpired(String id, int qty, bool isExpired) {
    state = state.map((item) {
      if (item.id == id) {
        final newStock = (item.currentStock - qty).clamp(0, 99999);
        InventoryStatus newStatus = InventoryStatus.normal;
        if (newStock == 0) {
          newStatus = InventoryStatus.outOfStock;
        } else if (newStock <= item.lowStockThreshold) {
          newStatus = InventoryStatus.lowStock;
        }
        return item.copyWith(
          currentStock: newStock,
          status: isExpired ? InventoryStatus.expired : InventoryStatus.damaged,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();
  }

  void transferStock(String id, int qty, String destinationZone) {
    state = state.map((item) {
      if (item.id == id) {
        final newStock = (item.currentStock - qty).clamp(0, 99999);
        InventoryStatus newStatus = InventoryStatus.normal;
        if (newStock == 0) {
          newStatus = InventoryStatus.outOfStock;
        } else if (newStock <= item.lowStockThreshold) {
          newStatus = InventoryStatus.lowStock;
        }
        return item.copyWith(
          currentStock: newStock,
          status: InventoryStatus.transferring,
          shelfLocation: "$destinationZone - Auto Assigned Shelf",
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();
  }
}

final storeManagerInventoryProvider = StateNotifierProvider<StoreManagerInventoryNotifier, List<InventoryItem>>((ref) {
  return StoreManagerInventoryNotifier();
});

// ---------------------------------------------------------
// Warehouse Layout Provider
// ---------------------------------------------------------
final storeManagerWarehouseZonesProvider = Provider<List<WarehouseZone>>((ref) {
  return const [
    WarehouseZone(code: "A", name: "Produce Section (A)", description: "Fresh fruits, organic greens, vegetables", shelfCount: 12),
    WarehouseZone(code: "B", name: "Bakery & Ambient (B)", description: "Breads, buns, non-refrigerated baking, grains", shelfCount: 8),
    WarehouseZone(code: "C", name: "Cold Storage Zone (C)", description: "Refrigerators & Freezers for milk, butter, meats", shelfCount: 6),
    WarehouseZone(code: "D", name: "Dry Grocery / Beverages (D)", description: "Packaged cereal, snacks, tea, coffee bags", shelfCount: 15),
    WarehouseZone(code: "E", name: "Household & Care (E)", description: "Cleaning materials, toiletries, baby care", shelfCount: 10),
  ];
});

final storeManagerWarehouseShelvesProvider = Provider<List<WarehouseShelf>>((ref) {
  return const [
    WarehouseShelf(code: "A-R3-S1", zone: "A", rackNumber: 3, level: 1, itemNames: ["Fresh Organic Bananas", "Red Apples Pack"], capacityPercent: 45),
    WarehouseShelf(code: "A-R4-S2", zone: "A", rackNumber: 4, level: 2, itemNames: ["Fresh Avocado Pack", "Watermelon Round"], capacityPercent: 82),
    WarehouseShelf(code: "B-R1-S3", zone: "B", rackNumber: 1, level: 3, itemNames: ["Sourdough Whole Wheat Bread", "Milk Bread"], capacityPercent: 15),
    WarehouseShelf(code: "C-R1-S2", zone: "C", rackNumber: 1, level: 2, itemNames: ["Farm Fresh Milk (Tone)", "Greek Yogurt Blueberry"], capacityPercent: 90),
    WarehouseShelf(code: "D-R2-S1", zone: "D", rackNumber: 2, level: 1, itemNames: ["Premium Coffee Beans", "Sugar-free Oat Milk"], capacityPercent: 60),
  ];
});

// ---------------------------------------------------------
// Returns & Refunds State Management
// ---------------------------------------------------------
class StoreManagerReturnsNotifier extends StateNotifier<List<ReturnedItem>> {
  StoreManagerReturnsNotifier() : super(_initialReturns);

  static final List<ReturnedItem> _initialReturns = [
    ReturnedItem(
      id: "RET-101",
      orderId: "FC-8904",
      productName: "Farm Fresh Milk (Tone)",
      quantity: 2,
      reason: "Leaking / Damaged pouch",
      status: ReturnStatus.pendingInspection,
      refundAmount: 64.0,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      imageUrl: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=120&q=80",
    ),
    ReturnedItem(
      id: "RET-102",
      orderId: "FC-8799",
      productName: "Fresh Avocado Pack",
      quantity: 1,
      reason: "Overripe / Spoiled inside",
      status: ReturnStatus.inspectedPassed,
      refundAmount: 189.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&q=80",
    ),
  ];

  void processRefund(String id, ReturnStatus outcome) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(status: outcome);
      }
      return item;
    }).toList();
  }
}

final storeManagerReturnsProvider = StateNotifierProvider<StoreManagerReturnsNotifier, List<ReturnedItem>>((ref) {
  return StoreManagerReturnsNotifier();
});

// ---------------------------------------------------------
// Notifications State Management
// ---------------------------------------------------------
class StoreManagerNotificationsNotifier extends StateNotifier<List<StoreNotification>> {
  StoreManagerNotificationsNotifier() : super(_initialNotifications);

  static final List<StoreNotification> _initialNotifications = [
    StoreNotification(
      id: "notif_1",
      title: "🚨 High Priority Order Added",
      body: "Order FC-9023 for Rohan Deshmukh contains 6 items and requires immediate pick & pack.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      category: NotificationCategory.newOrder,
    ),
    StoreNotification(
      id: "notif_2",
      title: "⚠️ Low Stock Alert: Bananas",
      body: "Fresh Organic Bananas has dropped to 15 units (threshold is 20). Schedule a warehouse transfer.",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      category: NotificationCategory.stockAlert,
    ),
    StoreNotification(
      id: "notif_3",
      title: "📢 Morning Shift Handoff Notes",
      body: "Ensure Cold Storage Zone C temperatures are verified manually. Power cycle fridge 2 if latch feels loose.",
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: NotificationCategory.supervisorAnnouncement,
    ),
  ];

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final storeManagerNotificationsProvider = StateNotifierProvider<StoreManagerNotificationsNotifier, List<StoreNotification>>((ref) {
  return StoreManagerNotificationsNotifier();
});
