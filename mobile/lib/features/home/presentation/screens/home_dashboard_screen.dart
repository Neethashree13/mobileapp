import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/home/widgets/banner_carousel.dart';
import 'package:flashcart_ai/features/home/widgets/category_card.dart';
import 'package:flashcart_ai/features/home/widgets/product_card.dart';
import 'package:flashcart_ai/features/home/widgets/offer_card.dart';
import 'package:flashcart_ai/features/home/widgets/search_widgets.dart';
import 'package:flashcart_ai/features/home/widgets/badge_and_rating_widgets.dart';
import 'package:flashcart_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flashcart_ai/features/profile/presentation/providers/user_profile_providers.dart';
import '../../../shopping/providers/shopping_providers.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _cartSlideController;
  late Animation<Offset> _cartSlideAnimation;

  // Local storage for mock "Recently Viewed" which gets populated as user taps on items
  final List<String> _recentlyViewedIds = ['milk-001', 'apple-001', 'chips-001']; // initial mock values

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartProvider.notifier).loadCart();
    });

    _cartSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cartSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cartSlideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _cartSlideController.dispose();
    super.dispose();
  }

  void _showCheckoutSheet(BuildContext context) {
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

    // Cart items state
    final cartTotalItems = ref.watch(cartTotalItemsProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);

    // Real App States
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(userProfileProvider);
    final addressesState = ref.watch(userAddressesProvider);
    final wishlist = ref.watch(wishlistProvider);
    final orders = ref.watch(ordersProvider);

    // Dynamic user name resolution
    String resolveUserName() {
      final pFirst = profileState.profile?.firstName?.trim() ?? '';
      final pLast = profileState.profile?.lastName?.trim() ?? '';
      final uFirst = authState.user?.firstName?.trim() ?? '';
      final uLast = authState.user?.lastName?.trim() ?? '';
      final uEmail = (authState.user?.email.isNotEmpty == true)
          ? authState.user!.email
          : (profileState.profile?.email ?? '');

      bool isTechnicalId(String str) {
        if (str.isEmpty) return true;
        final lower = str.toLowerCase();
        return lower.startsWith('u_') ||
            lower.startsWith('usr_') ||
            lower.startsWith('user_') ||
            lower == 'flashcart' ||
            lower == 'user' ||
            RegExp(r'^[a-f0-9\-]{8,}$').hasMatch(lower);
      }

      if (pFirst.isNotEmpty && !isTechnicalId(pFirst)) {
        return (pLast.isNotEmpty && !isTechnicalId(pLast)) ? '$pFirst $pLast' : pFirst;
      }
      if (uFirst.isNotEmpty && !isTechnicalId(uFirst)) {
        return (uLast.isNotEmpty && !isTechnicalId(uLast)) ? '$uFirst $uLast' : uFirst;
      }

      if (uEmail.isNotEmpty && uEmail.contains('@')) {
        final emailPrefix = uEmail.split('@').first;
        if (!isTechnicalId(emailPrefix)) {
          final cleaned = emailPrefix.replaceAll(RegExp(r'\d+$'), '');
          if (cleaned.isNotEmpty) {
            return cleaned[0].toUpperCase() + cleaned.substring(1);
          }
          return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
        }
      }

      return 'Neetha'; // Clean fallback name for testing
    }

    final String userName = resolveUserName();
    final profile = profileState.profile;

    // Dynamic address
    String currentAddressStr = 'Set Delivery Location';
    if (addressesState.addresses.isNotEmpty) {
      dynamic defaultAddr;
      for (final a in addressesState.addresses) {
        if (a.isDefault) {
          defaultAddr = a;
          break;
        }
      }
      defaultAddr ??= addressesState.addresses.first;

      final parts = <String>[];
      final houseNo = defaultAddr.houseNo;
      final line1 = defaultAddr.addressLine1;
      final street = defaultAddr.street;
      final city = defaultAddr.city;
      final title = defaultAddr.title;

      if (houseNo != null && houseNo.toString().isNotEmpty) parts.add(houseNo.toString());
      if (line1 != null && line1.toString().isNotEmpty) parts.add(line1.toString());
      else if (street != null && street.toString().isNotEmpty) parts.add(street.toString());
      if (city != null && city.toString().isNotEmpty) parts.add(city.toString());

      if (parts.isNotEmpty) {
        currentAddressStr = parts.join(', ');
      } else if (title != null && title.toString().isNotEmpty) {
        currentAddressStr = title.toString();
      }
    }

    // Photo / Avatar
    final photoUrl = profile?.profilePhoto ?? profile?.profileImage;

    // Slide bottom cart panel in/out based on items
    if (cartTotalItems > 0) {
      _cartSlideController.forward();
    } else {
      _cartSlideController.reverse();
    }

    // Dynamic Greeting based on time
    final hour = DateTime.now().hour;
    String greeting = 'Hey there';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // Async products provider from backend
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: true,
                  onTap: () {},
                  isDark: isDark,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Categories',
                  isActive: false,
                  onTap: () => context.push('/categories'),
                  isDark: isDark,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Wishlist',
                  badgeCount: wishlist.length,
                  isActive: false,
                  onTap: () => context.push('/wishlist'),
                  isDark: isDark,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Cart',
                  badgeCount: cartTotalItems,
                  isActive: false,
                  onTap: () => context.push('/cart-screen'),
                  isDark: isDark,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  badgeCount: orders.length,
                  isActive: false,
                  onTap: () => context.push('/orders'),
                  isDark: isDark,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: false,
                  onTap: () {
                    if (authState.isAuthenticated || profile != null) {
                      context.push('/profile');
                    } else {
                      context.push('/login-options');
                    }
                  },
                  isDark: isDark,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable contents
            RefreshIndicator(
              onRefresh: () async {
                await ref.read(userProfileProvider.notifier).loadProfile();
                await ref.read(userAddressesProvider.notifier).loadAddresses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dashboard updated with fresh data!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              color: theme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0), // Padding to clear floating bottom cart
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Premium Custom Header: Address, ETA & Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.push('/address-management');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: theme.primaryColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Delivering in 9 Mins',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF10B981),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    currentAddressStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Quick Profile Avatar
                          GestureDetector(
                            onTap: () {
                              if (authState.isAuthenticated || profile != null) {
                                context.push('/profile');
                              } else {
                                context.push('/login-options');
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.primaryColor, width: 1.5),
                              ),
                              child: (photoUrl != null && photoUrl.startsWith('http'))
                                  ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            userName.isNotEmpty ? userName[0].toUpperCase() : '👤',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        userName.isNotEmpty ? userName[0].toUpperCase() : '👤',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. Greeting Row
                      Text(
                        '$greeting, $userName!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'What shall we deliver to you in 10 minutes?',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3. Search Bar and AI Button
                      Row(
                        children: [
                          Expanded(
                            child: HomeSearchBar(
                              readOnly: true,
                              onTap: () {
                                context.push('/search');
                              },
                              onVoiceTap: () {
                                context.push('/search');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          AISearchButton(
                            onPressed: () {
                              // Deep-link directly to Search with AI focus
                              context.push('/search', extra: true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. Banners Carousel
                      BannerCarousel(banners: MockData.banners),
                      const SizedBox(height: 18),

                      // AI Dashboard Portal Banner
                      GestureDetector(
                        onTap: () {
                          context.push('/ai-hub');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.psychology_rounded, color: Color(0xFF10B981), size: 24),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'FlashCart AI Experience',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '10-MIN CO-PILOT',
                                          style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Chat, Scan Pantry, Speech Shopping & Smart Recipes',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Browse Categories Section Header
                      _buildSectionHeader(
                        context,
                        title: 'Browse Categories',
                        onViewAll: () {
                          context.push('/categories');
                        },
                      ),
                      const SizedBox(height: 14),

                      // Categories Grid (2 Rows of 4 items)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: MockData.categories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(category: MockData.categories[index], compact: true);
                        },
                      ),
                      const SizedBox(height: 28),

                      // Async product sections with Loading, Error, Data states
                      productsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Unable to load catalog from server',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  err.toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => ref.refresh(productsProvider),
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (productsList) {
                          final flashDeals = productsList.where((p) => p.isFlashDeal).toList();
                          final effectiveFlashDeals = flashDeals.isNotEmpty ? flashDeals : productsList.take(4).toList();

                          final bestSellers = productsList.where((p) => p.isBestSeller).toList();
                          final effectiveBestSellers = bestSellers.isNotEmpty ? bestSellers : productsList.skip(1).take(4).toList();

                          final buyAgain = productsList.take(3).toList();
                          final combos = productsList.where((p) => p.isCombo).toList();
                          final effectiveCombos = combos.isNotEmpty ? combos : productsList.take(3).toList();
                          final trending = productsList.where((p) => p.isTrending).toList();
                          final effectiveTrending = trending.isNotEmpty ? trending : productsList.skip(2).take(4).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 6. Flash Deals Section
                              _buildProductHorizontalSection(
                                context,
                                title: '🔥 Flash Deals',
                                subtitle: 'Ending soon! Heavy price cuts',
                                products: effectiveFlashDeals,
                              ),

                              // 7. Seasonal Offers Header & Cards
                              _buildSectionHeader(
                                context,
                                title: '🌿 Premium Seasonal Savings',
                                hideViewAll: true,
                              ),
                              const SizedBox(height: 10),
                              ...MockData.offers.map((offer) => OfferCard(offer: offer)).toList(),
                              const SizedBox(height: 28),

                              // 8. Best Sellers
                              _buildProductHorizontalSection(
                                context,
                                title: '👑 Best Sellers',
                                subtitle: 'Most ordered essentials this week',
                                products: effectiveBestSellers,
                              ),

                              // 9. Frequently Bought Section
                              _buildProductHorizontalSection(
                                context,
                                title: '🔄 Buy Again',
                                subtitle: 'Based on your purchase history',
                                products: buyAgain,
                              ),

                              // 10. Brand Showcase (Curated premium brand circles)
                              _buildSectionHeader(
                                context,
                                title: '🏛️ Brand Showcase',
                                hideViewAll: true,
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: MockData.brands.length,
                                  itemBuilder: (context, index) {
                                    final brand = MockData.brands[index];
                                    return GestureDetector(
                                      onTap: () {
                                        context.push('/products?brand=${brand.name}');
                                      },
                                      child: Container(
                                        width: 150,
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF111317) : brand.color.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF1F2937) : brand.color,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(brand.logoEmoji, style: const TextStyle(fontSize: 20)),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    brand.name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: isDark ? Colors.white : Colors.black,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              brand.description,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),

                              // 11. Combo Packs
                              _buildProductHorizontalSection(
                                context,
                                title: '🎁 Value Combo Packs',
                                subtitle: 'Curated sets, guaranteed to save 20%+',
                                products: effectiveCombos,
                              ),

                              // 12. Featured Collections
                              _buildSectionHeader(
                                context,
                                title: '✨ Featured Collections',
                                hideViewAll: true,
                              ),
                              const SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.9,
                                ),
                                itemCount: MockData.collections.length,
                                itemBuilder: (context, index) {
                                  final collection = MockData.collections[index];
                                  return GestureDetector(
                                    onTap: () {
                                      context.push('/products?collectionId=${collection.id}');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF111317) : collection.color,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1F2937) : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  collection.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 13,
                                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  collection.subtitle,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            collection.emoji,
                                            style: const TextStyle(fontSize: 28),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 28),

                              // 13. Recommended & Trending
                              _buildProductHorizontalSection(
                                context,
                                title: '🌟 Recommended for You',
                                subtitle: 'Personalized based on morning browsing',
                                products: effectiveTrending,
                              ),
                            ],
                          );
                        },
                      ),

                      // 14. Recently Viewed & Continue Shopping
                      _recentlyViewedSection(context, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Persistent Sliding Add-To-Cart Summary HUD
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: SlideTransition(
                position: _cartSlideAnimation,
                child: _buildFloatingCartSummaryHUD(context, isDark, cartTotalItems, cartSubtotal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, String? subtitle, VoidCallback? onViewAll, bool hideViewAll = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (!hideViewAll && onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: theme.primaryColor),
                  ],
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductHorizontalSection(BuildContext context, {required String title, required String subtitle, required List<Product> products}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          title: title,
          subtitle: subtitle,
          onViewAll: () {
            context.push('/products');
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
                child: ProductCard(product: products[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _recentlyViewedSection(BuildContext context, bool isDark) {
    final allProducts = ref.watch(productsProvider).value ?? [];
    // Look up product objects
    final products = allProducts.where((p) => _recentlyViewedIds.contains(p.id)).toList();
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          title: '🕒 Recently Viewed',
          subtitle: 'Pick up where you left off',
          hideViewAll: true,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
                child: ProductCard(product: products[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFloatingCartSummaryHUD(BuildContext context, bool isDark, int count, double subtotal) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Charcoal dark slate color for high-end professional appearance
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left portion: item details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count ${count == 1 ? "item" : "items"} added',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 13),
                      const Text(
                        '10 MINS',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Right portion: action button to open checkout sheet
          GestureDetector(
            onTap: () => _showCheckoutSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black,
                    size: 11,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
    int badgeCount = 0,
  }) {
    final activeColor = theme.primaryColor;
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Beautiful slide-up full receipt checkout drawer bottom sheet
class CheckoutDrawerSheet extends ConsumerStatefulWidget {
  const CheckoutDrawerSheet({super.key});

  @override
  ConsumerState<CheckoutDrawerSheet> createState() => _CheckoutDrawerSheetState();
}

class _CheckoutDrawerSheetState extends ConsumerState<CheckoutDrawerSheet> with SingleTickerProviderStateMixin {
  bool _isOrdering = false;
  bool _orderCompleted = false;

  void _processOrder() async {
    setState(() {
      _isOrdering = true;
    });

    // Simulate payment parsing
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        _isOrdering = false;
        _orderCompleted = true;
      });

      // Clear the cart on successful completion
      ref.read(cartProvider.notifier).clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cart details
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final savings = ref.watch(cartSavingsProvider);
    final deliveryFee = subtotal >= 15.0 ? 0.00 : 1.99;
    final total = subtotal + deliveryFee;

    if (_orderCompleted) {
      return Container(
        height: 480,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1115) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                '🎉',
                style: TextStyle(fontSize: 72),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rider has picked up your fresh organic produce and is racing towards you! Estimated delivery: 8 Minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close modal
              },
              child: const Text('Track Order Status'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07080A) : const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Cart Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable Receipt Items
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                final product = cartItem.product;
                final qty = cartItem.quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      // Item emoji card fallback
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: product.fallbackColor.withOpacity(isDark ? 0.1 : 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(product.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Title / Weight
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.weight,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Incrementer
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            onPressed: () {
                              ref.read(cartProvider.notifier).updateQuantity(product.id, qty - 1);
                            },
                          ),
                          Text(
                            '$qty',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 14),
                            onPressed: () {
                              ref.read(cartProvider.notifier).updateQuantity(product.id, qty + 1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Cost
                      Text(
                        '\$${(product.price * qty).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Bill Details Receipt Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111317) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Item Subtotal', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Partner Fee', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(
                      deliveryFee == 0.00 ? 'FREE' : '\$${deliveryFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: deliveryFee == 0.00 ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
                if (savings > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount Savings', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        '-\$${savings.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Slider/Button
          _isOrdering
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  ),
                )
              : ElevatedButton(
                  onPressed: _processOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Slide to Pay & Order',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
