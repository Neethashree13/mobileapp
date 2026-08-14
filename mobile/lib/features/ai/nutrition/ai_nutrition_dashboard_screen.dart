import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';
import 'package:flashcart_ai/features/home/providers/home_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import 'package:flashcart_ai/features/ai/providers/ai_providers.dart';
import '../../shopping/providers/shopping_providers.dart';

class AINutritionDashboardScreen extends ConsumerWidget {
  const AINutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calPercentage = (state.caloriesConsumed / state.caloriesLimit).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Health & Nutrition', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.amber),
            tooltip: 'Reset Stats',
            onPressed: () {
              ref.read(nutritionDashboardProvider.notifier).resetNutrition();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nutrition intake counter reset.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Core Calorie Ring Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Circular indicator simulation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: calPercentage,
                              strokeWidth: 10,
                              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${state.caloriesConsumed}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                              const Text(
                                'KCAL',
                                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HEALTH SCORE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.healthyScore.toStringAsFixed(0)} / 100',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: state.healthyScore >= 80 ? const Color(0xFF10B981) : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.healthyScore >= 80
                                  ? 'Excellent! Your grocery cart is highly aligned with a fiber-rich clean diet.'
                                  : 'Try adding more organic leafy greens or low-fat proteins to increase score.',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600], height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Nutrition Grid of Macros
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  children: [
                    NutritionCard(
                      title: 'Protein',
                      current: state.proteinGrams,
                      limit: 90.0,
                      unit: 'g',
                      color: const Color(0xFF3B82F6),
                    ),
                    NutritionCard(
                      title: 'Carbohydrates',
                      current: state.carbsGrams,
                      limit: 250.0,
                      unit: 'g',
                      color: const Color(0xFFFBBF24),
                    ),
                    NutritionCard(
                      title: 'Healthy Fats',
                      current: state.fatGrams,
                      limit: 70.0,
                      unit: 'g',
                      color: const Color(0xFFEC4899),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Smart Diet Upgrade Recommendations
                const Text(
                  'Recommended Nutrition Boosters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'These clean-certified organic products improve your daily dietary profile.',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 230,
                  child: () {
                    final allProducts = ref.watch(productsProvider).value ?? [];
                    final productsList = allProducts.where((p) => p.categoryId == 'cat_fresh' || p.categoryId == 'cat_dairy' || p.categoryId == 'veg_fruits' || p.categoryId == 'dairy_bread').toList();
                    final finalProducts = productsList.isNotEmpty ? productsList : allProducts.take(4).toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: finalProducts.length,
                      itemBuilder: (context, idx) {
                        final prod = finalProducts[idx];

                      return RecommendationCard(
                        product: prod,
                        reason: prod.categoryId == 'cat_fresh' ? '🔥 High Fiber' : '💪 High Protein',
                        onAddToCart: () {
                          ref.read(nutritionDashboardProvider.notifier).logProductNutrition(prod);
                          ref.read(cartProvider.notifier).addToCart(prod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged nutrition & added ${prod.name} to Cart! 🥦'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  );
                }(),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
