import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import '../../shopping/providers/shopping_providers.dart';

class AISmartRecommendationsScreen extends ConsumerStatefulWidget {
  const AISmartRecommendationsScreen({super.key});

  @override
  ConsumerState<AISmartRecommendationsScreen> createState() => _AISmartRecommendationsScreenState();
}

class _AISmartRecommendationsScreenState extends ConsumerState<AISmartRecommendationsScreen> {
  String _selectedWeather = 'Rainy 🌧️';
  String _selectedTime = 'Evening Tea ☕';

  final List<String> _weatherOptions = ['Rainy 🌧️', 'Sunny ☀️', 'Chilly ❄️'];
  final List<String> _timeOptions = ['Morning Breakfast 🥚', 'Lunch Break 🥗', 'Evening Tea ☕', 'Late Night Munchies 🍕'];

  List<Product> _getFilteredRecommendations() {
    List<Product> items = [];
    final allProducts = ref.watch(productsProvider).value ?? [];

    if (_selectedWeather.contains('Rainy') || _selectedTime.contains('Tea')) {
      // Prioritize snacks and hot beverages
      items = allProducts.where((p) => p.categoryId == 'cat_snacks' || p.categoryId == 'cat_beverages').toList();
    } else if (_selectedWeather.contains('Chilly') || _selectedTime.contains('Breakfast')) {
      // Prioritize bakery, dairy and morning staples
      items = allProducts.where((p) => p.categoryId == 'cat_bakery' || p.categoryId == 'cat_dairy').toList();
    } else {
      // Sunny / Lunch / Default -> fresh organic vegetables and fruits
      items = allProducts.where((p) => p.categoryId == 'cat_fresh' || p.name.contains('Organic')).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendedProducts = _getFilteredRecommendations();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dynamic Recommendation Desk', style: TextStyle(fontWeight: FontWeight.bold)),
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
                // 1. Interactive Climate Control Simulator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'AI DYNAMIC CATALOG CONTEXTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Weather selector
                      const Text('Simulate Current Weather', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: _weatherOptions.map((w) {
                          final isSel = _selectedWeather == w;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedWeather = w;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF10B981).withOpacity(0.12)
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF10B981) : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  w,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSel ? const Color(0xFF10B981) : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Time Selector
                      const Text('Simulate Time of Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _timeOptions.length,
                          itemBuilder: (context, idx) {
                            final t = _timeOptions[idx];
                            final isSel = _selectedTime == t;
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(t),
                                selected: isSel,
                                selectedColor: const Color(0xFF10B981).withOpacity(0.25),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTime = t;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Weather Recommendation Output Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Suggested for $_selectedWeather',
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                    ),
                    const Icon(Icons.bolt, color: Color(0xFF10B981), size: 18),
                  ],
                ),
                const SizedBox(height: 12),

                // List of items
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: recommendedProducts.length,
                    itemBuilder: (context, idx) {
                      final prod = recommendedProducts[idx];
                      return RecommendationCard(
                        product: prod,
                        reason: _selectedWeather.contains('Rainy') ? '🌧️ Hot Treat' : '🔥 Healthy Choice',
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addToCart(prod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${prod.name} to Cart! 🛒'), behavior: SnackBarBehavior.floating),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Time of day Suggestion Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                          : [const Color(0xFFEEF2F6), const Color(0xFFE2E8F0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CO-PILOT TIP',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Matching your simulated context of $_selectedTime, we recommend trying a hot recipe or stocking up on fresh bakeries.',
                              style: TextStyle(fontSize: 12, height: 1.3, color: isDark ? Colors.grey[200] : Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
