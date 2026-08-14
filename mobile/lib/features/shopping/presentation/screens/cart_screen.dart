import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';
import '../../../home/models/home_models.dart';
import '../../../home/providers/home_providers.dart';

class ShoppingCartScreen extends ConsumerWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final isDark = ref.watch(settingsProvider).isDarkMode;

    final activeItems = cartState.items;
    final savedItems = cartState.savedForLater;

    // Group active items by store name
    final Map<String, List<CartItem>> itemsByStore = {};
    for (final item in activeItems) {
      itemsByStore.putIfAbsent(item.storeName, () => []).add(item);
    }

    void showErrorIfNeeded() {
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

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('My Basket', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (activeItems.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await cartNotifier.clearCart();
                  if (context.mounted) showErrorIfNeeded();
                },
                child: const Text('CLEAR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        body: cartState.isLoading && activeItems.isEmpty && savedItems.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
            : activeItems.isEmpty && savedItems.isEmpty
                ? RefreshIndicator(
                    onRefresh: () => ref.read(cartProvider.notifier).refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: EmptyState(
                          icon: Icons.shopping_basket_outlined,
                          title: '🛒 Your basket is empty',
                          description: 'Add some groceries to continue.',
                          buttonText: 'Shop Now',
                          onAction: () => context.go('/home'),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.read(cartProvider.notifier).refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (cartState.isLoading)
                            const LinearProgressIndicator(
                              color: Color(0xFF10B981),
                              backgroundColor: Colors.transparent,
                            ),

                          // A. Carbon savings indicator (AI Premium Banner)
                          _buildAISavingsBanner(cartState.subtotal, isDark),

                          // B. Grouped items by Store
                          if (activeItems.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'ITEMS FROM YOUR NEARBY STORES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            ...itemsByStore.entries.map((entry) => _buildStoreCard(context, ref, entry.key, entry.value, cartNotifier, isDark, showErrorIfNeeded)),
                          ],

                          // C. Save For Later Tray
                          if (savedItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildSavedForLaterTray(context, ref, savedItems, cartNotifier, isDark, showErrorIfNeeded),
                          ],

                          // D. Tipping Rajesh Kumar (Delivery Partner)
                          const SizedBox(height: 16),
                          _buildTippingCard(context, cartState, cartNotifier, isDark),

                          // E. Recommended items
                          const SizedBox(height: 16),
                          _buildRecommendedProducts(context, ref, activeItems, cartNotifier, isDark, showErrorIfNeeded),

                          // F. Promo coupon section
                          const SizedBox(height: 16),
                          _buildCouponSection(context, cartState, cartNotifier, isDark),

                          // G. Wallet Balance Deduct slider
                          const SizedBox(height: 16),
                          _buildWalletUsageCard(context, cartState, cartNotifier, isDark),

                          // H. Bill Summary
                          if (activeItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildBillSummaryCard(context, cartState, isDark),
                          ],
                        ],
                      ),
                    ),
                  ),
        // I. Float action checkout bar
        bottomSheet: activeItems.isEmpty
            ? null
            : _buildBottomCheckoutBar(context, cartState, isDark),
      ),
    );
  }

  Widget _buildAISavingsBanner(double subtotal, bool isDark) {
    if (subtotal == 0.0) return const SizedBox.shrink();
    final co2 = subtotal * 0.42;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF042C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF10B981),
            radius: 18,
            child: Icon(Icons.bolt_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Superfast 10-Min Delivery Enabled',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Eco-friendly EV routing prevents ${co2.toStringAsFixed(1)}kg of CO2!',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    WidgetRef ref,
    String storeName,
    List<CartItem> items,
    CartNotifier notifier,
    bool isDark,
    VoidCallback showErrorIfNeeded,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Store Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '10 MINS',
                    style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),
          // List of items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, idx) => const Divider(height: 1, color: Color(0xFF334155)),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key('cart-${item.product.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await notifier.removeItem(item.product.id);
                  if (context.mounted) showErrorIfNeeded();
                },
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: item.product.fallbackColor.withOpacity(0.12),
                          child: Image.network(
                            item.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(item.product.emoji, style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.product.weight,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                if (item.product.originalPrice > item.product.price)
                                  Text(
                                    '\$${item.product.originalPrice.toStringAsFixed(2)}',
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
                      // Controls column
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                                onPressed: () async {
                                  await notifier.updateQuantity(item.product.id, item.quantity - 1);
                                  if (context.mounted) showErrorIfNeeded();
                                },
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 22),
                                onPressed: () async {
                                  await notifier.updateQuantity(item.product.id, item.quantity + 1);
                                  if (context.mounted) showErrorIfNeeded();
                                },
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              await notifier.toggleSaveForLater(item.product.id, false);
                              if (context.mounted) showErrorIfNeeded();
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            ),
                            child: const Text('Save For Later', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedForLaterTray(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> items,
    CartNotifier notifier,
    bool isDark,
    VoidCallback showErrorIfNeeded,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_added_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Saved For Later (${items.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: item.product.fallbackColor.withOpacity(0.12),
                          child: Image.network(
                            item.product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${item.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Color(0xFF10B981), size: 20),
                        onPressed: () async {
                          await notifier.toggleSaveForLater(item.product.id, true);
                          if (context.mounted) showErrorIfNeeded();
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTippingCard(
    BuildContext context,
    CartState state,
    CartNotifier notifier,
    bool isDark,
  ) {
    final tips = [1.0, 2.0, 5.0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 16,
                child: Text('🛵', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip Rajesh Kumar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '100% of the tip goes directly to your delivery hero',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (state.deliveryTip > 0)
                Text(
                  '\$${state.deliveryTip.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14),
                )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...tips.map((amount) {
                final isSelected = state.deliveryTip == amount;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('+\$${amount.toStringAsFixed(0)}'),
                      selected: isSelected,
                      selectedColor: Colors.amber,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                      ),
                      onSelected: (val) {
                        notifier.selectTip(val ? amount : 0.0);
                      },
                    ),
                  ),
                );
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: const Text('Custom'),
                    selected: state.deliveryTip > 0 && !tips.contains(state.deliveryTip),
                    onSelected: (val) {
                      if (val) {
                        notifier.selectTip(3.50); // Mocks a custom \$3.50 tip
                      } else {
                        notifier.selectTip(0.0);
                      }
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> activeItems,
    CartNotifier notifier,
    bool isDark,
    VoidCallback showErrorIfNeeded,
  ) {
    final activeIds = activeItems.map((item) => item.product.id).toSet();
    final allProducts = ref.watch(productsProvider).value ?? [];
    final recs = allProducts.where((p) => !activeIds.contains(p.id)).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'YOU MAY ALSO NEED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recs.length,
            itemBuilder: (context, index) {
              final product = recs[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 70,
                        color: product.fallbackColor.withOpacity(0.12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(product.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.weight,
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await notifier.addToCart(product);
                            if (context.mounted) {
                              showErrorIfNeeded();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, size: 14, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildCouponSection(
    BuildContext context,
    CartState state,
    CartNotifier notifier,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_num_rounded, color: Color(0xFF10B981), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.appliedCoupon != null
                      ? 'Coupon Applied: ${state.appliedCoupon!.code}'
                      : 'Avail Store Vouchers',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  state.appliedCoupon != null
                      ? 'Saved \$${state.discount.toStringAsFixed(2)} with this promo'
                      : 'Select from available dynamic coupons to save big',
                  style: TextStyle(fontSize: 11, color: state.appliedCoupon != null ? const Color(0xFF10B981) : Colors.grey),
                ),
              ],
            ),
          ),
          if (state.appliedCoupon != null)
            TextButton(
              onPressed: () => notifier.removeCoupon(),
              child: const Text('REMOVE', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: () {
                context.push('/coupons');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SEE ALL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            )
        ],
      ),
    );
  }

  Widget _buildWalletUsageCard(
    BuildContext context,
    CartState state,
    CartNotifier notifier,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF1E3A8A),
            radius: 18,
            child: Icon(Icons.account_balance_wallet_rounded, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use FlashCart Wallet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Available balance: \$15.00',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: state.useWallet,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) {
              notifier.toggleWallet(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(BuildContext context, CartState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Item Subtotal', '\$${state.subtotal.toStringAsFixed(2)}', isDark),
          _buildBillRow(
            'Delivery Fee',
            state.deliveryFee == 0.0 ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}',
            isDark,
            valueColor: state.deliveryFee == 0.0 ? const Color(0xFF10B981) : null,
          ),
          _buildBillRow('Platform Fee', '\$${state.platformFee.toStringAsFixed(2)}', isDark),
          _buildBillRow('Taxes & Surcharges (8%)', '\$${state.taxes.toStringAsFixed(2)}', isDark),
          if (state.deliveryTip > 0)
            _buildBillRow('Driver Tipping', '\$${state.deliveryTip.toStringAsFixed(2)}', isDark),
          if (state.appliedCoupon != null)
            _buildBillRow('Coupon Discount', '-\$${state.discount.toStringAsFixed(2)}', isDark, valueColor: const Color(0xFF10B981)),
          if (state.useWallet)
            _buildBillRow('Wallet Offset', '-\$${state.walletDeduction.toStringAsFixed(2)}', isDark, valueColor: Colors.blueAccent),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Color(0xFF334155)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${state.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String val, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          Text(
            val,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context, CartState state, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${state.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF10B981)),
                ),
                Text(
                  '${state.items.where((i) => !i.isSavedForLater).fold(0, (sum, i) => sum + i.quantity)} Items • Total Bill',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef CartScreen = ShoppingCartScreen;

