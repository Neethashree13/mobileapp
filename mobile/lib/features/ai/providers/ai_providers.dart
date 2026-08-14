import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/home_models.dart';
import '../../home/providers/home_providers.dart';
import '../models/ai_models.dart';
import '../../shopping/providers/shopping_providers.dart';

// ==========================================
// 1. AI CHAT STATE NOTIFIER
// ==========================================
class AIChatNotifier extends StateNotifier<List<AIChatMessage>> {
  final Ref _ref;
  AIChatNotifier(this._ref) : super([]) {
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    state = [
      AIChatMessage(
        id: 'welcome',
        text: 'Hello! I am your FlashCart AI personal shopping assistant. 🥦🤖\n\nI can help you find fresh products, build meal plans, analyze your nutrition, or suggest recipes. What are you looking to cook or buy today?',
        isUser: false,
        timestamp: DateTime.now(),
        followUpQuestions: const [
          'What are some healthy breakfast options?',
          'Find organic gluten-free snacks',
          'Create a party recipe under \$20',
        ],
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final typingMsg = AIChatMessage(
      id: 'typing',
      text: 'Thinking...',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );

    state = [...state, userMsg, typingMsg];

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Remove typing indicator
    final listWithoutTyping = state.where((m) => m.id != 'typing').toList();

    // Determine smart context-aware response based on keywords
    String replyText = "I found some fantastic fresh options for you in our store. These are in stock and can be delivered to your doorstep in 10 minutes!";
    List<Product> recommendedProducts = [];
    List<String> suggestions = [];

    final query = text.toLowerCase();
    final allProducts = _ref.read(productsProvider).value ?? [];
    if (query.contains('breakfast') || query.contains('morning') || query.contains('egg') || query.contains('milk')) {
      replyText = "Here are some top-rated, nutritious breakfast essentials for a wholesome start to your morning! 🥚🥛";
      recommendedProducts = allProducts.where((p) => p.categoryId == 'cat_dairy' || p.categoryId == 'cat_bakery' || p.categoryId == 'dairy_bread').toList();
      suggestions = ['Any vegan options?', 'What bread goes well with this?', 'Tell me the total cost'];
    } else if (query.contains('organic') || query.contains('healthy') || query.contains('fruit') || query.contains('vegetable') || query.contains('salad')) {
      replyText = "Here are fresh, handpicked organic fruits and vegetables harvested straight from farm to dark store! 🍎🥦";
      recommendedProducts = allProducts.where((p) => p.name.toLowerCase().contains('organic') || p.categoryId == 'cat_fresh' || p.categoryId == 'veg_fruits').toList();
      suggestions = ['Give me a salad recipe', 'Are there any combos?', 'Show calorie information'];
    } else if (query.contains('party') || query.contains('snack') || query.contains('chips') || query.contains('drink')) {
      replyText = "Host like a pro! Here are premium quick-munch snacks and refreshing beverages for your party. 🥳🍕";
      recommendedProducts = allProducts.where((p) => p.categoryId == 'cat_snacks' || p.categoryId == 'cat_beverages' || p.categoryId == 'munchies' || p.categoryId == 'drinks' || p.isFlashDeal).toList();
      suggestions = ['Find high protein snacks', 'Add flat \$3 coupon', 'Which one is best selling?'];
    } else {
      // Default fallback using top trending items
      replyText = "I've searched our AI-enhanced catalog and recommended these trending and highly-rated options matching your description:";
      recommendedProducts = allProducts.take(3).toList();
      suggestions = ['Show me organic deals', 'Suggest a quick dinner recipe', 'Explain nutritional scores'];
    }

    final aiReply = AIChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      products: recommendedProducts.take(3).toList(),
      followUpQuestions: suggestions,
    );

    state = [...listWithoutTyping, aiReply];
  }

  void clearConversation() {
    _sendWelcomeMessage();
  }
}

final aiChatProvider = StateNotifierProvider<AIChatNotifier, List<AIChatMessage>>((ref) {
  return AIChatNotifier(ref);
});

// ==========================================
// 2. SMART GROCERY PLANNER NOTIFIER
// ==========================================
class GroceryPlannerNotifier extends StateNotifier<List<GroceryPlan>> {
  GroceryPlannerNotifier() : super([]) {
    _seedMockPlans();
  }

  void _seedMockPlans() {
    state = [];
  }

  void createPlan(String name, String type, String emoji, List<Product> items) {
    final total = items.fold(0.0, (sum, p) => sum + p.price);
    final newPlan = GroceryPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      emoji: emoji,
      items: items,
      totalCost: total,
      createdAt: DateTime.now(),
    );
    state = [newPlan, ...state];
  }

