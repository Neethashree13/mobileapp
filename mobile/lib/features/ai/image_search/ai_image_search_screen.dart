import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import '../../shopping/providers/shopping_providers.dart';

class AIImageSearchScreen extends ConsumerStatefulWidget {
  const AIImageSearchScreen({super.key});

  @override
  ConsumerState<AIImageSearchScreen> createState() => _AIImageSearchScreenState();
}

class _AIImageSearchScreenState extends ConsumerState<AIImageSearchScreen> {
  bool _isSearching = false;
  List<Map<String, dynamic>> _matches = [];

  void _simulateImageSearch() async {
    setState(() {
      _isSearching = true;
      _matches = [];
    });

    await Future.delayed(const Duration(seconds: 1800));

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      final allProducts = ref.read(productsProvider).value ?? [];
      if (allProducts.isNotEmpty) {
        _matches = [
          {
            'product': allProducts[0],
            'confidence': 98.4,
            'reason': '98% Visual match on shape & color'
          },
          if (allProducts.length > 1)
            {
              'product': allProducts[1],
              'confidence': 88.1,
              'reason': '88% Color and specular similarity match'
            },
        ];
      } else {
        _matches = [];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visual Search complete! Found 2 matching products.'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Visual Product Search', style: TextStyle(fontWeight: FontWeight.bold)),
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
                // Image Search Frame
                _isSearching
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                        ),
                        child: const AILoadingState(message: 'AI comparing visual vectors...'),
                      )
                    : CameraUploadWidget(
                        title: 'Upload Product Snap',
                        subtitle: 'Take a picture of a vegetable, cereal package or logo',
                        onSelected: _simulateImageSearch,
                      ),
                const SizedBox(height: 24),

                // Matches list
                const Text(
                  'Visual Similarity Matches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),

                _matches.isEmpty && !_isSearching
                    ? const AIEmptyState(
                        title: 'Snap a Product Pic',
                        description: 'Select an image or capture a snapshot above to perform visual-similarity queries on our catalog.',
                        icon: Icons.image_search_rounded,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _matches.length,
                        itemBuilder: (context, idx) {
                          final match = _matches[idx];
                          final Product prod = match['product'];
                          final double confidence = match['confidence'];
                          final String reason = match['reason'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: prod.fallbackColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(prod.emoji, style: const TextStyle(fontSize: 32)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            prod.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                          ),
                                          Text(
                                            '${confidence.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reason,
                                        style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${prod.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).addToCart(prod);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added ${prod.name} to Cart! 🛒'),
                                        backgroundColor: const Color(0xFF10B981),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.all(10),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Colors.white),
                                ),
                              ],
                            ),
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
