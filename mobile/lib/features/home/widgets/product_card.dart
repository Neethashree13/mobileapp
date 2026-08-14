import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/home/widgets/badge_and_rating_widgets.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool compact;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.compact = false,
    this.width = 165.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch providers for live cart quantity and favorite status
  final cartState = ref.watch(cartProvider);

final quantity = cartState.items
    .where((item) => item.product.id == product.id)
    .fold(0, (sum, item) => sum + item.quantity);
    
    print("PRODUCT ID = ${product.id}");
// print("CART DATA = $cart");
print("QUANTITY = $quantity");


    final wishlist = ref.watch(wishlistProvider);
    final isFavorite = wishlist.contains(product.id);

    return GestureDetector(
      onTap: () {
        // Navigate to details screen, passing the product model via state.extra
        context.push('/product-details', extra: product);
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111317) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image container
                Expanded(
                  flex: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: product.fallbackColor.withOpacity(isDark ? 0.06 : 0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                 ClipRRect(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
  product.imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const Center(
      child: CircularProgressIndicator(),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    print("IMAGE ERROR");
    print(product.imageUrl);
    print(error);

    return Container(
      color: Colors.red,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image,
        color: Colors.white,
      ),
    );
  },
),
                          ),
                        ),
                        // Delivery Time overlay on the image bottom-left
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: DeliveryETAWidget(etaMins: product.deliveryTimeMins, compact: true),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Details text area
                Expanded(
                  flex: 11,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Weight and rating row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                product.weight,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            RatingWidget(rating: product.rating),
                          ],
                        ),
                        
                        // Product Name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Pricing and ADD button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Price
                            Expanded(
                              child: PriceWidget(
                                price: product.price,
                                originalPrice: product.originalPrice,
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            
                            // ADD or +/- button
                            _buildAddToCartButton(context, ref, quantity),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top overlay badges & actions
            Positioned(
              top: 0,
              left: 0,
              child: product.discountPercentage > 0
                  ? ProductBadge(text: '${product.discountPercentage}% OFF')
                  : (product.isBestSeller 
                      ? const ProductBadge(text: 'BEST SELLER', backgroundColor: Color(0xFFD97706))
                      : (product.isFlashDeal 
                          ? const ProductBadge(text: 'FLASH DEAL', backgroundColor: Color(0xFFEF4444))
                          : const SizedBox.shrink())),
            ),

            // Wishlist heart overlay
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: wishlist.isLoading
                    ? null
                    : () async {
                        final wasFavorite = isFavorite;
                        await ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                        if (!context.mounted) return;
                        final err = ref.read(wishlistProvider).errorMessage;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        if (err != null && err.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wasFavorite 
                                    ? 'Removed ${product.name} from favorites' 
                                    : 'Added ${product.name} to favorites!'
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: wasFavorite ? const Color(0xFF374151) : const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111317).withOpacity(0.8) : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? const Color(0xFFEF4444) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, WidgetRef ref, int quantity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);
    final isLoading = cartState.isLoading;

    if (isLoading) {
      return Container(
        height: 30,
        width: 65,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }

    if (quantity == 0) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        width: 65,
        child: ElevatedButton(
          onPressed: () async {
            await ref.read(cartProvider.notifier).addToCart(product);
            if (context.mounted) {
              final err = ref.read(cartProvider).errorMessage;
              if (err != null && err.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor.withOpacity(0.12),
            foregroundColor: theme.primaryColor,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.primaryColor, width: 1.2),
            ),
          ),
          child: const Text(
            'ADD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 30,
      width: 65,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Decrement
          GestureDetector(
            onTap: () async {
              await ref.read(cartProvider.notifier).updateQuantity(product.id, quantity - 1);
              if (context.mounted) {
                final err = ref.read(cartProvider).errorMessage;
                if (err != null && err.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const SizedBox(
              width: 22,
              height: 30,
              child: Icon(Icons.remove, color: Colors.white, size: 12),
            ),
          ),
          // Quantity
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Increment
          GestureDetector(
            onTap: () async {
              await ref.read(cartProvider.notifier).updateQuantity(product.id, quantity + 1);
              if (context.mounted) {
                final err = ref.read(cartProvider).errorMessage;
                if (err != null && err.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const SizedBox(
              width: 22,
              height: 30,
              child: Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
