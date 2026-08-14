import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/ai/models/ai_models.dart';
import 'package:flashcart_ai/features/ai/providers/ai_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import '../../shopping/providers/shopping_providers.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

class AIPantryScannerScreen extends ConsumerStatefulWidget {
  const AIPantryScannerScreen({super.key});

  @override
  ConsumerState<AIPantryScannerScreen> createState() => _AIPantryScannerScreenState();
}

class _AIPantryScannerScreenState extends ConsumerState<AIPantryScannerScreen> {
  bool _isScanning = false;

  void _simulateScanner() async {
    setState(() {
      _isScanning = true;
    });

    // Simulated scan timing
    await Future.delayed(const Duration(seconds: 2200));

    if (!mounted) return;

    // Generate new scanned products
    final freshTomatoes = PantryItem(
      id: 'pantry_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Organic Vine Tomatoes',
      emoji: '🍅',
      category: 'Fresh Produce',
      expiryDate: DateTime.now().add(const Duration(days: 6)),
      quantity: 100.0,
      unit: '%',
    );

    ref.read(pantryScannerProvider.notifier).addNewScannedItems([freshTomatoes]);

    setState(() {
      _isScanning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Scan Complete! Detected: Organic Vine Tomatoes 🍅'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(pantryScannerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pantry Inventory Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Scanning Frame Camera Widget
                _isScanning
                    ? const ContainerPlaceholder(
                        child: AILoadingState(message: 'AI Vision analyzing fridge shelf...'),
                      )
                    : CameraUploadWidget(
                        title: 'Snap or Scan Shelf',
                        subtitle: 'Point at your fridge, fruit bowl, or spice pantry',
                        onSelected: _simulateScanner,
                      ),
                const SizedBox(height: 24),

                // 2. Inventory Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shelved Grocery Status',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pantryItems.length} Monitored',
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Pantry Items Grid / List
                pantryItems.isEmpty
                    ? const AIEmptyState(
                        title: 'No Shelved Items',
                        description: 'Scan your food shelf using the camera above to automatically build an expiry log.',
                        icon: Icons.inventory_2_outlined,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pantryItems.length,
                        itemBuilder: (context, idx) {
                          final item = pantryItems[idx];
                          return PantryItemCard(
                            item: item,
                            onQuantityChanged: (qty) {
                              ref.read(pantryScannerProvider.notifier).updateQuantity(item.id, qty);
                            },
                            onBuyMissing: () {
                              if (item.storeProduct != null) {
                                ref.read(cartProvider.notifier).addToCart(item.storeProduct!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${item.name} to Cart! 🛒'),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            onDelete: () {
                              ref.read(pantryScannerProvider.notifier).removePantryItem(item.id);
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContainerPlaceholder extends StatelessWidget {
  final Widget child;

  const ContainerPlaceholder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: child,
    );
  }
}
