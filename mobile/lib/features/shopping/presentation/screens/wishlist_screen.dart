
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../home/models/home_models.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  bool _isGridView = true;
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistProvider);
    final wishlistNotifier = ref.read(wishlistProvider.notifier);
    final isDark = ref.watch(settingsProvider).isDarkMode;
    final isLoading = wishlistState.isLoading;

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            _isSelectionMode
                ? '${wishlistState.selectedIds.length} Selected'
                : 'My Wishlist',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          leading: _isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      wishlistNotifier.clearSelection();
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          actions: [
            if (!_isSelectionMode && wishlistState.items.isNotEmpty) ...[
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _showShareBottomSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.checklist_rounded),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = true;
                  });
                },
              ),
            ] else if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.select_all_rounded),
                onPressed: () {
                  for (final item in wishlistState.items) {
                    if (!wishlistState.selectedIds.contains(item.id)) {
                      wishlistNotifier.toggleSelection(item.id);
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                onPressed: wishlistState.isLoading
                    ? null
                    : () async {
                        await wishlistNotifier.removeSelected();
                        if (!mounted) return;
                        final err = ref.read(wishlistProvider).errorMessage;
                        if (err != null && err.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                          );
                        } else {
                          setState(() {
                            _isSelectionMode = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected items removed from wishlist'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
              ),
            ]
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(wishlistProvider.notifier).refresh(),
          color: const Color(0xFF10B981),
          child: wishlistState.isLoading && wishlistState.items.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
              : wishlistState.items.isEmpty
                  ? EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: '❤️ Your wishlist is empty',
                      description: 'Browse products and add your favourites.',
                      buttonText: 'Continue Shopping',
                      onAction: () => context.go('/home'),
                    )
                  : Column(
                      children: [
                        if (_isSelectionMode)
                          Container(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Select multiple items to move to basket or delete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: wishlistState.isLoading
                                      ? null
                                      : () async {
                                          final itemsToMove = wishlistState.items
                                              .where((item) => wishlistState.selectedIds.contains(item.id))
                                              .toList();
                                          
                                          if (itemsToMove.isNotEmpty) {
                                            final cart = ref.read(cartProvider.notifier);
                                            for (final item in itemsToMove) {
                                              await cart.addToCart(item.id);
                                            }
                                            await wishlistNotifier.removeSelected();
                                            if (!mounted) return;
                                            final err = ref.read(wishlistProvider).errorMessage;
                                            if (err != null && err.isNotEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                              );
                                            } else {
                                              setState(() {
                                                _isSelectionMode = false;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Moved ${itemsToMove.length} items to Basket!'),
                                                  backgroundColor: const Color(0xFF10B981),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  child: const Text(
                                    'MOVE TO CART',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        Expanded(
                          child: _isGridView
                              ? GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.63,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                                  itemCount: wishlistState.items.length,
                                  itemBuilder: (context, index) {
                                    final product = wishlistState.items[index];
                                    final isSelected = wishlistState.selectedIds.contains(product.id);
                                    return _buildWishlistItem(product, isSelected, wishlistNotifier, isDark, wishlistState.isLoading);
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: wishlistState.items.length,
                                  itemBuilder: (context, index) {
                                    final product = wishlistState.items[index];
                                    final isSelected = wishlistState.selectedIds.contains(product.id);
                                    return _buildWishlistRowItem(product, isSelected, wishlistNotifier, isDark,isLoading);
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildWishlistItem(Product product, bool isSelected, WishlistNotifier notifier, bool isDark, bool isLoading) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0)),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              if (_isSelectionMode) {
                notifier.toggleSelection(product.id);
              } else {
                context.push('/product-details', extra: product);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image Container
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: product.fallbackColor.withOpacity(0.12),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Text(
                              product.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        if (_isSelectionMode)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? const Color(0xFF10B981) : Colors.grey,
                              size: 24,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                // Text details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.brand,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                if (product.originalPrice > product.price)
                                  Text(
                                    '\$${product.originalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (!_isSelectionMode)
                              GestureDetector(
                               onTap: () async {
  await ref.read(cartProvider.notifier).addToCart(product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to basket!'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: const Color(0xFF10B981),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded, size: 18, color: Colors.black),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                      onPressed:isLoading
                          ? null
                          : () async {
                              await notifier.removeSingle(product.id);
                              if (!context.mounted) return;
                              final err = ref.read(wishlistProvider).errorMessage;
                              if (err != null && err.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} removed from wishlist'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildWishlistRowItem(Product product, bool isSelected, WishlistNotifier notifier, bool isDark, bool isLoading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            notifier.toggleSelection(product.id);
          } else {
            context.push('/product-details', extra: product);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (_isSelectionMode) ...[
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFF10B981) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: product.fallbackColor.withOpacity(0.12),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(product.emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.originalPrice > product.price)
                          Text(
                            '\$${product.originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                 onPressed: isLoading
                      ? null
                      : () async {
                          await notifier.removeSingle(product.id);
                          if (!context.mounted) return;
                          final err = ref.read(wishlistProvider).errorMessage;
                          if (err != null && err.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} removed from wishlist'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF10B981)),
                  onPressed: () async {
                    await ref.read(cartProvider.notifier).addToCart(product.id);
                    if (!context.mounted) return;
                    final err = ref.read(cartProvider).errorMessage;
                    if (err != null && err.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to basket!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Share Your Wishlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let friends and family see your fresh organic shopping bucket list.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareIcon(Icons.chat, 'WhatsApp', Colors.green),
                    _buildShareIcon(Icons.telegram, 'Telegram', Colors.blue),
                    _buildShareIcon(Icons.link_rounded, 'Copy Link', Colors.purple),
                    _buildShareIcon(Icons.mail_rounded, 'Email', Colors.orange),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wishlist URL successfully copied to clipboard!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
