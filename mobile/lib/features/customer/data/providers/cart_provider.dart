import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final Map<String, CartItem> items;

  CartState({this.items = const {}});

  double get subtotal => items.values.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  
  double get totalEcoSavings => items.values.fold(0.0, (sum, item) {
    if (item.product.originalPrice != null) {
      return sum + ((item.product.originalPrice! - item.product.price) * item.quantity);
    }
    // Organic or highly healthy products get a small bonus AI eco-saving
    if (item.product.isOrganic) {
      return sum + (0.15 * item.quantity);
    }
    return sum;
  });

  double get deliveryFee => subtotal > 15.0 ? 0.0 : 1.99;
  
  double get tax => subtotal * 0.05; // 5% tax

  double get total => subtotal + deliveryFee + tax - totalEcoSavings;

  double get totalCarbonEmissionKg => items.values.fold(0.0, (sum, item) => sum + (item.product.carbonEmissionKg * item.quantity));

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product) {
    final currentItems = Map<String, CartItem>.from(state.items);
    if (currentItems.containsKey(product.id)) {
      currentItems[product.id] = currentItems[product.id]!.copyWith(
        quantity: currentItems[product.id]!.quantity + 1,
      );
    } else {
      currentItems[product.id] = CartItem(product: product, quantity: 1);
    }
    state = state.copyWith(items: currentItems);
  }

  void removeProduct(String productId) {
    final currentItems = Map<String, CartItem>.from(state.items);
    if (!currentItems.containsKey(productId)) return;

    if (currentItems[productId]!.quantity <= 1) {
      currentItems.remove(productId);
    } else {
      currentItems[productId] = currentItems[productId]!.copyWith(
        quantity: currentItems[productId]!.quantity - 1,
      );
    }
    state = state.copyWith(items: currentItems);
  }

  void deleteItem(String productId) {
    final currentItems = Map<String, CartItem>.from(state.items);
    currentItems.remove(productId);
    state = state.copyWith(items: currentItems);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