  void editPlan(String id, String name, String type, String emoji, List<Product> items) {
    final total = items.fold(0.0, (sum, p) => sum + p.price);
    state = state.map((plan) {
      if (plan.id == id) {
        return plan.copyWith(
          name: name,
          type: type,
          emoji: emoji,
          items: items,
          totalCost: total,
        );
      }
      return plan;
    }).toList();
  }

  void deletePlan(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final groceryPlannerProvider = StateNotifierProvider<GroceryPlannerNotifier, List<GroceryPlan>>((ref) {
  return GroceryPlannerNotifier();
});

// ==========================================
// 3. AI RECIPE GENERATOR PROVIDER
// ==========================================
final recipesProvider = Provider<List<RecipeModel>>((ref) {
  final allProducts = ref.watch(productsProvider).value ?? [];
  final defaultProduct = allProducts.isNotEmpty ? allProducts[0] : null;

  final broccoli = allProducts.firstWhere((p) => p.name.toLowerCase().contains('broccoli') || p.id == 'milk-001', orElse: () => defaultProduct!);
  final apple = allProducts.firstWhere((p) => p.name.toLowerCase().contains('apple') || p.id == 'apple-001', orElse: () => defaultProduct!);
  final milk = allProducts.firstWhere((p) => p.name.toLowerCase().contains('milk') || p.id == 'milk-001', orElse: () => defaultProduct!);
  final bread = allProducts.firstWhere((p) => p.name.toLowerCase().contains('bread') || p.id == 'carrot-001', orElse: () => defaultProduct!);

  return [
    RecipeModel(
      id: 'rec_1',
      title: 'Vibrant Farm-To-Table Broccoli Salad',
      description: 'A superfood crunch-salad packed with creamy dairy notes, fiber-rich florets, and organic crisp toppings.',
      difficulty: 'Easy',
      prepTimeMinutes: 10,
      cookTimeMinutes: 0,
      cuisine: 'Mediterranean',
      emoji: '🥗',
      ingredients: [
        '1 Fresh Organic Broccoli (chopped)',
        '1 Organic Red Apple (diced)',
        '2 tablespoons Low Fat Yogurt dressing',
        'Handful of Almonds and Sunflower Seeds',
        'Pinch of Salt & Crushed Black Pepper',
      ],
      steps: [
        'Wash the fresh organic broccoli florets thoroughly and cut into bite-sized pieces.',
        'Core and finely dice the sweet crisp red apple.',
        'In a large salad bowl, toss the broccoli and apple together.',
        'Drizzle fresh yogurt and sprinkle roasted almonds on top.',
        'Season with salt, pepper, and serve chilled immediately!'
      ],
      nutrition: const {
        'Calories': '210 kcal',
        'Protein': '6g',
        'Carbs': '18g',
        'Fat': '12g',
        'Fiber': '5g'
      },
      matchingProducts: [broccoli, apple],
    ),
    RecipeModel(
      id: 'rec_2',
      title: 'Artisan Golden Avocado Toast',
      description: 'Crispy premium bakery bread toasted to golden perfection and topped with rich mashed avocado.',
      difficulty: 'Easy',
      prepTimeMinutes: 5,
      cookTimeMinutes: 5,
      cuisine: 'Western',
      emoji: '🥑',
      ingredients: [
        '2 Slices of Whole Wheat Sourdough Bread',
        '1 Ripe Hass Avocado (mashed)',
        '1 teaspoon Organic Extra Virgin Olive Oil',
        'Crushed Chili Flakes & Sea Salt to taste',
      ],
      steps: [
        'Pop the premium wheat bread slices in the toaster until golden brown.',
        'Cut the avocado in half, remove the pit, and scoop the flesh into a bowl.',
        'Mash the avocado pulp coarsely with a fork, mixing in sea salt and olive oil.',
        'Spread the rich mashed mixture evenly over the warm toasted bread.',
        'Garnish with premium red chili flakes and enjoy instantly!'
      ],
      nutrition: const {
        'Calories': '320 kcal',
        'Protein': '8g',
        'Carbs': '24g',
        'Fat': '20g',
        'Fiber': '7g'
      },
      matchingProducts: [bread, broccoli], // Broccoli/Apple as vegetable fallback
    ),
    RecipeModel(
      id: 'rec_3',
      title: 'Velvety Berry Oat Smoothie',
      description: 'A creamy high-protein smoothie loaded with antioxidants and gut-friendly probiotics.',
      difficulty: 'Easy',
      prepTimeMinutes: 5,
      cookTimeMinutes: 0,
      cuisine: 'Continental',
      emoji: '🥤',
      ingredients: [
        '1 cup Fresh Berries',
        '1 cup Organic Dairy Milk or Almond Milk',
        '1/2 cup Rolled Oats',
        '1 tablespoon Organic Honey',
      ],
      steps: [
        'Place the chilled milk and rolled oats into a high-speed blender.',
        'Add the fresh berries and natural honey.',
        'Blend on high speed for 60 seconds until completely smooth and velvety.',
        'Pour into a tall glass and garnish with fresh mint leaves.'
      ],
      nutrition: const {
        'Calories': '280 kcal',
        'Protein': '10g',
        'Carbs': '42g',
        'Fat': '4g',
        'Sugar': '15g'
      },
      matchingProducts: [milk, apple],
    ),
  ];
});

// ==========================================
// 4. PANTRY SCANNER NOTIFIER
// ==========================================
class PantryScannerNotifier extends StateNotifier<List<PantryItem>> {
  PantryScannerNotifier() : super([]) {
    _initializePantry();
  }

  void _initializePantry() {
    state = [
      PantryItem(
        id: 'pantry_1',
        name: 'Fresh Farm Broccoli',
        emoji: '🥦',
        category: 'Fresh Produce',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        quantity: 75.0,
        unit: '%',
      ),
      PantryItem(
        id: 'pantry_2',
        name: 'Whole Wheat Sourdough',
        emoji: '🍞',
        category: 'Bakery',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        quantity: 10.0,
        unit: '%',
      ),
      PantryItem(
        id: 'pantry_3',
        name: 'Organic Milk Carton',
        emoji: '🥛',
        category: 'Dairy & Eggs',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        quantity: 40.0,
        unit: '%',
      ),
      PantryItem(
        id: 'pantry_4',
        name: 'Red Delicious Apples',
        emoji: '🍎',
        category: 'Fresh Produce',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        quantity: 0.0,
        unit: 'pcs',
        isMissing: true,
      ),
    ];
  }

  void toggleMissing(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isMissing: !item.isMissing);
      }
      return item;
    }).toList();
  }

  void updateQuantity(String id, double qty) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          quantity: qty,
          isMissing: qty <= 0,
        );
      }
      return item;
    }).toList();
  }

  void removePantryItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void addNewScannedItems(List<PantryItem> newItems) {
    state = [...newItems, ...state];
  }
}

