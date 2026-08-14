// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flashcart_ai/features/home/models/home_models.dart';
// import 'package:flashcart_ai/features/shopping/models/shopping_models.dart';

// // ==========================================
// // 1. WISHLIST STATE NOTIFIER
// // ==========================================
// class WishlistState {
//   final List<Product> items;
//   final Set<String> selectedIds;

//   int get length => items.length;

//   const WishlistState({
//     required this.items,
//     required this.selectedIds,
//   });

//   bool contains(String productId) => items.any((item) => item.id == productId);
//   bool isFavorite(String productId) => contains(productId);

//   WishlistState copyWith({
//     List<Product>? items,
//     Set<String>? selectedIds,
//   }) {
//     return WishlistState(
//       items: items ?? this.items,
//       selectedIds: selectedIds ?? this.selectedIds,
//     );
//   }
// }

// class WishlistNotifier extends StateNotifier<WishlistState> {
//   WishlistNotifier() : super(const WishlistState(items: [], selectedIds: {}));

//   void toggleWishlist(String productId) {
//     if (state.items.any((item) => item.id == productId)) {
//       state = state.copyWith(
//         items: state.items.where((item) => item.id != productId).toList(),
//         selectedIds: state.selectedIds.difference({productId}),
//       );
//     } else {
//       final found = MockData.products.firstWhere(
//         (p) => p.id == productId,
//         orElse: () => MockData.products.first,
//       );
//       state = state.copyWith(items: [...state.items, found]);
//     }
//   }

//   void toggleFavorite(Product product) {
//     if (state.items.any((item) => item.id == product.id)) {
//       state = state.copyWith(
//         items: state.items.where((item) => item.id != product.id).toList(),
//         selectedIds: state.selectedIds.difference({product.id}),
//       );
//     } else {
//       state = state.copyWith(
//         items: [...state.items, product],
//       );
//     }
//   }

//   bool isFavorite(String productId) {
//     return state.items.any((item) => item.id == productId);
//   }

//   void toggleSelection(String productId) {
//     final currentSelected = Set<String>.from(state.selectedIds);
//     if (currentSelected.contains(productId)) {
//       currentSelected.remove(productId);
//     } else {
//       currentSelected.add(productId);
//     }
//     state = state.copyWith(selectedIds: currentSelected);
//   }

//   void clearSelection() {
//     state = state.copyWith(selectedIds: {});
//   }

//   void removeSelected() {
//     state = state.copyWith(
//       items: state.items.where((item) => !state.selectedIds.contains(item.id)).toList(),
//       selectedIds: {},
//     );
//   }

//   void removeSingle(String productId) {
//     state = state.copyWith(
//       items: state.items.where((item) => item.id != productId).toList(),
//       selectedIds: state.selectedIds.difference({productId}),
//     );
//   }
// }

// final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
//   return WishlistNotifier();
// });

// // ==========================================
// // 2. CART STATE NOTIFIER
// // ==========================================
// class CartState {
//   final List<CartItem> items;
//   final Coupon? appliedCoupon;
//   final double deliveryTip;
//   final bool useWallet;

//   const CartState({
//     required this.items,
//     this.appliedCoupon,
//     this.deliveryTip = 0.0,
//     this.useWallet = false,
//   });

//   CartState copyWith({
//     List<CartItem>? items,
//     Coupon? Function()? appliedCoupon,
//     double? deliveryTip,
//     bool? useWallet,
//   }) {
//     return CartState(
//       items: items ?? this.items,
//       appliedCoupon: appliedCoupon != null ? appliedCoupon() : this.appliedCoupon,
//       deliveryTip: deliveryTip ?? this.deliveryTip,
//       useWallet: useWallet ?? this.useWallet,
//     );
//   }

//   int getQuantity(String productId) {
//     final item = items.where((i) => i.product.id == productId && !i.isSavedForLater).firstOrNull;
//     return item?.quantity ?? 0;
//   }

//   int operator [](String productId) => getQuantity(productId);

//   int get totalItems => items.where((i) => !i.isSavedForLater).fold(0, (sum, i) => sum + i.quantity);

//   double get subtotal {
//     return items
//         .where((item) => !item.isSavedForLater)
//         .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
//   }

//   double get deliveryFee {
//     if (subtotal == 0.0) return 0.0;
//     return subtotal > 15.0 ? 0.0 : 1.99; // Free above $15
//   }

//   double get platformFee {
//     if (subtotal == 0.0) return 0.0;
//     return 0.49;
//   }

//   double get taxes {
//     return subtotal * 0.08; // 8% Tax
//   }

//   double get discount {
//     if (appliedCoupon == null) return 0.0;
//     if (appliedCoupon!.discountPercentage != null) {
//       return subtotal * (appliedCoupon!.discountPercentage! / 100);
//     }
//     return appliedCoupon!.discountAmount;
//   }

//   double get walletDeduction {
//     if (!useWallet) return 0.0;
//     const mockWalletBal = 15.0; // Mock wallet balance
//     final totalBeforeWallet = (subtotal + deliveryFee + platformFee + taxes + deliveryTip) - discount;
//     if (totalBeforeWallet <= 0) return 0.0;
//     return totalBeforeWallet >= mockWalletBal ? mockWalletBal : totalBeforeWallet;
//   }

