import 'package:flutter/material.dart';
import '../../home/models/home_models.dart';

// 1. Cart Item Model
class CartItem {
  final Product product;
  final int quantity;
  final String storeName;
  final bool isSavedForLater;

  const CartItem({
    required this.product,
    required this.quantity,
    this.storeName = 'FlashCart Fresh Store',
    this.isSavedForLater = false,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? storeName,
    bool? isSavedForLater,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      storeName: storeName ?? this.storeName,
      isSavedForLater: isSavedForLater ?? this.isSavedForLater,
    );
  }
}

// 2. Address Model
enum AddressTag { home, office, hotel, friend, other }

class Address {
  final String id;
  final AddressTag tag;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.tag,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  String get label {
    switch (tag) {
      case AddressTag.home:
        return 'Home';
      case AddressTag.office:
        return 'Office';
      case AddressTag.hotel:
        return 'Hotel';
      case AddressTag.friend:
        return 'Friend\'s Place';
      case AddressTag.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (tag) {
      case AddressTag.home:
        return Icons.home_rounded;
      case AddressTag.office:
        return Icons.business_rounded;
      case AddressTag.hotel:
        return Icons.hotel_rounded;
      case AddressTag.friend:
        return Icons.people_rounded;
      case AddressTag.other:
        return Icons.location_on_rounded;
    }
  }

  Address copyWith({
    String? id,
    AddressTag? tag,
    String? recipientName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromJson(dynamic json) {
    if (json is String) {
      return Address(
        id: 'addr-json',
        tag: AddressTag.home,
        recipientName: 'Arav Sharma',
        phone: '+91 91234 56789',
        addressLine1: json,
        addressLine2: '',
        city: 'Bangalore',
        state: 'Karnataka',
        zipCode: '560034',
        latitude: 12.934,
        longitude: 77.61,
      );
    }
    if (json is Map<String, dynamic>) {
      return Address(
        id: json['id'] as String? ?? 'addr-json',
        tag: AddressTag.home,
        recipientName: json['recipientName'] as String? ?? json['name'] as String? ?? 'Arav Sharma',
        phone: json['phone'] as String? ?? '+91 91234 56789',
        addressLine1: json['addressLine1'] as String? ?? json['address'] as String? ?? '',
        addressLine2: json['addressLine2'] as String? ?? '',
        city: json['city'] as String? ?? 'Bangalore',
        state: json['state'] as String? ?? 'Karnataka',
        zipCode: json['zipCode'] as String? ?? '560034',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 12.934,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 77.61,
        isDefault: json['isDefault'] as bool? ?? false,
      );
    }
    return const Address(
      id: 'default',
      tag: AddressTag.home,
      recipientName: 'Arav Sharma',
      phone: '+91 91234 56789',
      addressLine1: '123 Main St',
      addressLine2: '',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560034',
      latitude: 12.934,
      longitude: 77.61,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}

// 3. Coupon Model
class Coupon {
  final String id;
  final String code;
  final String description;
  final double discountAmount;
  final double minOrderValue;
  final double? discountPercentage;
  final bool isBestValue;
  final bool isExpired;
  final String expiryDate;
  final bool _isFreeDelivery;

  Coupon({
    this.id = '',
    required this.code,
    required this.description,
    this.discountAmount = 0.0,
    double minOrderValue = 0.0,
    double? minBasketValue,
    this.discountPercentage,
    this.isBestValue = false,
    this.isExpired = false,
    dynamic expiryDate = '',
    bool isFreeDelivery = false,
  })  : minOrderValue = minBasketValue ?? minOrderValue,
        expiryDate = expiryDate is DateTime ? expiryDate.toString() : (expiryDate?.toString() ?? ''),
        _isFreeDelivery = isFreeDelivery;

  bool get isFreeDelivery => _isFreeDelivery || discountAmount == 0 || description.toLowerCase().contains('free delivery');
  double get minBasketValue => minOrderValue;
}

// 4. Wallet Transaction Model
enum TransactionType { credit, debit }

class WalletTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category; // 'Cashback', 'Rewards', 'Referral', 'Refund', 'Payment'

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });
}

class TimelineStep {
  final String title;
  final String subtitle;
  final String? time;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  const TimelineStep({
    required this.title,
    required this.subtitle,
    this.time,
    this.icon = Icons.check_circle_outline,
    this.isActive = false,
    this.isCompleted = false,
  });
}

// 5. Order Model
enum OrderStatus { active, delivered, cancelled, returned }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final DateTime orderDate;
  final OrderStatus status;
  final String rawStatus;
  final String paymentMethod;
  final Address deliveryAddress;
  final double subTotal;
  final double deliveryCharges;
  final double platformFee;
  final double taxes;
  final double discount;
  final double finalAmount;
  final String? deliveryInstructions;
  final double? rating;
  final String? reviewText;
  final String deliverySlot;
  final String otp;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String eta;
  final int trackingStep;
  final List<TimelineStep>? timeline;
  final String? invoiceNumber;

  double get subtotal => subTotal;

  const OrderModel({
    required this.id,
    required this.items,
    required this.orderDate,
    required this.status,
    this.rawStatus = 'PLACED',
    required this.paymentMethod,
    required this.deliveryAddress,
    double? subtotal,
    double subTotal = 0.0,
    required this.deliveryCharges,
    required this.platformFee,
    required this.taxes,
    required this.discount,
    required this.finalAmount,
    this.deliveryInstructions,
    this.rating,
    this.reviewText,
    required this.deliverySlot,
    this.otp = '4829',
    this.driverName = 'Rajesh Kumar',
    this.driverPhone = '+91 91234 56789',
    this.vehicleNumber = 'KA-03-HA-8842 (Ather EV)',
    this.eta = '9 mins',
    this.trackingStep = 1,
    this.timeline,
    this.invoiceNumber,
  }) : subTotal = subtotal ?? subTotal;

  static OrderStatus _parseOrderStatus(String? statusStr) {
    if (statusStr == null) return OrderStatus.active;
    final s = statusStr.toUpperCase();
    if (s == 'DELIVERED' || s == 'COMPLETED') {
      return OrderStatus.delivered;
    } else if (s == 'CANCELLED' || s == 'CANCELED') {
      return OrderStatus.cancelled;
    } else if (s == 'RETURNED') {
      return OrderStatus.returned;
    } else {
      return OrderStatus.active;
    }
  }

  static List<TimelineStep>? _parseTimeline(dynamic timelineJson) {
    if (timelineJson is! List) return null;
    return timelineJson.map((e) {
      if (e is Map<String, dynamic>) {
        final status = e['status'] as String? ?? '';
        final title = e['title'] as String? ?? status;
        final timestamp = e['timestamp'] as String? ?? '';
        final completed = e['completed'] as bool? ?? false;
        final notes = e['notes'] as String? ?? '';
        return TimelineStep(
          title: title,
          subtitle: notes.isNotEmpty ? notes : title,
          time: timestamp != 'Pending' ? timestamp : null,
          isCompleted: completed,
          isActive: completed && timestamp != 'Pending',
          icon: completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        );
      }
      return const TimelineStep(title: 'Order Status', subtitle: '');
    }).toList();
  }

  static CartItem _parseCartItem(Map<String, dynamic> itemJson) {
    final prodJson = itemJson['product'];
    Product product;
    if (prodJson is Map<String, dynamic>) {
      product = Product.fromJson(prodJson);
    } else {
      product = Product.fromJson({
        'id': itemJson['productId'] as String? ?? 'p-unknown',
        'name': itemJson['productName'] as String? ?? itemJson['name'] as String? ?? 'Item',
        'category': 'Grocery',
        'price': (itemJson['price'] as num?)?.toDouble() ?? 0.0,
        'unit': itemJson['unit'] as String? ?? '1 pc',
        'image': itemJson['image'] as String? ?? 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120',
        'rating': 4.8,
        'reviewsCount': 10,
      });
    }
    final qty = (itemJson['quantity'] as num?)?.toInt() ?? 1;
    final store = itemJson['storeName'] as String? ?? 'FlashCart Fresh Store';
    return CartItem(
      product: product,
      quantity: qty,
      storeName: store,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((i) => _parseCartItem(i as Map<String, dynamic>))
            .toList() ??
        [];

    final dateStr = json['createdAt'] as String? ?? json['orderDate'] as String?;
    final DateTime date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();

    final rawStatusStr = json['status'] as String? ?? 'PLACED';
    final orderStatus = _parseOrderStatus(rawStatusStr);

    Address address;
    if (json['deliveryAddress'] is Map<String, dynamic>) {
      address = Address.fromJson(json['deliveryAddress']);
    } else if (json['deliveryAddress'] is String && (json['deliveryAddress'] as String).isNotEmpty) {
      final addrStr = json['deliveryAddress'] as String;
      address = Address(
        id: 'addr-order',
        tag: AddressTag.home,
        recipientName: json['customerName'] as String? ?? 'Arav Sharma',
        phone: '+91 91234 56789',
        addressLine1: addrStr,
        addressLine2: '',
        city: 'Bangalore',
        state: 'Karnataka',
        zipCode: '560034',
        latitude: 12.934,
        longitude: 77.61,
      );
    } else {
      address = const Address(
        id: 'default',
        tag: AddressTag.home,
        recipientName: 'Arav Sharma',
        phone: '+91 91234 56789',
        addressLine1: 'Symphony Premium Apts, Koramangala',
        addressLine2: '3rd Block',
        city: 'Bangalore',
        state: 'Karnataka',
        zipCode: '560034',
        latitude: 12.934,
        longitude: 77.61,
      );
    }

    final subtotal = (json['subtotal'] as num?)?.toDouble() ?? (json['subTotal'] as num?)?.toDouble() ?? 0.0;
    final deliveryFee = (json['deliveryFee'] as num?)?.toDouble() ?? (json['deliveryCharges'] as num?)?.toDouble() ?? 0.0;
    final platformFee = (json['platformFee'] as num?)?.toDouble() ?? 5.0;
    final tax = (json['tax'] as num?)?.toDouble() ?? (json['taxes'] as num?)?.toDouble() ?? 0.0;
    final discount = (json['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total'] as num?)?.toDouble() ?? (json['finalAmount'] as num?)?.toDouble() ?? (subtotal + deliveryFee + platformFee + tax - discount);

    return OrderModel(
      id: json['id'] as String? ?? '',
      items: itemsList,
      orderDate: date,
      status: orderStatus,
      rawStatus: rawStatusStr,
      paymentMethod: json['paymentMethod'] as String? ?? 'Wallet Pay',
      deliveryAddress: address,
      subTotal: subtotal,
      deliveryCharges: deliveryFee,
      platformFee: platformFee,
      taxes: tax,
      discount: discount,
      finalAmount: total,
      deliveryInstructions: json['notes'] as String? ?? json['deliveryInstructions'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewText: json['reviewText'] as String?,
      deliverySlot: json['scheduledTime'] as String? ?? json['deliverySlot'] as String? ?? 'Express (10 Mins)',
      otp: json['otp'] as String? ?? '4829',
      driverName: json['driverName'] as String? ?? 'Rajesh Kumar',
      driverPhone: json['driverPhone'] as String? ?? '+91 91234 56789',
      vehicleNumber: json['vehicleNumber'] as String? ?? 'KA-03-HA-8842 (Ather EV)',
      eta: json['estimatedDeliveryTime'] as String? ?? json['eta'] as String? ?? '9 mins',
      trackingStep: (json['trackingStep'] as num?)?.toInt() ?? 1,
      timeline: _parseTimeline(json['timeline']),
      invoiceNumber: json['invoiceNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => {
        'product': {
          'id': i.product.id,
          'name': i.product.name,
          'price': i.product.price,
          'unit': i.product.weight,
          'image': i.product.imageUrl,
          'category': i.product.categoryId,
        },
        'quantity': i.quantity,
        'addedBy': i.storeName,
      }).toList(),
      'subtotal': subTotal,
      'deliveryFee': deliveryCharges,
      'discount': discount,
      'tax': taxes,
      'platformFee': platformFee,
      'total': finalAmount,
      'paymentMethod': paymentMethod,
      'deliveryAddress': '${deliveryAddress.addressLine1}, ${deliveryAddress.addressLine2}',
      'notes': deliveryInstructions ?? '',
      'scheduledTime': deliverySlot,
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? rawStatus,
    double? rating,
    String? reviewText,
    int? trackingStep,
    List<TimelineStep>? timeline,
  }) {
    return OrderModel(
      id: id,
      items: items,
      orderDate: orderDate,
      status: status ?? this.status,
      rawStatus: rawStatus ?? this.rawStatus,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      subTotal: subTotal,
      deliveryCharges: deliveryCharges,
      platformFee: platformFee,
      taxes: taxes,
      discount: discount,
      finalAmount: finalAmount,
      deliveryInstructions: deliveryInstructions,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      deliverySlot: deliverySlot,
      otp: otp,
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleNumber: vehicleNumber,
      eta: eta,
      trackingStep: trackingStep ?? this.trackingStep,
      timeline: timeline ?? this.timeline,
      invoiceNumber: invoiceNumber,
    );
  }
}

// 6. Notification Model
enum NotificationCategory { offers, orders, wallet, promotions, system, order, promo }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final NotificationCategory category;
  final bool isRead;
  final DateTime date;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isRead = false,
    required this.date,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      category: category,
      isRead: isRead ?? this.isRead,
      date: date,
    );
  }
}
