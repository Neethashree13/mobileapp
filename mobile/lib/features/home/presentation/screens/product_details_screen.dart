import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';
import 'package:flashcart_ai/features/home/widgets/badge_and_rating_widgets.dart';
import 'package:flashcart_ai/features/home/widgets/product_card.dart';
import 'package:flashcart_ai/features/home/presentation/screens/home_dashboard_screen.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _activeGalleryIndex = 0;
  bool _isPlayingVideo = false;

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const CheckoutDrawerSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cart and wishlist live states
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.items.where((i) => i.product.id == widget.product.id).firstOrNull;
    final quantity = cartItem?.quantity ?? 0;
    
    final wishlistState = ref.watch(wishlistProvider);
    final isFavorite = wishlistState.contains(widget.product.id);

    final allProducts = ref.watch(productsProvider).value ?? [];

    // Filter similar products
    final similarProducts = allProducts
        .where((p) => p.categoryId == widget.product.categoryId && p.id != widget.product.id)
        .toList();

    // Frequently bought together (e.g. bread paired with milk, orange juice paired with apples)
    final frequentlyBought = allProducts
        .where((p) => p.id != widget.product.id)
        .take(2)
        .toList();

    // Mock Image Gallery Paths (Using same unsplash and alternative gradients)
    final List<String> galleryUrls = [
      widget.product.imageUrl,
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop&q=60', // Organic fresh food backdrop
    ];

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
        actions: [
          // Favorite heart toggle
          IconButton(
            icon: wishlistState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
                  )
                : Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black),
                  ),
            onPressed: wishlistState.isLoading
                ? null
                : () async {
                    final wasFavorite = isFavorite;
                    await ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id);
                    if (!context.mounted) return;
                    final err = ref.read(wishlistProvider).errorMessage;
                    if (err != null && err.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasFavorite
                                ? 'Removed ${widget.product.name} from favorites'
                                : 'Added ${widget.product.name} to favorites!',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: wasFavorite ? const Color(0xFF374151) : const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Swipeable & Zoomable Image/Video Gallery
                    SizedBox(
                      height: 280,
                      child: Stack(
                        children: [
                          _isPlayingVideo 
                              ? _buildMockVideoPlayer(isDark)
                              : PageView.builder(
                                  itemCount: galleryUrls.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _activeGalleryIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 1.0,
                                      maxScale: 3.0,
                                      child: Hero(
                                        tag: 'product_image_${widget.product.id}',
                                        child: Image.network(
                                          galleryUrls[index],
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: widget.product.fallbackColor.withOpacity(0.12),
                                              child: Center(
                                                child: Text(widget.product.emoji, style: const TextStyle(fontSize: 84)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),

                          // Gallery dots indicator
                          if (!_isPlayingVideo)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(galleryUrls.length, (index) {
                                  final isSelected = index == _activeGalleryIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                    height: 4,
                                    width: isSelected ? 14 : 4,
                                    decoration: BoxDecoration(
                                      color: isSelected ? theme.primaryColor : Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Play Video Trigger Badge
                          Positioned(
                            top: 12,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPlayingVideo = !_isPlayingVideo;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isPlayingVideo ? Icons.photo_library_rounded : Icons.play_circle_fill_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isPlayingVideo ? 'View Photos' : 'Watch Video',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Main Product Info Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.product.brand,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: theme.primaryColor,
                                ),
                              ),
                              DeliveryETAWidget(etaMins: widget.product.deliveryTimeMins),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                widget.product.weight,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              RatingWidget(rating: widget.product.rating, reviewCount: widget.product.reviewCount),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Pricing & Stock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PriceWidget(
                                price: widget.product.price,
                                originalPrice: widget.product.originalPrice,
                                fontSize: 24.0,
                                showSavings: true,
                              ),
                              
                              // Stock indicator badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.product.stock <= 10 
                                      ? const Color(0xFFEF4444).withOpacity(0.1) 
                                      : const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.product.stock <= 10 
                                      ? 'ONLY ${widget.product.stock} LEFT' 
                                      : 'IN STOCK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: widget.product.stock <= 10 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'About this Product',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Collapsible Ingredients & Nutrition Charts
                          _buildExpansionSection(
                            isDark,
                            title: '🥕 Ingredients details',
                            child: widget.product.ingredients.isEmpty 
                                ? const Text('Pure organic single-ingredient produce.')
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: widget.product.ingredients.map((ing) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF10B981)),
                                            const SizedBox(width: 8),
                                            Text(ing, style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          _buildExpansionSection(
                            isDark,
                            title: '📊 Nutrition Facts',
                            child: Table(
                              border: TableBorder.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 0.5),
                              children: widget.product.nutritionInfo.entries.map((entry) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(entry.value, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. Reviews Preview Card
                          _buildReviewsPreview(isDark, widget.product),
                          const SizedBox(height: 28),

                          // 5. Frequently Bought Together Horizontal list
                          if (frequentlyBought.isNotEmpty) ...[
                            Text(
                              '🛒 Frequently Bought Together',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: frequentlyBought.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ProductCard(product: frequentlyBought[index]),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // 6. Similar Products Horizontal grid list
                          if (similarProducts.isNotEmpty) ...[
                            Text(
                              '🥗 Similar Products',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: similarProducts.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ProductCard(product: similarProducts[index]),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Sticky Bottom Action Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111317) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Quantity +/- incremental controllers
                  Expanded(
                    flex: 10,
                    child: cartState.isLoading
                        ? Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                            ),
                          )
                        : quantity == 0
                            ? SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await ref.read(cartProvider.notifier).addToCart(widget.product.id);
                                    if (!context.mounted) return;
                                    final err = ref.read(cartProvider).errorMessage;
                                    if (err != null && err.isNotEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.primaryColor, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, color: theme.primaryColor, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ADD TO CART',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: theme.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await ref.read(cartProvider.notifier).updateQuantity(widget.product.id, quantity - 1);
                                        if (!context.mounted) return;
                                        final err = ref.read(cartProvider).errorMessage;
                                        if (err != null && err.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.remove, color: Colors.black, size: 20),
                                    ),
                                    Text(
                                      '$quantity x in Cart',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await ref.read(cartProvider.notifier).updateQuantity(widget.product.id, quantity + 1);
                                        if (!context.mounted) return;
                                        final err = ref.read(cartProvider).errorMessage;
                                        if (err != null && err.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.add, color: Colors.black, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  const SizedBox(width: 12),

                  // Direct "Buy Now" button
                  Expanded(
                    flex: 9,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: cartState.isLoading
                            ? null
                            : () async {
                                // Add to cart if not present, then open the Checkout Sheet
                                if (quantity == 0) {
                                  await ref.read(cartProvider.notifier).addToCart(widget.product.id);
                                }
                                if (!context.mounted) return;
                                final err = ref.read(cartProvider).errorMessage;
                                if (err != null && err.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                  );
                                } else {
                                  _showCheckoutSheet();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.bolt_rounded, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'BUY NOW',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockVideoPlayer(bool isDark) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Play indicator and mockup imagery
          Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                'Organic Farms Production Video',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Subtitles: English • 12 seconds',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection(bool isDark, {required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111317) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).primaryColor,
          textColor: isDark ? Colors.white : Colors.black,
          collapsedTextColor: isDark ? Colors.white70 : Colors.black87,
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsPreview(bool isDark, Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111317) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews Preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              RatingWidget(rating: product.rating, reviewCount: product.reviewCount),
            ],
          ),
          const SizedBox(height: 16),
          
          // Star progress bars mapping
          _buildReviewDistributionLine('5 ★', 0.85, isDark),
          _buildReviewDistributionLine('4 ★', 0.10, isDark),
          _buildReviewDistributionLine('3 ★', 0.03, isDark),
          _buildReviewDistributionLine('2 ★', 0.01, isDark),
          _buildReviewDistributionLine('1 ★', 0.01, isDark),
          const SizedBox(height: 18),

          // User review comment card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.amber,
                child: Text('👨', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Johnathan K.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('2 days ago', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 10),
                        Icon(Icons.star, color: Colors.amber, size: 10),
                        Icon(Icons.star, color: Colors.amber, size: 10),
                        Icon(Icons.star, color: Colors.amber, size: 10),
                        Icon(Icons.star, color: Colors.amber, size: 10),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Outstanding quality. Tasted exactly like fresh organic farm produce. Sub-10 min delivery is unreal!',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDistributionLine(String star, double percentage, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(star, style: const TextStyle(fontSize: 10, color: Colors.grey))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFBBF24)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