final pantryScannerProvider = StateNotifierProvider<PantryScannerNotifier, List<PantryItem>>((ref) {
  return PantryScannerNotifier();
});

// ==========================================
// 5. BUDGET PLANNER NOTIFIER
// ==========================================
class BudgetPlannerNotifier extends StateNotifier<BudgetPlanState> {
  final Ref _ref;
  BudgetPlannerNotifier(this._ref)
      : super(const BudgetPlanState(
          limit: 30.0,
          familySize: 2,
          goal: 'Health-focused',
          optimizedList: [],
          totalCost: 0.0,
          savingsAmount: 0.0,
          alternativeProducts: {},
        )) {
    optimizeBudget(30.0, 2, 'Health-focused');
  }

  void optimizeBudget(double limit, int familySize, String goal) {
    // Select products that align with the goal and budget limits
    List<Product> sourceList = _ref.read(productsProvider).value ?? [];
    List<Product> optimized = [];
    double currentCost = 0.0;
    Map<String, Product> alts = {};

    if (goal == 'Health-focused') {
      // Prioritize cat_fresh, cat_dairy, items with 'organic'
      final healthItems = sourceList.where((p) => p.categoryId == 'cat_fresh' || p.categoryId == 'cat_dairy' || p.name.contains('Organic')).toList();
      for (final item in healthItems) {
        if (currentCost + item.price <= limit) {
          optimized.add(item);
          currentCost += item.price;
        }
      }
      // Populate some alternatives (cheaper alternatives for snacks/other items)
      final snack = sourceList.firstWhere((p) => p.categoryId == 'cat_snacks', orElse: () => sourceList[0]);
      final cheapFreshAlt = sourceList.firstWhere((p) => p.categoryId == 'cat_fresh' && p.price < snack.price, orElse: () => sourceList[1]);
      alts[snack.id] = cheapFreshAlt;

    } else if (goal == 'Max Savings') {
      // Sort items by price (lowest first) or discount percentage (highest first)
      final discountItems = List<Product>.from(sourceList);
      discountItems.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
      for (final item in discountItems) {
        if (currentCost + item.price <= limit) {
          optimized.add(item);
          currentCost += item.price;
        }
      }
      // Provide alternative suggestions for non-discounted products
      if (optimized.isNotEmpty) {
        final premiumItem = sourceList.firstWhere((p) => p.originalPrice > 10.0, orElse: () => sourceList[0]);
        final cheaperItem = sourceList.firstWhere((p) => p.price < 5.0, orElse: () => sourceList[1]);
        alts[premiumItem.id] = cheaperItem;
      }
    } else {
      // Default gourmet/combo/party Shopping
      final gourmetItems = sourceList.where((p) => p.isCombo || p.isFlashDeal || p.isTrending).toList();
      for (final item in gourmetItems) {
        if (currentCost + item.price <= limit) {
          optimized.add(item);
          currentCost += item.price;
        }
      }
    }

    state = BudgetPlanState(
      limit: limit,
      familySize: familySize,
      goal: goal,
      optimizedList: optimized,
      totalCost: currentCost,
      savingsAmount: limit * 0.15, // Mock savings indicator
      alternativeProducts: alts,
    );
  }
}

