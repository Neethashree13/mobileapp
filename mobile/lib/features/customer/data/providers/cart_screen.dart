import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/cart_provider.dart';
import 'order_tracking_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      appBar: AppBar(
        title: const Text('My Basket', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F1115),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Your basket is empty',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add premium organic produce to start shopping!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Go back shopping', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // List of Cart Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF1F2937), height: 24),
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: const Color(0xFF1F2937),
                                child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.product.unit,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.product.price.toStringAsFixed(2)} each',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          
                          // Control quantities
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).removeProduct(item.product.id);
                                },
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).addProduct(item.product);
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Receipt summary block
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F1115),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(top: BorderSide(color: Color(0xFF1F2937))),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick AI Carbon savings banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF022C22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF047857)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'AI Carbon Savings: ${cart.totalCarbonEmissionKg.toStringAsFixed(2)}kg CO2 prevented!',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Pricing Lines
                        _PriceLine(label: 'Items Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _PriceLine(
                          label: 'AI Eco-savings Discount',
                          value: '-\$${cart.totalEcoSavings.toStringAsFixed(2)}',
                          isDiscount: true,
                        ),
                        const SizedBox(height: 6),
                        _PriceLine(
                          label: 'Rapid Logistics Delivery',
                          value: cart.deliveryFee == 0.0 ? 'FREE' : '\$${cart.deliveryFee.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 6),
                        _PriceLine(label: 'Taxes & Surcharge (5%)', value: '\$${cart.tax.toStringAsFixed(2)}'),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFF374151)),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              '\$${cart.total < 0 ? "0.00" : cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Place Order Button
                        ElevatedButton(
                          onPressed: () => _placeOrder(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Checkout & Deliver in 10 Mins',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _placeOrder(BuildContext context, WidgetRef ref) {
    // 1. Snapshot the order details
    final totalValue = ref.read(cartProvider).total;
    
    // 2. Empty the basket state
    ref.read(cartProvider.notifier).clearCart();
    
    // 3. Slide immediately into the tracking page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderTotal: totalValue),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceLine({required this.label, required this.value, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? const Color(0xFF10B981) : Colors.white,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