//   double get total {
//     final finalAmount = (subtotal + deliveryFee + platformFee + taxes + deliveryTip) - discount - walletDeduction;
//     return finalAmount < 0 ? 0.0 : finalAmount;
//   }
// }

// class CartNotifier extends StateNotifier<CartState> {
//   CartNotifier() : super(const CartState(items: []));

//   void addToCart(dynamic productOrId, {int quantity = 1, String storeName = 'FlashCart Fresh Store'}) {
//     Product? product;
//     if (productOrId is Product) {
//       product = productOrId;
//     } else if (productOrId is String) {
//       product = MockData.products.firstWhere(
//         (p) => p.id == productOrId,
//         orElse: () => MockData.products.first,
//       );
//     }
//     if (product == null) return;

//     final existingIndex = state.items.indexWhere((item) => item.product.id == product!.id && !item.isSavedForLater);
//     if (existingIndex >= 0) {
//       final existingItem = state.items[existingIndex];
//       final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + quantity);
//       final updatedList = List<CartItem>.from(state.items);
//       updatedList[existingIndex] = updatedItem;
//       state = state.copyWith(items: updatedList);
//     } else {
//       state = state.copyWith(items: [
//         ...state.items,
//         CartItem(product: product, quantity: quantity, storeName: storeName),
//       ]);
//     }
//   }

//   void updateQuantity(String productId, int quantity, {bool isSaved = false}) {
//     if (quantity <= 0) {
//       removeFromCart(productId, isSaved: isSaved);
//       return;
//     }
//     final updatedList = state.items.map((item) {
//       if (item.product.id == productId && item.isSavedForLater == isSaved) {
//         return item.copyWith(quantity: quantity);
//       }
//       return item;
//     }).toList();
//     state = state.copyWith(items: updatedList);
//   }

//   void removeFromCart(String productId, {bool isSaved = false}) {
//     state = state.copyWith(
//       items: state.items.where((item) => !(item.product.id == productId && item.isSavedForLater == isSaved)).toList(),
//     );
//   }

//   void toggleSaveForLater(String productId, bool currentlySaved) {
//     state = state.copyWith(
//       items: state.items.map((item) {
//         if (item.product.id == productId && item.isSavedForLater == currentlySaved) {
//           return item.copyWith(isSavedForLater: !currentlySaved);
//         }
//         return item;
//       }).toList(),
//     );
//   }

//   void applyCoupon(Coupon coupon) {
//     state = state.copyWith(appliedCoupon: () => coupon);
//   }

//   void removeCoupon() {
//     state = state.copyWith(appliedCoupon: () => null);
//   }

//   void selectTip(double tip) {
//     state = state.copyWith(deliveryTip: tip);
//   }

//   void toggleWallet(bool value) {
//     state = state.copyWith(useWallet: value);
//   }

//   void clearCart() {
//     state = const CartState(items: []);
//   }
// }

// final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
//   return CartNotifier();
// });

// // ==========================================
// // 3. ADDRESS STATE NOTIFIER
// // ==========================================
// class AddressNotifier extends StateNotifier<List<Address>> {
//   AddressNotifier() : super([]) {
//     state = [
//       const Address(
//         id: 'addr1',
//         tag: AddressTag.home,
//         recipientName: 'Neetha Shree',
//         phone: '+91 98765 43210',
//         addressLine1: 'Villa 24, Greenwood Residency',
//         addressLine2: 'Sarjapur Main Road, Harlur',
//         city: 'Bengaluru',
//         state: 'Karnataka',
//         zipCode: '560102',
//         latitude: 12.9141,
//         longitude: 77.6669,
//         isDefault: true,
//       ),
//       const Address(
//         id: 'addr2',
//         tag: AddressTag.office,
//         recipientName: 'Neetha Shree (Office)',
//         phone: '+91 98765 43210',
//         addressLine1: 'Block C, Embassy Tech Village',
//         addressLine2: 'Outer Ring Road, Devarabisanahalli',
//         city: 'Bengaluru',
//         state: 'Karnataka',
//         zipCode: '560103',
//         latitude: 12.9272,
//         longitude: 77.6844,
//       ),
//       const Address(
//         id: 'addr3',
//         tag: AddressTag.hotel,
//         recipientName: 'Neetha S.',
//         phone: '+91 98765 43210',
//         addressLine1: 'Room 502, Ritz-Carlton Hotel',
//         addressLine2: 'Residency Road, Shanthala Nagar',
//         city: 'Bengaluru',
//         state: 'Karnataka',
//         zipCode: '560025',
//         latitude: 12.9698,
//         longitude: 77.5996,
//       ),
//     ];
//   }

//   Address get defaultAddress {
//     return state.firstWhere((addr) => addr.isDefault, orElse: () => state.first);
//   }

//   void setDefault(String id) {
//     state = state.map((addr) {
//       return addr.copyWith(isDefault: addr.id == id);
//     }).toList();
//   }

//   void addAddress(Address address) {
//     if (address.isDefault) {
//       state = state.map((addr) => addr.copyWith(isDefault: false)).toList();
//     }
//     state = [...state, address];
//   }

