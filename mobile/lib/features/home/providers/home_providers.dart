import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';
import '../data/datasources/product_remote_data_source.dart';
import '../data/repositories/product_repository.dart';
import '../../shopping/providers/shopping_providers.dart';

export '../../shopping/providers/shopping_providers.dart' show cartProvider, wishlistProvider;

// Remote Data Source Provider
final productRemoteDataSourceProvider = Provider<IProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource();
});

// Repository Provider
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepository(remoteDataSource: ref.watch(productRemoteDataSourceProvider));
});

// Products FutureProvider (Asynchronous Provider loading products from backend)
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  final products = await repository.getProducts();

  print("========== PRODUCTS FROM API ==========");
  print("TOTAL PRODUCTS: ${products.length}");

  for (var p in products.take(5)) {
    print(
      "${p.id} | ${p.name} | IMAGE: ${p.imageUrl}",
    );
  }

  return products;
});

// Selected Category Filter Provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// 1. Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Products Provider working with AsyncValue
final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    return products.where((product) {
      final matchesCategory = category == 'All' ||
          category.isEmpty ||
          product.categoryId.toLowerCase() == category.toLowerCase() ||
          product.brand.toLowerCase() == category.toLowerCase();
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.categoryId.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  });
});

// 2. Search History State Notifier
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([
    'organic milk',
    'fresh avocados',
    'pepperoni pizza',
    'sour bread',
    'kettle chips',
  ]);

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    final cleanQuery = query.trim().toLowerCase();
    
    // Remove if already exists to put it at the top
    final updated = List<String>.from(state)..remove(cleanQuery);
    state = [cleanQuery, ...updated].take(10).toList(); // Max 10 items
  }

  void clearHistory() {
    state = [];
  }

  void removeSearch(String query) {
    state = state.where((item) => item != query).toList();
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

// 3. Derived Cart Summary Providers (using unified shopping_providers.dart cartProvider)
final cartTotalItemsProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.totalItems;
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.subtotal;
});

final cartSavingsProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  double savings = 0.0;
  for (final item in cartState.items.where((i) => !i.isSavedForLater)) {
    if (item.product.originalPrice > item.product.price) {
      savings += (item.product.originalPrice - item.product.price) * item.quantity;
    }
  }
  return savings;
});