import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shopping_models.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/shopping_widgets.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  final TextEditingController _couponController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Coupon> _staticCoupons = [
    Coupon(
      id: 'c1',
      code: 'FLASHFAST50',
      discountPercentage: 50.0,
      description: 'Get 50% off on your first grocery basket. Maximum discount \$10.00.',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      minBasketValue: 15.0,
    ),
    Coupon(
      id: 'c2',
      code: 'VEGGIE20',
      discountPercentage: 20.0,
      description: '20% flat discount on organic green vegetables, leafy roots, and salads.',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      minBasketValue: 10.0,
    ),
    Coupon(
      id: 'c3',
      code: 'FREESHIP',
      discountPercentage: 100.0,
      description: 'Free instant 10-minute home delivery. Minimum basket size \$5.00.',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      minBasketValue: 5.0,
      isFreeDelivery: true,
    ),
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final isDark = ref.watch(settingsProvider).isDarkMode;

    // Filter coupons
    final List<Coupon> displayedCoupons = _staticCoupons.where((c) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Free Delivery') return c.isFreeDelivery;
      if (_selectedFilter == 'Big Discounts')return (c.discountPercentage ?? 0.0) >= 30.0;
      return true;
    }).toList();

    return Theme(
      data: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Apply Coupons', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Custom Code text-field input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'JetBrains Mono'),
                      decoration: const InputDecoration(
                        hintText: 'ENTER PROMO CODE manually...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: cartState.isLoading ? null : () => _handleManualCodeApply(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: cartState.isLoading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            // Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'Big Discounts', 'Free Delivery'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Coupon Ticket List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayedCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = displayedCoupons[index];
                  final isCurrentlyApplied = cartState.appliedCoupon?.code == coupon.code;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: CouponCard(
                      coupon: coupon,
                      isApplied: isCurrentlyApplied,
                      onApply: () async {
                        if (isCurrentlyApplied) {
                          await ref.read(cartProvider.notifier).removeCoupon();
                          if (!context.mounted) return;
                          final err = ref.read(cartProvider).errorMessage;
                          if (err != null && err.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coupon removed successfully')),
                            );
                          }
                        } else {
                          await ref.read(cartProvider.notifier).applyCoupon(coupon);
                          if (!context.mounted) return;
                          final err = ref.read(cartProvider).errorMessage;
                          if (err != null && err.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Promo code ${coupon.code} applied successfully!'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                            context.pop(); // Back to cart
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleManualCodeApply() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final matched = _staticCoupons.firstWhere(
      (c) => c.code == code,
      orElse: () => Coupon(
        id: 'c_manual',
        code: code,
        discountPercentage: 0.0,
        description: code,
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        minBasketValue: 0.0,
      ),
    );

    await ref.read(cartProvider.notifier).applyCoupon(matched);
    if (!mounted) return;

    final err = ref.read(cartProvider).errorMessage;
    if (err != null && err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
      );
    } else {
      _couponController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied promo code $code successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.pop();
    }
  }
}
