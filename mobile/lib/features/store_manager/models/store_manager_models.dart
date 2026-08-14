import 'package:flutter/foundation.dart';

enum OrderFulfillmentStatus {
  pending,
  picking,
  packing,
  readyForPickup,
  completed,
}

enum InventoryStatus {
  normal,
  lowStock,
  outOfStock,
  damaged,
  expired,
  transferring,
}

enum NotificationCategory {
  newOrder,
  stockAlert,
  supervisorAnnouncement,
}

enum ReturnStatus {
  pendingInspection,
  inspectedPassed,
  inspectedDamaged,
  refunded,
  rejected,
}

class StaffMember {
  final String id;
  final String name;
  final String employeeId;
  final String role;
  final String shift;
  final String storeDetails;
  final String avatarUrl;
  final int ordersPicked;
  final double packingAccuracy;
  final double productivityIndex;
  final int attendanceDays;

  const StaffMember({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.role,
    required this.shift,
    required this.storeDetails,
    required this.avatarUrl,
    required this.ordersPicked,
    required this.packingAccuracy,
    required this.productivityIndex,
    required this.attendanceDays,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? role,
    String? shift,
    String? storeDetails,
    String? avatarUrl,
    int? ordersPicked,
    double? packingAccuracy,
    double? productivityIndex,
    int? attendanceDays,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      storeDetails: storeDetails ?? this.storeDetails,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ordersPicked: ordersPicked ?? this.ordersPicked,
      packingAccuracy: packingAccuracy ?? this.packingAccuracy,
      productivityIndex: productivityIndex ?? this.productivityIndex,
      attendanceDays: attendanceDays ?? this.attendanceDays,
    );
  }
}

class OrderItem {
  final String id;
  final String productName;
  final String imageUrl;
  final int quantity;
  final String shelfLocation;
  final int pickedQuantity;
  final bool isPicked;
  final String barcode;

  const OrderItem({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.shelfLocation,
    this.pickedQuantity = 0,
    this.isPicked = false,
    required this.barcode,
  });

  OrderItem copyWith({
    String? id,
    String? productName,
    String? imageUrl,
    int? quantity,
    String? shelfLocation,
    int? pickedQuantity,
    bool? isPicked,
    String? barcode,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      pickedQuantity: pickedQuantity ?? this.pickedQuantity,
      isPicked: isPicked ?? this.isPicked,
      barcode: barcode ?? this.barcode,
    );
  }
}

class StoreOrder {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderFulfillmentStatus status;
  final bool isPriority;
  final bool isScheduled;
  final String? scheduledTime;
  final DateTime orderTime;
  final String barcode;

  const StoreOrder({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.isPriority = false,
    this.isScheduled = false,
    this.scheduledTime,
    required this.orderTime,
    required this.barcode,
  });

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get pickedItemsCount => items.fold(0, (sum, item) => sum + item.pickedQuantity);
  double get pickProgress => totalItemsCount == 0 ? 0.0 : pickedItemsCount / totalItemsCount;

  StoreOrder copyWith({
    String? id,
    String? customerName,
    List<OrderItem>? items,
    double? totalAmount,
    OrderFulfillmentStatus? status,
    bool? isPriority,
    bool? isScheduled,
    String? scheduledTime,
    DateTime? orderTime,
    String? barcode,
  }) {
    return StoreOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      isPriority: isPriority ?? this.isPriority,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      orderTime: orderTime ?? this.orderTime,
      barcode: barcode ?? this.barcode,
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int currentStock;
  final int lowStockThreshold;
  final String unit;
  final double price;
  final InventoryStatus status;
  final DateTime lastUpdated;
  final String shelfLocation;
  final String imageUrl;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.unit,
    required this.price,
    required this.status,
    required this.lastUpdated,
    required this.shelfLocation,
    required this.imageUrl,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    int? currentStock,
    int? lowStockThreshold,
    String? unit,
    double? price,
    InventoryStatus? status,
    DateTime? lastUpdated,
    String? shelfLocation,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class WarehouseZone {
  final String code;
  final String name;
  final String description;
  final int shelfCount;

  const WarehouseZone({
    required this.code,
    required this.name,
    required this.description,
    required this.shelfCount,
  });
}

class WarehouseShelf {
  final String code;
  final String zone;
  final int rackNumber;
  final int level;
  final List<String> itemNames;
  final int capacityPercent;

  const WarehouseShelf({
    required this.code,
    required this.zone,
    required this.rackNumber,
    required this.level,
    required this.itemNames,
    required this.capacityPercent,
  });
}

class ReturnedItem {
  final String id;
  final String orderId;
  final String productName;
  final int quantity;
  final String reason;
  final ReturnStatus status;
  final double refundAmount;
  final DateTime date;
  final String imageUrl;

  const ReturnedItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.reason,
    required this.status,
    required this.refundAmount,
    required this.date,
    required this.imageUrl,
  });

  ReturnedItem copyWith({
    String? id,
    String? orderId,
    String? productName,
    int? quantity,
    String? reason,
    ReturnStatus? status,
    double? refundAmount,
    DateTime? date,
    String? imageUrl,
  }) {
    return ReturnedItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      refundAmount: refundAmount ?? this.refundAmount,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class StoreNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;

  const StoreNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.isRead = false,
  });

  StoreNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationCategory? category,
    bool? isRead,
  }) {
    return StoreNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }
}
