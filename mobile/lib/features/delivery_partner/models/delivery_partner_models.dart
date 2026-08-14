import 'package:flutter/foundation.dart';

enum DeliveryStatus {
  available,
  accepted,
  reachedStore,
  pickedUp,
  reachedCustomer,
  completed
}

class ProductItem {
  final String name;
  final int quantity;
  final String spec;

  const ProductItem({
    required this.name,
    required this.quantity,
    required this.spec,
  });
}

class DeliveryOrder {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String storeName;
  final String storePhone;
  final String storeAddress;
  final List<ProductItem> items;
  final double expectedEarnings;
  final double distance; // in km
  final DeliveryStatus status;
  final int etaMinutes;
  final String pickupOtp;
  final String deliveryOtp;
  final String specialInstructions;
  final double latitude;
  final double longitude;

  const DeliveryOrder({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.storeName,
    required this.storePhone,
    required this.storeAddress,
    required this.items,
    required this.expectedEarnings,
    required this.distance,
    required this.status,
    required this.etaMinutes,
    required this.pickupOtp,
    required this.deliveryOtp,
    required this.specialInstructions,
    required this.latitude,
    required this.longitude,
  });

  DeliveryOrder copyWith({
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? storeName,
    String? storePhone,
    String? storeAddress,
    List<ProductItem>? items,
    double? expectedEarnings,
    double? distance,
    DeliveryStatus? status,
    int? etaMinutes,
    String? pickupOtp,
    String? deliveryOtp,
    String? specialInstructions,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryOrder(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      storeAddress: storeAddress ?? this.storeAddress,
      items: items ?? this.items,
      expectedEarnings: expectedEarnings ?? this.expectedEarnings,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

enum NotificationType {
  newOrder,
  paymentAlert,
  promotion,
  announcement,
  emergency
}

class RiderNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const RiderNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  String get description => body;

  RiderNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return RiderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class EarningTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime timestamp;
  final String type; // Delivery, Bonus, Tip
  final String orderId;

  const EarningTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.type,
    required this.orderId,
  });
}