//   void updateAddress(Address updated) {
//     if (updated.isDefault) {
//       state = state.map((addr) {
//         if (addr.id == updated.id) {
//           return updated;
//         } else {
//           return addr.copyWith(isDefault: false);
//         }
//       }).toList();
//     } else {
//       state = state.map((addr) => addr.id == updated.id ? updated : addr).toList();
//     }
//   }

//   void deleteAddress(String id) {
//     final wasDefault = state.any((addr) => addr.id == id && addr.isDefault);
//     state = state.where((addr) => addr.id != id).toList();
//     if (wasDefault && state.isNotEmpty) {
//       state = [
//         state.first.copyWith(isDefault: true),
//         ...state.sublist(1),
//       ];
//     }
//   }
// }

// final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
//   return AddressNotifier();
// });

// // ==========================================
// // 4. ORDERS STATE NOTIFIER
// // ==========================================
// class OrdersNotifier extends StateNotifier<List<OrderModel>> {
//   OrdersNotifier() : super([]);

//   void placeOrder(OrderModel order) {
//     state = [order, ...state];
//   }

//   void updateOrderStatus(String orderId, OrderStatus status) {
//     state = state.map((order) {
//       if (order.id == orderId) {
//         return order.copyWith(status: status);
//       }
//       return order;
//     }).toList();
//   }

//   void addReview(String orderId, double rating, String review) {
//     state = state.map((order) {
//       if (order.id == orderId) {
//         return order.copyWith(rating: rating, reviewText: review);
//       }
//       return order;
//     }).toList();
//   }
// }

// final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
//   return OrdersNotifier();
// });

// // ==========================================
// // 5. WALLET STATE NOTIFIER
// // ==========================================
// class WalletState {
//   final double balance;
//   final double cashback;
//   final List<WalletTransaction> transactions;

//   double get rewardsEarned => cashback + 12.50;

//   const WalletState({
//     required this.balance,
//     required this.cashback,
//     required this.transactions,
//   });

//   WalletState copyWith({
//     double? balance,
//     double? cashback,
//     List<WalletTransaction>? transactions,
//   }) {
//     return WalletState(
//       balance: balance ?? this.balance,
//       cashback: cashback ?? this.cashback,
//       transactions: transactions ?? this.transactions,
//     );
//   }
// }

// class WalletNotifier extends StateNotifier<WalletState> {
//   WalletNotifier()
//       : super(WalletState(
//           balance: 15.00,
//           cashback: 4.50,
//           transactions: [
//             WalletTransaction(
//               id: 'TXN-101',
//               title: 'Cashback Credited',
//               description: 'Cashback from Order #ORD-984218',
//               amount: 2.50,
//               type: TransactionType.credit,
//               date: DateTime.now().subtract(const Duration(days: 3)),
//               category: 'Cashback',
//             ),
//             WalletTransaction(
//               id: 'TXN-102',
//               title: 'Referral Bonus',
//               description: 'Referred friend Amith S.',
//               amount: 5.00,
//               type: TransactionType.credit,
//               date: DateTime.now().subtract(const Duration(days: 6)),
//               category: 'Referral',
//             ),
//             WalletTransaction(
//               id: 'TXN-103',
//               title: 'Wallet Top-up',
//               description: 'Added money via GPay',
//               amount: 10.00,
//               type: TransactionType.credit,
//               date: DateTime.now().subtract(const Duration(days: 10)),
//               category: 'Rewards',
//             ),
//             WalletTransaction(
//               id: 'TXN-104',
//               title: 'Order Paid',
//               description: 'Paid for Order #ORD-661204',
//               amount: 3.00,
//               type: TransactionType.debit,
//               date: DateTime.now().subtract(const Duration(days: 12)),
//               category: 'Payment',
//             ),
//           ],
//         ));

//   void loadCash(double amount) {
//     state = state.copyWith(
//       balance: state.balance + amount,
//       transactions: [
//         WalletTransaction(
//           id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
//           title: 'Wallet Top-up',
//           description: 'Added cash to wallet',
//           amount: amount,
//           type: TransactionType.credit,
//           date: DateTime.now(),
//           category: 'Top-up',
//         ),
//         ...state.transactions,
//       ],
//     );
//   }

//   void deductWallet(double amount) {
//     if (state.balance >= amount) {
//       state = state.copyWith(
//         balance: state.balance - amount,
//         transactions: [
//           WalletTransaction(
//             id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
//             title: 'Payment Debited',
//             description: 'Order Checkout partial payment',
//             amount: amount,
//             type: TransactionType.debit,
//             date: DateTime.now(),
//             category: 'Payment',
//           ),
//           ...state.transactions,
//         ],
//       );
//     }
//   }

//   void addCashback(double amount) {
//     state = state.copyWith(
//       cashback: state.cashback + amount,
//       transactions: [
//         WalletTransaction(
//           id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
//           title: 'Cashback Received',
//           description: 'Checkout Cashback Reward',
//           amount: amount,
//           type: TransactionType.credit,
//           date: DateTime.now(),
//           category: 'Cashback',
//         ),
//         ...state.transactions,
//       ],
//     );
//   }
// }

// final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
//   return WalletNotifier();
// });

