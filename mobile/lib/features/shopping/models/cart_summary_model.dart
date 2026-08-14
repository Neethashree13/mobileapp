// import 'package:flashcart_ai/features/home/models/home_models.dart';
// import 'package:flashcart_ai/features/shopping/models/shopping_models.dart';

// double _toDouble(dynamic val, [double defaultValue = 0.0]) {
//   if (val == null) return defaultValue;
//   if (val is num) return val.toDouble();
//   if (val is String) return double.tryParse(val) ?? defaultValue;
//   return defaultValue;
// }

// int _toInt(dynamic val, [int defaultValue = 0]) {
//   if (val == null) return defaultValue;
//   if (val is num) return val.toInt();
//   if (val is String) return int.tryParse(val) ?? defaultValue;
//   return defaultValue;
// }

// class AppliedCouponModel {
//   final String code;
//   final double discountAmount;

//   const AppliedCouponModel({
//     required this.code,
//     required this.discountAmount,
//   });

//   factory AppliedCouponModel.fromJson(Map<String, dynamic> json) {
//     return AppliedCouponModel(
//       code: json['code'] as String? ?? '',
//       discountAmount: _toDouble(json['discountAmount']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'code': code,
//         'discountAmount': discountAmount,
//       };
// }

// class CartSummaryModel {
//   final List<CartItem> items;
//   final List<CartItem> savedForLater;
//   final int itemCount;
//   final double subtotal;
//   final double originalSubtotal;
//   final double savings;
//   final double freeDeliveryThreshold;
//   final double amountForFreeDelivery;
//   final double deliveryFee;
//   final double tax;
//   final double platformFee;
//   final double packingCharges;
//   final AppliedCouponModel? appliedCoupon;
//   final double total;
//   final String estimatedDeliveryTime;
//   final bool isCartValid;

//   const CartSummaryModel({
//     required this.items,
//     required this.savedForLater,
//     required this.itemCount,
//     required this.subtotal,
//     required this.originalSubtotal,
//     required this.savings,
//     required this.freeDeliveryThreshold,
//     required this.amountForFreeDelivery,
//     required this.deliveryFee,
//     required this.tax,
//     required this.platformFee,
//     required this.packingCharges,
//     this.appliedCoupon,
//     required this.total,
//     required this.estimatedDeliveryTime,
//     required this.isCartValid,
//   });

//   factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
//     final rawItems = json['items'] as List<dynamic>? ?? [];
//     final itemsList = rawItems.map((item) => _cartItemFromJson(item as Map<String, dynamic>)).toList();

//     final rawSaved = json['savedForLater'] as List<dynamic>? ?? [];
//     final savedList = rawSaved.map((item) => _cartItemFromJson(item as Map<String, dynamic>, isSaved: true)).toList();

//     return CartSummaryModel(
//       items: itemsList,
//       savedForLater: savedList,
//       itemCount: json['itemCount'] != null ? _toInt(json['itemCount']) : itemsList.fold(0, (sum, i) => sum + i.quantity),
//       subtotal: _toDouble(json['subtotal']),
//       originalSubtotal: _toDouble(json['originalSubtotal']),
//       savings: _toDouble(json['savings']),
//       freeDeliveryThreshold: _toDouble(json['freeDeliveryThreshold'], 199.0),
//       amountForFreeDelivery: _toDouble(json['amountForFreeDelivery']),
//       deliveryFee: _toDouble(json['deliveryFee']),
//       tax: _toDouble(json['tax']),
//       platformFee: _toDouble(json['platformFee']),
//       packingCharges: _toDouble(json['packingCharges']),
//       appliedCoupon: json['appliedCoupon'] != null && json['appliedCoupon'] is Map
//           ? AppliedCouponModel.fromJson(json['appliedCoupon'] as Map<String, dynamic>)
//           : null,
//       total: _toDouble(json['total']),
//       estimatedDeliveryTime: json['estimatedDeliveryTime'] as String? ?? '8 - 12 Mins',
//       isCartValid: json['isCartValid'] as bool? ?? true,
//     );
//   }

