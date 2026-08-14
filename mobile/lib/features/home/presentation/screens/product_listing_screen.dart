import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/home/widgets/product_card.dart';
import 'package:flashcart_ai/features/home/widgets/empty_state_and_error_widgets.dart';

class ProductListingScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final String? initialBrand;
  final String? initialCollectionId;

  const ProductListingScreen({
    super.key,
    this.initialCategoryId,
    this.initialBrand,
    this.initialCollectionId,
  });

  @override
  ConsumerState<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen> {
  String? _currentCategoryId;
  String? _currentBrand;
  String? _currentCollectionId;

  // Sorting Option: 'relevance', 'price_asc', 'price_desc', 'fastest', 'rating'
  String _sortBy = 'relevance';
  
  // Filters
  bool _inStockOnly = false;
  bool _discountedOnly = false;

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.initialCategoryId;
    _currentBrand = widget.initialBrand;
    _currentCollectionId = widget.initialCollectionId;
  }

  List<Product> _getProcessedProducts(List<Product> allProducts) {
    List<Product> list = List<Product>.from(allProducts);

    // 1. Category Filter
    if (_currentCategoryId != null) {
      list = list.where((p) => p.categoryId == _currentCategoryId).toList();
    }

    // 2. Brand Filter
    if (_currentBrand != null) {
      list = list.where((p) => p.brand.toLowerCase() == _currentBrand!.toLowerCase()).toList();
    }

    // 3. Collection Filter
    if (_currentCollectionId != null) {
      final collection = MockData.collections.firstWhere(
        (col) => col.id == _currentCollectionId,
        orElse: () => throw Exception('Collection $_currentCollectionId not found'),
      );
      list = list.where((p) => collection.productIds.contains(p.id)).toList();
    }

    // 4. Stock Filter
    if (_inStockOnly) {
      list = list.where((p) => p.stock > 0).toList();
    }

    // 5. Offers Filter
    if (_discountedOnly) {
      list = list.where((p) => p.discountPercentage > 0).toList();
    }

    // 6. Sorting Logic
    if (_sortBy == 'price_asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'fastest') {
      list.sort((a, b) => a.deliveryTimeMins.compareTo(b.deliveryTimeMins));
    } else if (_sortBy == 'rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111317)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, String>> sortOptions = [
          {'value': 'relevance', 'label': 'Popularity / Relevance'},
          {'value': 'price_asc', 'label': 'Price: Low to High'},
          {'value': 'price_desc', 'label': 'Price: High to Low'},
          {'value': 'fastest', 'label': 'Delivery Speed (Fastest first)'},
          {'value': 'rating', 'label': 'Customer Rating (High to Low)'},
        ];

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sort Products By',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = _sortBy == opt['value'];
                return ListTile(
                  title: Text(
                    opt['label']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  trailing: isSelected 
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor) 
                      : null,
                  onTap: () {
                    setState(() {
                      _sortBy = opt['value']!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111317)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filter Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // In Stock Only Switch
                  SwitchListTile(
                    title: const Text('In Stock Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Hide currently sold out items', style: TextStyle(fontSize: 11)),
                    activeColor: Theme.of(context).primaryColor,
                    value: _inStockOnly,
                    onChanged: (val) {
                      setSheetState(() {
                        _inStockOnly = val;
                      });
                      setState(() {
                        _inStockOnly = val;
                      });
                    },
                  ),
                  const Divider(),
                  
                  // Discounted Only Switch
                  SwitchListTile(
                    title: const Text('Deals & Offers Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Show items with active discounts', style: TextStyle(fontSize: 11)),
                    activeColor: Theme.of(context).primaryColor,
                    value: _discountedOnly,
                    onChanged: (val) {
                      setSheetState(() {
                        _discountedOnly = val;
                      });
                      setState(() {
                        _discountedOnly = val;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsAsync = ref.watch(productsProvider);

    // Work out current header title based on current filters
    String title = 'All Products';
    if (_currentCategoryId != null) {
      final category = MockData.categories.firstWhere((c) => c.id == _currentCategoryId);
      title = category.name;
    } else if (_currentBrand != null) {
      title = _currentBrand!;
    } else if (_currentCollectionId != null) {
      final col = MockData.collections.firstWhere((c) => c.id == _currentCollectionId);
      title = col.title;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Horizontal Category tabs for quick-swapping if we are browsing by category
            if (_currentCategoryId != null)
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MockData.categories.length,
                  itemBuilder: (context, index) {
                    final cat = MockData.categories[index];
                    final isSelected = _currentCategoryId == cat.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentCategoryId = cat.id;
                          _currentBrand = null;
                          _currentCollectionId = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.primaryColor.withOpacity(0.12) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.primaryColor : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: isSelected ? theme.primaryColor : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 2. Control bar containing Sort/Filter labels
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111317) : Colors.white,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${productsAsync.value != null ? _getProcessedProducts(productsAsync.value!).length : 0} products',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                  Row(
                    children: [
                      // Sort trigger
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sort_rounded, size: 14, color: isDark ? Colors.white : Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                'Sort',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter trigger
                      GestureDetector(
                        onTap: _showFilterSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (_inStockOnly || _discountedOnly) ? theme.primaryColor.withOpacity(0.12) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (_inStockOnly || _discountedOnly) ? theme.primaryColor : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt_rounded,
                                size: 14,
                                color: (_inStockOnly || _discountedOnly) ? theme.primaryColor : (isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: (_inStockOnly || _discountedOnly) ? theme.primaryColor : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Main Products Listing Grid
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load products: ${err.toString()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.refresh(productsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (allProducts) {
                  final products = _getProcessedProducts(allProducts);
                  if (products.isEmpty) {
                    return EmptyStateWidget(
                      title: 'No Matching Products',
                      message: 'We couldn\'t find any essentials matching your active filters. Try resetting them.',
                      emoji: '🥦',
                      actionText: 'Reset Filters',
                      onActionPressed: () {
                        setState(() {
                          _sortBy = 'relevance';
                          _inStockOnly = false;
                          _discountedOnly = false;
                        });
                      },
                    );
                  }
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.63,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