// // ==========================================
// // 6. COUPON PROVIDER (Seeded Static List)
// // ==========================================
// final couponsProvider = Provider<List<Coupon>>((ref) {
//   return const [
//     Coupon(
//       code: 'FLASHFAST',
//       description: 'Get Flat \$3.00 off on order above \$10.00. Best value offer!',
//       discountAmount: 3.0,
//       minOrderValue: 10.0,
//       isBestValue: true,
//       expiryDate: '28 Jul 2026',
//     ),
//     Coupon(
//       code: 'WELCOME50',
//       description: 'Get 50% discount up to \$5.00 on your first FlashCart order.',
//       discountAmount: 5.0,
//       minOrderValue: 8.0,
//       discountPercentage: 50.0,
//       expiryDate: '15 Aug 2026',
//     ),
//     Coupon(
//       code: 'SUPERMUNCH',
//       description: 'Flat \$1.50 Off on Snacks and munchies above \$6.00.',
//       discountAmount: 1.5,
//       minOrderValue: 6.0,
//       expiryDate: '30 Jul 2026',
//     ),
//     Coupon(
//       code: 'EXP99',
//       description: 'Flat \$4.00 off on your order.',
//       discountAmount: 4.0,
//       minOrderValue: 12.0,
//       isExpired: true,
//       expiryDate: '10 Jul 2026',
//     ),
//   ];
// });

// // ==========================================
// // 7. NOTIFICATIONS STATE NOTIFIER
// // ==========================================
// class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
//   NotificationsNotifier() : super([]) {
//     state = [
//       NotificationModel(
//         id: 'n1',
//         title: '🥦 Farm Fresh Organic Alert!',
//         description: 'New seasonal organic apples and mangoes are back in stock. Order now before they fly away!',
//         category: NotificationCategory.offers,
//         date: DateTime.now().subtract(const Duration(hours: 2)),
//       ),
//       NotificationModel(
//         id: 'n2',
//         title: '🛵 Order Delivered successfully!',
//         description: 'Your order #ORD-984218 has been safely delivered to your doorstep. Rate your delivery partner now.',
//         category: NotificationCategory.orders,
//         isRead: true,
//         date: DateTime.now().subtract(const Duration(days: 3)),
//       ),
//       NotificationModel(
//         id: 'n3',
//         title: '💰 \$2.50 Cashback Credited!',
//         description: 'FlashCart Super cashback has been successfully credited to your wallet. Use it for next instant munchies.',
//         category: NotificationCategory.wallet,
//         date: DateTime.now().subtract(const Duration(days: 3)),
//       ),
//       NotificationModel(
//         id: 'n4',
//         title: '🎉 Referral Reward Waiting',
//         description: 'Invite your friends to try FlashCart and get up to \$5.00 cash back instantly on their first checkout!',
//         category: NotificationCategory.promotions,
//         isRead: true,
//         date: DateTime.now().subtract(const Duration(days: 5)),
//       ),
//     ];
//   }

//   void toggleRead(String id) {
//     state = state.map((n) => n.id == id ? n.copyWith(isRead: !n.isRead) : n).toList();
//   }

//   void markAsRead(String id) {
//     state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
//   }

//   void markAllRead() {
//     state = state.map((n) => n.copyWith(isRead: true)).toList();
//   }

//   void markAllAsRead() {
//     state = state.map((n) => n.copyWith(isRead: true)).toList();
//   }

//   void restoreNotification(NotificationModel alert) {
//     if (!state.any((n) => n.id == alert.id)) {
//       state = [...state, alert];
//     }
//   }

//   void deleteNotification(String id) {
//     state = state.where((n) => n.id != id).toList();
//   }

//   void clearAll() {
//     state = [];
//   }
// }

// final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
//   return NotificationsNotifier();
// });

// // ==========================================
// // 8. SETTINGS STATE NOTIFIER
// // ==========================================
// class SettingsState {
//   final bool isDarkMode;
//   final String selectedLanguage;
//   final bool enablePushNotifications;
//   final bool enableLocationService;
//   final bool biometricsEnabled;

//   const SettingsState({
//     required this.isDarkMode,
//     required this.selectedLanguage,
//     required this.enablePushNotifications,
//     required this.enableLocationService,
//     required this.biometricsEnabled,
//   });

//   SettingsState copyWith({
//     bool? isDarkMode,
//     String? selectedLanguage,
//     bool? enablePushNotifications,
//     bool? enableLocationService,
//     bool? biometricsEnabled,
//   }) {
//     return SettingsState(
//       isDarkMode: isDarkMode ?? this.isDarkMode,
//       selectedLanguage: selectedLanguage ?? this.selectedLanguage,
//       enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
//       enableLocationService: enableLocationService ?? this.enableLocationService,
//       biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
//     );
//   }
// }

// class SettingsNotifier extends StateNotifier<SettingsState> {
//   SettingsNotifier()
//       : super(const SettingsState(
//           isDarkMode: false,
//           selectedLanguage: 'English',
//           enablePushNotifications: true,
//           enableLocationService: true,
//           biometricsEnabled: false,
//         ));

//   void toggleTheme() {
//     state = state.copyWith(isDarkMode: !state.isDarkMode);
//   }

