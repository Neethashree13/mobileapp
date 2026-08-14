import 'package:flutter/material.dart';

// 1. Order Status Enum
enum OrderStatusEnum {
  Placed,
  Confirmed,
  Preparing,
  Packed,
  OutForDelivery,
  Delivered,
  Cancelled,
  Returned,
}

extension OrderStatusEnumExtension on OrderStatusEnum {
  String get label {
    switch (this) {
      case OrderStatusEnum.Placed:
        return 'Order Placed';
      case OrderStatusEnum.Confirmed:
        return 'Order Confirmed';
      case OrderStatusEnum.Preparing:
        return 'Preparing Items';
      case OrderStatusEnum.Packed:
        return 'Packed';
      case OrderStatusEnum.OutForDelivery:
        return 'Out for Delivery';
      case OrderStatusEnum.Delivered:
        return 'Delivered';
      case OrderStatusEnum.Cancelled:
        return 'Cancelled';
      case OrderStatusEnum.Returned:
        return 'Returned';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatusEnum.Placed:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatusEnum.Confirmed:
        return const Color(0xFF6366F1); // Indigo
      case OrderStatusEnum.Preparing:
        return const Color(0xFFF59E0B); // Amber
      case OrderStatusEnum.Packed:
        return const Color(0xFF8B5CF6); // Purple
      case OrderStatusEnum.OutForDelivery:
        return const Color(0xFF06B6D4); // Cyan
      case OrderStatusEnum.Delivered:
        return const Color(0xFF10B981); // Emerald Green
      case OrderStatusEnum.Cancelled:
        return const Color(0xFFEF4444); // Red
      case OrderStatusEnum.Returned:
        return const Color(0xFF6B7280); // Gray
    }
  }

  bool get isCancellable {
    return this == OrderStatusEnum.Placed ||
        this == OrderStatusEnum.Confirmed ||
        this == OrderStatusEnum.Preparing;
  }
}

// 2. Payment Status Enum
enum PaymentStatusEnum {
  Pending,
  Paid,
  Failed,
  Refunded,
}

extension PaymentStatusEnumExtension on PaymentStatusEnum {
  String get label {
    switch (this) {
      case PaymentStatusEnum.Pending:
        return 'Pending';
      case PaymentStatusEnum.Paid:
        return 'Paid';
      case PaymentStatusEnum.Failed:
        return 'Failed';
      case PaymentStatusEnum.Refunded:
        return 'Refunded';
    }
  }
}

// 3. Payment Method Enum
enum PaymentMethodEnum {
  CashOnDelivery,
  UPI,
  CreditCard,
  DebitCard,
  Wallet,
  NetBanking,
}

extension PaymentMethodEnumExtension on PaymentMethodEnum {
  String get label {
    switch (this) {
      case PaymentMethodEnum.CashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethodEnum.UPI:
        return 'UPI Payment';
      case PaymentMethodEnum.CreditCard:
        return 'Credit Card';
      case PaymentMethodEnum.DebitCard:
        return 'Debit Card';
      case PaymentMethodEnum.Wallet:
        return 'Flash Pay Wallet';
      case PaymentMethodEnum.NetBanking:
        return 'Net Banking';
    }
  }
}

// 4. Delivery Address Model
class DeliveryAddressModel {
  final String id;
  final String name;
  final String phone;
  final String house;
  final String street;
  final String landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;

