import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcart_ai/features/ai/models/ai_models.dart';
import 'package:flashcart_ai/features/ai/providers/ai_providers.dart';
import 'package:flashcart_ai/features/ai/presentation/widgets/ai_reusable_widgets.dart';
import 'package:flashcart_ai/features/shopping/providers/shopping_providers.dart';

class AIRecipeGeneratorScreen extends ConsumerStatefulWidget {
  const AIRecipeGeneratorScreen({super.key});

  @override
  ConsumerState<AIRecipeGeneratorScreen> createState() => _AIRecipeGeneratorScreenState();
}

class _AIRecipeGeneratorScreenState extends ConsumerState<AIRecipeGeneratorScreen> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';

  final List<String> _cuisines = ['All', 'Mediterranean', 'Western', 'Continental'];

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredRecipes = recipes.where((r) {
      final matchesSearch = r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCuisine = _selectedCuisine == 'All' || r.cuisine == _selectedCuisine;
      return matchesSearch && matchesCuisine;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Recipe Builder', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filters
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipe or ingredient (e.g. Avocado, Salad)...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF10B981)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cuisines.length,
                      itemBuilder: (context, idx) {
                        final cuisine = _cuisines[idx];
                        final isSelected = _selectedCuisine == cuisine;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IngredientChip(
                            label: cuisine,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCuisine = cuisine;
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

            // Recipes List
            Expanded(
              child: filteredRecipes.isEmpty
                  ? const AIEmptyState(
                      title: 'No Matching Recipes',
                      description: 'Try adjusting your search criteria or looking for categories like Salad or Oats.',
                      icon: Icons.cookie_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, idx) {
                        final recipe = filteredRecipes[idx];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () => _showRecipeDetailsSheet(recipe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetailsSheet(RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Column(
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(recipe.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${recipe.cuisine} • ${recipe.difficulty}',
                                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            recipe.description,
                            style: TextStyle(fontSize: 13.5, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          ),
                          const SizedBox(height: 24),

                          // Nutrition linear values
                          const Text('AI Estimated Nutrition', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: recipe.nutrition.entries.map((entry) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Ingredients
                          const Text('Detailed Ingredients', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 12),
                          ...recipe.ingredients.map((ing) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 16),
                                    const SizedBox(width: 8),
                                    Text(ing, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 24),

                          // Directions
                          const Text('Preparation Steps', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 12),
                          ...recipe.steps.asMap().entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: const Color(0xFF10B981),
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 24),

                          // Quick Buy matching items
                          const Text('Matching Products in Store', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 12),
                          ...recipe.matchingProducts.map((prod) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Text(prod.emoji, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text('\$${prod.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addToCart(prod);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Added ${prod.name} to Cart!'), behavior: SnackBarBehavior.floating),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 20),

                          // Add All Button
                          ElevatedButton.icon(
                            onPressed: () {
                              for (final prod in recipe.matchingProducts) {
                                ref.read(cartProvider.notifier).addToCart(prod);
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added all ${recipe.matchingProducts.length} ingredients to Cart! 🥦🛒'),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
                            label: const Text('Add All Recipe Ingredients to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