//   void setLanguage(String lang) {
//     state = state.copyWith(selectedLanguage: lang);
//   }

//   void toggleNotifications(bool val) {
//     state = state.copyWith(enablePushNotifications: val);
//   }

//   void toggleLocation(bool val) {
//     state = state.copyWith(enableLocationService: val);
//   }

//   void toggleBiometrics(bool val) {
//     state = state.copyWith(biometricsEnabled: val);
//   }
// }

// final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
//   return SettingsNotifier();
// });

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/home_models.dart';
import '../models/shopping_models.dart';
import '../models/cart_summary_model.dart';
import '../models/wishlist_response_model.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import '../data/repositories/order_repository.dart';

final cartRepositoryProvider = Provider<ICartRepository>((ref) => CartRepository());
final wishlistRepositoryProvider = Provider<IWishlistRepository>((ref) => WishlistRepository());
final orderRepositoryProvider = Provider<IOrderRepository>((ref) => OrderRepository());

// ==========================================
// 1. WISHLIST STATE NOTIFIER
// ==========================================
class WishlistState {
  final List<Product> items;
  final Set<String> wishlistIds;
  final Set<String> selectedIds;
  final bool isLoading;
  final String? errorMessage;

  int get length => items.length;

  const WishlistState({
    required this.items,
    required this.wishlistIds,
    required this.selectedIds,
    this.isLoading = false,
    this.errorMessage,
  });

  bool contains(String productId) => wishlistIds.contains(productId) || items.any((item) => item.id == productId);
  bool isFavorite(String productId) => contains(productId);