//   static CartItem _cartItemFromJson(Map<String, dynamic> json, {bool isSaved = false}) {
//     final productMap = json['product'] as Map<String, dynamic>? ?? {};
//     final Product product = Product.fromJson(productMap);

//     return CartItem(
//       product: product,
//       quantity: _toInt(json['quantity'], 1),
//       storeName: json['addedBy'] as String? ?? 'FlashCart Fresh Store',
//       isSavedForLater: json['isSavedForLater'] as bool? ?? isSaved,
//     );
//   }
// }
import '../../home/models/home_models.dart';
import 'shopping_models.dart';

double _toDouble(dynamic val, [double defaultValue = 0.0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? defaultValue;
  return defaultValue;
}

int _toInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultValue;
  return defaultValue;
}

class AppliedCouponModel {
  final String code;
  final double discountAmount;

  const AppliedCouponModel({
    required this.code,
    required this.discountAmount,
  });

  factory AppliedCouponModel.fromJson(Map<String, dynamic> json) {
    return AppliedCouponModel(
      code: json['code'] as String? ?? '',
      discountAmount: _toDouble(json['discountAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discountAmount': discountAmount,
      };
}

class CartSummaryModel {
  final List<CartItem> items;
  final List<CartItem> savedForLater;
  final int itemCount;
  final double subtotal;
  final double originalSubtotal;
  final double savings;
  final double freeDeliveryThreshold;
  final double amountForFreeDelivery;
  final double deliveryFee;
  final double tax;
  final double platformFee;
  final double packingCharges;
  final AppliedCouponModel? appliedCoupon;
  final double total;
  final String estimatedDeliveryTime;
  final bool isCartValid;

  const CartSummaryModel({
    required this.items,
    required this.savedForLater,
    required this.itemCount,
    required this.subtotal,
    required this.originalSubtotal,
    required this.savings,
    required this.freeDeliveryThreshold,
    required this.amountForFreeDelivery,
    required this.deliveryFee,
    required this.tax,
    required this.platformFee,
    required this.packingCharges,
    this.appliedCoupon,
    required this.total,
    required this.estimatedDeliveryTime,
    required this.isCartValid,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((item) => _cartItemFromJson(item as Map<String, dynamic>)).toList();

    final rawSaved = json['savedForLater'] as List<dynamic>? ?? [];
    final savedList = rawSaved.map((item) => _cartItemFromJson(item as Map<String, dynamic>, isSaved: true)).toList();

    return CartSummaryModel(
      items: itemsList,
      savedForLater: savedList,
      itemCount: json['itemCount'] != null ? _toInt(json['itemCount']) : itemsList.fold(0, (sum, i) => sum + i.quantity),
      subtotal: _toDouble(json['subtotal']),
      originalSubtotal: _toDouble(json['originalSubtotal']),
      savings: _toDouble(json['savings']),
      freeDeliveryThreshold: _toDouble(json['freeDeliveryThreshold'], 199.0),
      amountForFreeDelivery: _toDouble(json['amountForFreeDelivery']),
      deliveryFee: _toDouble(json['deliveryFee']),
      tax: _toDouble(json['tax']),
      platformFee: _toDouble(json['platformFee']),
      packingCharges: _toDouble(json['packingCharges']),
      appliedCoupon: json['appliedCoupon'] != null && json['appliedCoupon'] is Map
          ? AppliedCouponModel.fromJson(json['appliedCoupon'] as Map<String, dynamic>)
          : null,
      total: _toDouble(json['total']),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String? ?? '8 - 12 Mins',
      isCartValid: json['isCartValid'] as bool? ?? true,
    );
  }

  static CartItem _cartItemFromJson(Map<String, dynamic> json, {bool isSaved = false}) {
    final productMap = json['product'] as Map<String, dynamic>? ?? {};
    final Product product = Product.fromJson(productMap);

    return CartItem(
      product: product,
      quantity: _toInt(json['quantity'], 1),
      storeName: json['addedBy'] as String? ?? 'FlashCart Fresh Store',
      isSavedForLater: json['isSavedForLater'] as bool? ?? isSaved,
    );
  }
}