  const DeliveryAddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.house,
    required this.street,
    required this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.latitude = 12.9716,
    this.longitude = 77.5946,
  });

  String get fullAddress {
    final parts = [
      if (house.isNotEmpty) house,
      if (street.isNotEmpty) street,
      if (landmark.isNotEmpty) 'Near $landmark',
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (postalCode.isNotEmpty) postalCode,
    ];
    return parts.join(', ');
  }

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'] as String? ?? 'addr-1',
      name: json['name'] as String? ?? json['recipientName'] as String? ?? 'Valued Customer',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      house: json['house'] as String? ?? json['addressLine1'] as String? ?? '',
      street: json['street'] as String? ?? json['addressLine2'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String? ?? 'Bangalore',
      state: json['state'] as String? ?? 'Karnataka',
      postalCode: json['postalCode'] as String? ?? json['zipCode'] as String? ?? '560001',
      country: json['country'] as String? ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5946,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'house': house,
      'street': street,
      'landmark': landmark,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// 5. Order Item Model
class OrderItemModel {
  final String productId;
  final String productName;
  final String image;
  final int quantity;
  final double price;
  final double originalPrice;
  final String unit;
  final double subtotal;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.image,
    required this.quantity,
    required this.price,
    double? originalPrice,
    this.unit = '1 unit',
    double? subtotal,
  })  : originalPrice = originalPrice ?? price,
        subtotal = subtotal ?? (price * quantity);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final priceVal = (json['price'] as num?)?.toDouble() ?? 0.0;
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final origPrice = (json['originalPrice'] as num?)?.toDouble() ?? priceVal;
    final calculatedSubtotal = (json['subtotal'] as num?)?.toDouble() ?? (priceVal * qty);

    return OrderItemModel(
      productId: json['productId'] as String? ?? json['id'] as String? ?? 'p-unknown',
      productName: json['productName'] as String? ?? json['name'] as String? ?? 'Flash Item',
      image: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      quantity: qty,
      price: priceVal,
      originalPrice: origPrice,
      unit: json['unit'] as String? ?? '1 unit',
      subtotal: calculatedSubtotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'image': image,
      'quantity': quantity,
      'price': price,
      'originalPrice': originalPrice,
      'unit': unit,
      'subtotal': subtotal,
    };
  }
}

// 6. Create Order Request DTO
class CreateOrderRequest {
  final String storeId;
  final PaymentMethodEnum paymentMethod;
  final DeliveryAddressModel deliveryAddress;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;
  final String? notes;

  CreateOrderRequest({
    this.storeId = 'store-main',
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.deliveryFee = 25.0,
    this.tax = 5.0,
    required this.total,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'paymentMethod': paymentMethod.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'notes': notes,
    };
  }
}