  WishlistState copyWith({
    List<Product>? items,
    Set<String>? wishlistIds,
    Set<String>? selectedIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WishlistState(
      items: items ?? this.items,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  final IWishlistRepository _repository;

  WishlistNotifier(this._repository)
      : super(const WishlistState(items: [], wishlistIds: {}, selectedIds: {})) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.getWishlist();
      state = state.copyWith(
        items: res.items,
        wishlistIds: res.wishlist.toSet(),
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  Future<void> refresh() async {
    await loadWishlist();
  }

  Future<void> toggleWishlist(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.toggleWishlist(productId);
      state = state.copyWith(
        items: res.items,
        wishlistIds: res.wishlist.toSet(),
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  Future<void> addToWishlist(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.addItem(productId);
      state = state.copyWith(
        items: res.items,
        wishlistIds: res.wishlist.toSet(),
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.removeItem(productId);
      state = state.copyWith(
        items: res.items,
        wishlistIds: res.wishlist.toSet(),
        selectedIds: state.selectedIds.difference({productId}),
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  Future<void> removeSingle(String productId) async {
    await removeFromWishlist(productId);
  }

  Future<void> toggleFavorite(Product product) async {
    await toggleWishlist(product.id);
  }

  bool isFavorite(String productId) {
    return state.contains(productId);
  }

  void toggleSelection(String productId) {
    final currentSelected = Set<String>.from(state.selectedIds);
    if (currentSelected.contains(productId)) {
      currentSelected.remove(productId);
    } else {
      currentSelected.add(productId);
    }
    state = state.copyWith(selectedIds: currentSelected);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  Future<void> removeSelected() async {
    if (state.selectedIds.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final idsToRemove = List<String>.from(state.selectedIds);
    try {
      WishlistResponseModel? lastRes;
      for (final id in idsToRemove) {
        lastRes = await _repository.removeItem(id);
      }
      state = state.copyWith(
        items: lastRes?.items ?? state.items,
        wishlistIds: lastRes?.wishlist.toSet() ?? state.wishlistIds,
        selectedIds: {},
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final repo = ref.watch(wishlistRepositoryProvider);
  return WishlistNotifier(repo);
});

// ==========================================
// 2. CART STATE NOTIFIER
// ==========================================
class CartState {
  final CartSummaryModel? summary;
  final Coupon? appliedCoupon;
  final double deliveryTip;
  final bool useWallet;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.summary,
    this.appliedCoupon,
    this.deliveryTip = 0.0,
    this.useWallet = false,
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    CartSummaryModel? summary,
    Coupon? Function()? appliedCoupon,
    double? deliveryTip,
    bool? useWallet,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      summary: summary ?? this.summary,
      appliedCoupon: appliedCoupon != null ? appliedCoupon() : this.appliedCoupon,
      deliveryTip: deliveryTip ?? this.deliveryTip,
      useWallet: useWallet ?? this.useWallet,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<CartItem> get items => summary?.items ?? [];
  List<CartItem> get savedForLater => summary?.savedForLater ?? [];
  int get totalItems => summary?.itemCount ?? items.where((i) => !i.isSavedForLater).fold(0, (sum, i) => sum + i.quantity);

  int getQuantity(String productId) {
    final item = items.where((i) => i.product.id == productId && !i.isSavedForLater).firstOrNull;
    return item?.quantity ?? 0;
  }

  int operator [](String productId) => getQuantity(productId);

  double get subtotal => summary?.subtotal ?? 0.0;
  double get originalSubtotal => summary?.originalSubtotal ?? 0.0;
  double get savings => summary?.savings ?? 0.0;
  double get freeDeliveryThreshold => summary?.freeDeliveryThreshold ?? 199.0;
  double get amountForFreeDelivery => summary?.amountForFreeDelivery ?? 0.0;
  double get deliveryFee => summary?.deliveryFee ?? 0.0;
  double get tax => summary?.tax ?? 0.0;
  double get taxes => summary?.tax ?? 0.0;
  double get platformFee => (summary?.platformFee ?? 0.0) + (summary?.packingCharges ?? 0.0);
  double get packingCharges => summary?.packingCharges ?? 0.0;
  double get discount => appliedCoupon?.discountAmount ?? summary?.appliedCoupon?.discountAmount ?? summary?.savings ?? 0.0;
  bool get isCartValid => summary?.isCartValid ?? true;
  String get estimatedDeliveryTime => summary?.estimatedDeliveryTime ?? '8 - 12 Mins';

  double get walletDeduction {
    if (!useWallet || summary == null) return 0.0;
    const mockWalletBal = 15.0;
    final totalBeforeWallet = summary!.total + deliveryTip;
    if (totalBeforeWallet <= 0) return 0.0;
    return totalBeforeWallet >= mockWalletBal ? mockWalletBal : totalBeforeWallet;
  }

  double get total {
    if (summary == null) return 0.0;
    final finalAmount = summary!.total + deliveryTip - walletDeduction;
    return finalAmount < 0 ? 0.0 : finalAmount;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final ICartRepository _repository;

  CartNotifier(this._repository) : super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart({String? couponCode}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.getCart(couponCode: couponCode);
      _updateFromSummary(summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> refresh() async {
    await loadCart(couponCode: state.appliedCoupon?.code);
  }

  Future<void> addToCart(dynamic productOrId, {int quantity = 1, String storeName = 'FlashCart Fresh Store'}) async {
    String productId = '';
    if (productOrId is Product) {
      productId = productOrId.id;
    } else if (productOrId is String) {
      productId = productOrId;
    }
    if (productId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.addItem(productId: productId, quantity: quantity, addedBy: storeName);
      _updateFromSummary(summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateQuantity(String productId, int quantity, {bool isSaved = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (quantity <= 0) {
        final summary = await _repository.removeItem(productId: productId);
        _updateFromSummary(summary);
      } else {
        final summary = await _repository.updateItem(productId: productId, quantity: quantity);
        _updateFromSummary(summary);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> removeFromCart(String productId, {bool isSaved = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.removeItem(productId: productId);
      _updateFromSummary(summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> removeItem(String productId) async {
    await removeFromCart(productId);
  }

  Future<void> toggleSaveForLater(String productId, bool currentlySaved) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.saveForLater(productId: productId, isSavedForLater: !currentlySaved);
      _updateFromSummary(summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> syncCart(List<Map<String, dynamic>> items) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.syncCart(items);
      _updateFromSummary(summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> applyCoupon(Coupon coupon) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.getCart(couponCode: coupon.code);
      _updateFromSummary(summary, appliedCoupon: coupon);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> removeCoupon() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.getCart(couponCode: '');
      _updateFromSummary(summary, clearCoupon: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void selectTip(double tip) {
    state = state.copyWith(deliveryTip: tip);
  }

  void toggleWallet(bool value) {
    state = state.copyWith(useWallet: value);
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.syncCart([]);
      _updateFromSummary(summary);
    } catch (e) {
      state = const CartState();
    }
  }

  void _updateFromSummary(CartSummaryModel summary, {Coupon? appliedCoupon, bool clearCoupon = false}) {
    Coupon? currentCoupon = state.appliedCoupon;
    if (clearCoupon) {
      currentCoupon = null;
    } else if (appliedCoupon != null) {
      currentCoupon = appliedCoupon;
    } else if (summary.appliedCoupon != null) {
      currentCoupon = Coupon(
        id: 'cp_backend',
        code: summary.appliedCoupon!.code,
        description: 'Backend Applied Coupon',
        discountAmount: summary.appliedCoupon!.discountAmount,
        minOrderValue: 0.0,
        expiryDate: 'Valid',
      );
    }

    state = state.copyWith(
      summary: summary,
      appliedCoupon: () => currentCoupon,
      isLoading: false,
      errorMessage: null,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(repository);
});

// ==========================================
// 3. ADDRESS STATE NOTIFIER
// ==========================================
class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super([]) {
    state = [
      const Address(
        id: 'addr1',
        tag: AddressTag.home,
        recipientName: 'Neetha Shree',
        phone: '+91 98765 43210',
        addressLine1: 'Villa 24, Greenwood Residency',
        addressLine2: 'Sarjapur Main Road, Harlur',
        city: 'Bengaluru',
        state: 'Karnataka',
        zipCode: '560102',
        latitude: 12.9141,
        longitude: 77.6669,
        isDefault: true,
      ),
      const Address(
        id: 'addr2',
        tag: AddressTag.office,
        recipientName: 'Neetha Shree (Office)',
        phone: '+91 98765 43210',
        addressLine1: 'Block C, Embassy Tech Village',
        addressLine2: 'Outer Ring Road, Devarabisanahalli',
        city: 'Bengaluru',
        state: 'Karnataka',
        zipCode: '560103',
        latitude: 12.9272,
        longitude: 77.6844,
      ),
      const Address(
        id: 'addr3',
        tag: AddressTag.hotel,
        recipientName: 'Neetha S.',
        phone: '+91 98765 43210',
        addressLine1: 'Room 502, Ritz-Carlton Hotel',
        addressLine2: 'Residency Road, Shanthala Nagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        zipCode: '560025',
        latitude: 12.9698,
        longitude: 77.5996,
      ),
    ];
  }

  Address get defaultAddress {
    return state.firstWhere((addr) => addr.isDefault, orElse: () => state.first);
  }

  void setDefault(String id) {
    state = state.map((addr) {
      return addr.copyWith(isDefault: addr.id == id);
    }).toList();
  }

  void addAddress(Address address) {
    if (address.isDefault) {
      state = state.map((addr) => addr.copyWith(isDefault: false)).toList();
    }
    state = [...state, address];
  }

  void updateAddress(Address updated) {
    if (updated.isDefault) {
      state = state.map((addr) {
        if (addr.id == updated.id) {
          return updated;
        } else {
          return addr.copyWith(isDefault: false);
        }
      }).toList();
    } else {
      state = state.map((addr) => addr.id == updated.id ? updated : addr).toList();
    }
  }

  void deleteAddress(String id) {
    final wasDefault = state.any((addr) => addr.id == id && addr.isDefault);
    state = state.where((addr) => addr.id != id).toList();
    if (wasDefault && state.isNotEmpty) {
      state = [
        state.first.copyWith(isDefault: true),
        ...state.sublist(1),
      ];
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier();
});

// ==========================================
// 4. ORDERS STATE NOTIFIER
// ==========================================
class OrdersState with IterableMixin<OrderModel> {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;
  final OrderModel? selectedOrder;

  const OrdersState({
    required this.orders,
    this.isLoading = false,
    this.errorMessage,
    this.selectedOrder,
  });

  @override
  Iterator<OrderModel> get iterator => orders.iterator;

  OrderModel operator [](int index) => orders[index];

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
    OrderModel? selectedOrder,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final IOrderRepository _repository;

  OrdersNotifier(this._repository)
      : super(const OrdersState(orders: [], isLoading: true)) {
    loadOrders();
  }

  Future<void> loadOrders({String? status, String? search}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final fetched = await _repository.getOrders(status: status, search: search);
      state = state.copyWith(orders: fetched, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }

  Future<OrderModel?> getOrderById(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final order = await _repository.getOrderById(id);
      final updatedList = [...state.orders];
      final idx = updatedList.indexWhere((o) => o.id == id);
      if (idx >= 0) {
        updatedList[idx] = order;
      } else {
        updatedList.insert(0, order);
      }
      state = state.copyWith(
        orders: updatedList,
        selectedOrder: order,
        isLoading: false,
      );
      return order;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<OrderModel?> placeOrder(OrderModel newOrder) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final placed = await _repository.placeOrder(newOrder);
      state = state.copyWith(
        orders: [placed, ...state.orders],
        isLoading: false,
      );
      return placed;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> cancelOrder(String id, {String? reason}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ok = await _repository.cancelOrder(id, reason: reason);
      if (ok) {
        await loadOrders();
      }
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> reorder(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ok = await _repository.reorder(id);
      state = state.copyWith(isLoading: false);
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<List<TimelineStep>?> getOrderTracking(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tracking = await _repository.getOrderTracking(id);
      state = state.copyWith(isLoading: false);
      return tracking;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    state = state.copyWith(
      orders: state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: status);
        }
        return order;
      }).toList(),
    );
  }

  void addReview(String orderId, double rating, String review) {
    state = state.copyWith(
      orders: state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(rating: rating, reviewText: review);
        }
        return order;
      }).toList(),
    );
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repo);
});

// ==========================================
// 5. WALLET STATE NOTIFIER
// ==========================================
class WalletState {
  final double balance;
  final double cashback;
  final List<WalletTransaction> transactions;

  double get rewardsEarned => cashback + 12.50;

  const WalletState({
    required this.balance,
    required this.cashback,
    required this.transactions,
  });

  WalletState copyWith({
    double? balance,
    double? cashback,
    List<WalletTransaction>? transactions,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      cashback: cashback ?? this.cashback,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier()
      : super(WalletState(
          balance: 15.00,
          cashback: 4.50,
          transactions: [
            WalletTransaction(
              id: 'TXN-101',
              title: 'Cashback Credited',
              description: 'Cashback from Order #ORD-984218',
              amount: 2.50,
              type: TransactionType.credit,
              date: DateTime.now().subtract(const Duration(days: 3)),
              category: 'Cashback',
            ),
            WalletTransaction(
              id: 'TXN-102',
              title: 'Referral Bonus',
              description: 'Referred friend Amith S.',
              amount: 5.00,
              type: TransactionType.credit,
              date: DateTime.now().subtract(const Duration(days: 6)),
              category: 'Referral',
            ),
            WalletTransaction(
              id: 'TXN-103',
              title: 'Wallet Top-up',
              description: 'Added money via GPay',
              amount: 10.00,
              type: TransactionType.credit,
              date: DateTime.now().subtract(const Duration(days: 10)),
              category: 'Rewards',
            ),
            WalletTransaction(
              id: 'TXN-104',
              title: 'Order Paid',
              description: 'Paid for Order #ORD-661204',
              amount: 3.00,
              type: TransactionType.debit,
              date: DateTime.now().subtract(const Duration(days: 12)),
              category: 'Payment',
            ),
          ],
        ));

  void loadCash(double amount) {
    state = state.copyWith(
      balance: state.balance + amount,
      transactions: [
        WalletTransaction(
          id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Wallet Top-up',
          description: 'Added cash to wallet',
          amount: amount,
          type: TransactionType.credit,
          date: DateTime.now(),
          category: 'Top-up',
        ),
        ...state.transactions,
      ],
    );
  }

  void deductWallet(double amount) {
    if (state.balance >= amount) {
      state = state.copyWith(
        balance: state.balance - amount,
        transactions: [
          WalletTransaction(
            id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
            title: 'Payment Debited',
            description: 'Order Checkout partial payment',
            amount: amount,
            type: TransactionType.debit,
            date: DateTime.now(),
            category: 'Payment',
          ),
          ...state.transactions,
        ],
      );
    }
  }

  void addCashback(double amount) {
    state = state.copyWith(
      cashback: state.cashback + amount,
      transactions: [
        WalletTransaction(
          id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Cashback Received',
          description: 'Checkout Cashback Reward',
          amount: amount,
          type: TransactionType.credit,
          date: DateTime.now(),
          category: 'Cashback',
        ),
        ...state.transactions,
      ],
    );
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});

// ==========================================
// 6. COUPON PROVIDER (Seeded Static List)
// ==========================================
final couponsProvider = Provider<List<Coupon>>((ref) {
 return [
    Coupon(
      code: 'FLASHFAST',
      description: 'Get Flat \$3.00 off on order above \$10.00. Best value offer!',
      discountAmount: 3.0,
      minOrderValue: 10.0,
      isBestValue: true,
      expiryDate: '28 Jul 2026',
    ),
    Coupon(
      code: 'WELCOME50',
      description: 'Get 50% discount up to \$5.00 on your first FlashCart order.',
      discountAmount: 5.0,
      minOrderValue: 8.0,
      discountPercentage: 50.0,
      expiryDate: '15 Aug 2026',
    ),
    Coupon(
      code: 'SUPERMUNCH',
      description: 'Flat \$1.50 Off on Snacks and munchies above \$6.00.',
      discountAmount: 1.5,
      minOrderValue: 6.0,
      expiryDate: '30 Jul 2026',
    ),
    Coupon(
      code: 'EXP99',
      description: 'Flat \$4.00 off on your order.',
      discountAmount: 4.0,
      minOrderValue: 12.0,
      isExpired: true,
      expiryDate: '10 Jul 2026',
    ),
  ];
});

// ==========================================
// 7. NOTIFICATIONS STATE NOTIFIER
// ==========================================
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([]) {
    state = [
      NotificationModel(
        id: 'n1',
        title: '🥦 Farm Fresh Organic Alert!',
        description: 'New seasonal organic apples and mangoes are back in stock. Order now before they fly away!',
        category: NotificationCategory.offers,
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n2',
        title: '🛵 Order Delivered successfully!',
        description: 'Your order #ORD-984218 has been safely delivered to your doorstep. Rate your delivery partner now.',
        category: NotificationCategory.orders,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'n3',
        title: '💰 \$2.50 Cashback Credited!',
        description: 'FlashCart Super cashback has been successfully credited to your wallet. Use it for next instant munchies.',
        category: NotificationCategory.wallet,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'n4',
        title: '🎉 Referral Reward Waiting',
        description: 'Invite your friends to try FlashCart and get up to \$5.00 cash back instantly on their first checkout!',
        category: NotificationCategory.promotions,
        isRead: true,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void toggleRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: !n.isRead) : n).toList();
  }

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void restoreNotification(NotificationModel alert) {
    if (!state.any((n) => n.id == alert.id)) {
      state = [...state, alert];
    }
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

// ==========================================
// 8. SETTINGS STATE NOTIFIER
// ==========================================
class SettingsState {
  final bool isDarkMode;
  final String selectedLanguage;
  final bool enablePushNotifications;
  final bool enableLocationService;
  final bool biometricsEnabled;

  const SettingsState({
    required this.isDarkMode,
    required this.selectedLanguage,
    required this.enablePushNotifications,
    required this.enableLocationService,
    required this.biometricsEnabled,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? selectedLanguage,
    bool? enablePushNotifications,
    bool? enableLocationService,
    bool? biometricsEnabled,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableLocationService: enableLocationService ?? this.enableLocationService,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(
          isDarkMode: false,
          selectedLanguage: 'English',
          enablePushNotifications: true,
          enableLocationService: true,
          biometricsEnabled: false,
        ));

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void toggleNotifications(bool val) {
    state = state.copyWith(enablePushNotifications: val);
  }

  void toggleLocation(bool val) {
    state = state.copyWith(enableLocationService: val);
  }

  void toggleBiometrics(bool val) {
    state = state.copyWith(biometricsEnabled: val);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