final budgetPlannerProvider = StateNotifierProvider<BudgetPlannerNotifier, BudgetPlanState>((ref) {
  return BudgetPlannerNotifier(ref);
});

// ==========================================
// 6. NUTRITION DASHBOARD NOTIFIER
// ==========================================
class NutritionDashboardNotifier extends StateNotifier<NutritionState> {
  NutritionDashboardNotifier()
      : super(const NutritionState(
          caloriesLimit: 2000,
          caloriesConsumed: 1150,
          proteinGrams: 42.5,
          carbsGrams: 145.0,
          fatGrams: 34.0,
          sugarGrams: 28.5,
          healthyScore: 82.0,
          categoryDistribution: {
            'Fresh Veggies': 40.0,
            'Dairy Protein': 30.0,
            'Healthy Grains': 20.0,
            'Sweet Treats': 10.0,
          },
        ));

  void logProductNutrition(Product product) {
    // Parse nutrition info from product model (e.g. {'Calories': '350 kcal', 'Protein': '12g', ...})
    final calStr = product.nutritionInfo['Calories'] ?? '150';
    final calories = int.tryParse(calStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 150;

    final protStr = product.nutritionInfo['Protein'] ?? '5g';
    final protein = double.tryParse(protStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 5.0;

    final carbStr = product.nutritionInfo['Carbs'] ?? '20g';
    final carbs = double.tryParse(carbStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 20.0;

    final fatStr = product.nutritionInfo['Fat'] ?? '3g';
    final fat = double.tryParse(fatStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 3.0;

    final scoreDelta = product.categoryId == 'cat_fresh' ? 2.5 : -1.5;
    final newScore = (state.healthyScore + scoreDelta).clamp(0.0, 100.0);

    state = state.copyWith(
      caloriesConsumed: state.caloriesConsumed + calories,
      proteinGrams: state.proteinGrams + protein,
      carbsGrams: state.carbsGrams + carbs,
      fatGrams: state.fatGrams + fat,
      healthyScore: newScore,
    );
  }

  void resetNutrition() {
    state = const NutritionState(
      caloriesLimit: 2000,
      caloriesConsumed: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      sugarGrams: 0,
      healthyScore: 100.0,
      categoryDistribution: {
        'Fresh Veggies': 0.0,
        'Dairy Protein': 0.0,
        'Healthy Grains': 0.0,
        'Sweet Treats': 0.0,
      },
    );
  }
}

final nutritionDashboardProvider = StateNotifierProvider<NutritionDashboardNotifier, NutritionState>((ref) {
  return NutritionDashboardNotifier();
});

// ==========================================
// 7. AI SHOPPING INSIGHTS PROVIDER
// ==========================================
final shoppingInsightsProvider = Provider<ShoppingInsightsState>((ref) {
  final allProducts = ref.watch(productsProvider).value ?? [];
  final bestSelling = allProducts.where((p) => p.isBestSeller).toList();
  final topPurchases = bestSelling.isNotEmpty ? bestSelling.take(3).toList() : allProducts.take(3).toList();

  return ShoppingInsightsState(
    monthlySpending: 1450.50,
    monthlySavings: 215.80,
    couponsUsed: 8,
    categoryBreakdown: const {
      'Organic Produce': 420.0,
      'Dairy & Breakfast': 350.0,
      'Bakery': 210.0,
      'Munchies & Snacks': 280.0,
      'Beverages': 190.50,
    },
    topPurchases: topPurchases,
    weeklySpendingTrend: const [280.0, 390.0, 310.0, 470.50],
  );
});