// 7. Production OrderModel
class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String storeId;
  final OrderStatusEnum status;
  final PaymentStatusEnum paymentStatus;
  final PaymentMethodEnum paymentMethod;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String estimatedDeliveryTime;
  final DeliveryAddressModel deliveryAddress;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.storeId = 'store-main',
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.subtotal,
    this.discount = 0.0,
    this.deliveryFee = 25.0,
    this.tax = 5.0,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedDeliveryTime = '10 Mins',
    required this.deliveryAddress,
    required this.items,
  });

  static OrderStatusEnum _parseStatus(String? str) {
    if (str == null) return OrderStatusEnum.Placed;
    final s = str.replaceAll('_', '').replaceAll(' ', '').toUpperCase();
    if (s == 'CONFIRMED' || s == 'ACCEPTED') return OrderStatusEnum.Confirmed;
    if (s == 'PREPARING' || s == 'PICKING') return OrderStatusEnum.Preparing;
    if (s == 'PACKED' || s == 'PACKING') return OrderStatusEnum.Packed;
    if (s == 'OUTFORDELIVERY') return OrderStatusEnum.OutForDelivery;
    if (s == 'DELIVERED' || s == 'COMPLETED') return OrderStatusEnum.Delivered;
    if (s == 'CANCELLED' || s == 'CANCELED') return OrderStatusEnum.Cancelled;
    if (s == 'RETURNED') return OrderStatusEnum.Returned;
    return OrderStatusEnum.Placed;
  }

  static PaymentStatusEnum _parsePaymentStatus(String? str) {
    if (str == null) return PaymentStatusEnum.Pending;
    final s = str.toUpperCase();
    if (s == 'PAID' || s == 'COMPLETED' || s == 'SUCCESS') return PaymentStatusEnum.Paid;
    if (s == 'FAILED') return PaymentStatusEnum.Failed;
    if (s == 'REFUNDED') return PaymentStatusEnum.Refunded;
    return PaymentStatusEnum.Pending;
  }

  static PaymentMethodEnum _parsePaymentMethod(String? str) {
    if (str == null) return PaymentMethodEnum.Wallet;
    final s = str.toUpperCase();
    if (s.contains('CASH') || s.contains('COD')) return PaymentMethodEnum.CashOnDelivery;
    if (s.contains('UPI')) return PaymentMethodEnum.UPI;
    if (s.contains('CREDIT')) return PaymentMethodEnum.CreditCard;
    if (s.contains('DEBIT')) return PaymentMethodEnum.DebitCard;
    if (s.contains('NET') || s.contains('BANK')) return PaymentMethodEnum.NetBanking;
    return PaymentMethodEnum.Wallet;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ?? 'FC-${DateTime.now().millisecondsSinceEpoch}';
    final rawOrderNum = json['orderNumber'] as String? ?? json['order_number'] as String? ?? rawId;
    final rawUserId = json['userId'] as String? ?? json['user_id'] as String? ?? 'usr-1';
    final rawStoreId = json['storeId'] as String? ?? json['store_id'] as String? ?? 'store-main';

    final parsedStatus = _parseStatus(json['status'] as String?);
    final parsedPaymentStatus = _parsePaymentStatus(json['paymentStatus'] as String? ?? json['payment_status'] as String?);
    final parsedPaymentMethod = _parsePaymentMethod(json['paymentMethod'] as String? ?? json['payment_method'] as String?);

    final subtotalVal = (json['subtotal'] as num?)?.toDouble() ?? (json['subTotal'] as num?)?.toDouble() ?? 0.0;
    final discountVal = (json['discount'] as num?)?.toDouble() ?? 0.0;
    final deliveryFeeVal = (json['deliveryFee'] as num?)?.toDouble() ?? (json['delivery_fee'] as num?)?.toDouble() ?? 25.0;
    final taxVal = (json['tax'] as num?)?.toDouble() ?? (json['taxes'] as num?)?.toDouble() ?? 5.0;
    final totalVal = (json['total'] as num?)?.toDouble() ?? (json['finalAmount'] as num?)?.toDouble() ?? (subtotalVal + deliveryFeeVal + taxVal - discountVal);

    final createdStr = json['createdAt'] as String? ?? json['created_at'] as String? ?? json['orderDate'] as String?;
    final updatedStr = json['updatedAt'] as String? ?? json['updated_at'] as String?;

    final createdDate = createdStr != null ? (DateTime.tryParse(createdStr) ?? DateTime.now()) : DateTime.now();
    final updatedDate = updatedStr != null ? (DateTime.tryParse(updatedStr) ?? createdDate) : createdDate;

    final estTime = json['estimatedDeliveryTime'] as String? ?? json['estimated_delivery_time'] as String? ?? json['eta'] as String? ?? '10 Mins';

    DeliveryAddressModel address;
    if (json['deliveryAddress'] is Map<String, dynamic>) {
      address = DeliveryAddressModel.fromJson(json['deliveryAddress'] as Map<String, dynamic>);
    } else if (json['deliveryAddress'] is String && (json['deliveryAddress'] as String).isNotEmpty) {
      address = DeliveryAddressModel(
        id: 'addr-snap',
        name: json['customerName'] as String? ?? 'Customer',
        phone: '+91 98765 43210',
        house: json['deliveryAddress'] as String,
        street: '',
        landmark: '',
        city: 'Bangalore',
        state: 'Karnataka',
        postalCode: '560001',
      );
    } else {
      address = const DeliveryAddressModel(
        id: 'default',
        name: 'Arav Sharma',
        phone: '+91 91234 56789',
        house: 'Flat 402, Lotus Heights',
        street: '8th Main, Koramangala 4th Block',
        landmark: 'Opposite Sony World Signal',
        city: 'Bangalore',
        state: 'Karnataka',
        postalCode: '560034',
      );
    }

    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    final itemsList = itemsRaw.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList();

    return OrderModel(
      id: rawId,
      orderNumber: rawOrderNum,
      userId: rawUserId,
      storeId: rawStoreId,
      status: parsedStatus,
      paymentStatus: parsedPaymentStatus,
      paymentMethod: parsedPaymentMethod,
      subtotal: subtotalVal,
      discount: discountVal,
      deliveryFee: deliveryFeeVal,
      tax: taxVal,
      total: totalVal,
      createdAt: createdDate,
      updatedAt: updatedDate,
      estimatedDeliveryTime: estTime,
      deliveryAddress: address,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'storeId': storeId,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'deliveryAddress': deliveryAddress.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? storeId,
    OrderStatusEnum? status,
    PaymentStatusEnum? paymentStatus,
    PaymentMethodEnum? paymentMethod,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? tax,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? estimatedDeliveryTime,
    DeliveryAddressModel? deliveryAddress,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
    );
  }
}
