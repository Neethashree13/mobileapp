import 'package:flutter/material.dart';
import 'package:flashcart_ai/features/home/models/home_models.dart';

// ==========================================
// 1. AI CHAT MESSAGE MODEL
// ==========================================
class AIChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final List<Product>? products;
  final DateTime timestamp;
  final List<String>? followUpQuestions;
  final bool isTyping;

  const AIChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.products,
    required this.timestamp,
    this.followUpQuestions,
    this.isTyping = false,
  });

  AIChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    List<Product>? products,
    DateTime? timestamp,
    List<String>? followUpQuestions,
    bool? isTyping,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      products: products ?? this.products,
      timestamp: timestamp ?? this.timestamp,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

// ==========================================
// 2. SMART GROCERY PLAN MODEL
// ==========================================
class GroceryPlan {
  final String id;
  final String name;
  final String type; // e.g. Weekly, Monthly, Festival, Party, Baby Essentials, Pet Supplies, Students, Family
  final String emoji;
  final List<Product> items;
  final double totalCost;
  final DateTime createdAt;

  const GroceryPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.emoji,
    required this.items,
    required this.totalCost,
    required this.createdAt,
  });

  GroceryPlan copyWith({
    String? id,
    String? name,
    String? type,
    String? emoji,
    List<Product>? items,
    double? totalCost,
    DateTime? createdAt,
  }) {
    return GroceryPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      items: items ?? this.items,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ==========================================
// 3. AI RECIPE MODEL
// ==========================================
class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String difficulty; // e.g. Easy, Medium, Hard
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String cuisine;
  final String emoji;
  final List<String> ingredients;
  final List<String> steps;
  final Map<String, String> nutrition; // e.g. {'Calories': '350 kcal', 'Protein': '12g', ...}
  final List<Product> matchingProducts; // Products in store for easy add-to-cart

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.cuisine,
    required this.emoji,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.matchingProducts,
  });
}

// ==========================================
// 4. PANTRY SCANNER MODEL
// ==========================================
class PantryItem {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final DateTime expiryDate;
  final double quantity; // percentage left or absolute count
  final String unit; // e.g. '%', 'pcs', 'kg'
  final bool isMissing;
  final Product? storeProduct;

  const PantryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    this.isMissing = false,
    this.storeProduct,
  });

  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  PantryItem copyWith({
    String? id,
    String? name,
    String? emoji,
    String? category,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    bool? isMissing,
    Product? storeProduct,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isMissing: isMissing ?? this.isMissing,
      storeProduct: storeProduct ?? this.storeProduct,
    );
  }
}

// ==========================================
// 5. BUDGET PLANNER STATE
// ==========================================
class BudgetPlanState {
  final double limit;
  final int familySize;
  final String goal; // e.g., 'Health-focused', 'Max Savings', 'Gourmet Feast'
  final List<Product> optimizedList;
  final double totalCost;
  final double savingsAmount;
  final Map<String, Product> alternativeProducts; // Original ID -> Healthier/Cheaper Alt Product

  const BudgetPlanState({
    required this.limit,
    required this.familySize,
    required this.goal,
    required this.optimizedList,
    required this.totalCost,
    required this.savingsAmount,
    required this.alternativeProducts,
  });

  BudgetPlanState copyWith({
    double? limit,
    int? familySize,
    String? goal,
    List<Product>? optimizedList,
    double? totalCost,
    double? savingsAmount,
    Map<String, Product>? alternativeProducts,
  }) {
    return BudgetPlanState(
      limit: limit ?? this.limit,
      familySize: familySize ?? this.familySize,
      goal: goal ?? this.goal,
      optimizedList: optimizedList ?? this.optimizedList,
      totalCost: totalCost ?? this.totalCost,
      savingsAmount: savingsAmount ?? this.savingsAmount,
      alternativeProducts: alternativeProducts ?? this.alternativeProducts,
    );
  }
}

// ==========================================
// 6. NUTRITION DASHBOARD STATE
// ==========================================
class NutritionState {
  final int caloriesLimit;
  final int caloriesConsumed;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double sugarGrams;
  final double healthyScore; // 0.0 to 100.0
  final Map<String, double> categoryDistribution; // e.g., {'Fruits & Veggies': 40.0, ...}

  const NutritionState({
    required this.caloriesLimit,
    required this.caloriesConsumed,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.sugarGrams,
    required this.healthyScore,
    required this.categoryDistribution,
  });

  NutritionState copyWith({
    int? caloriesLimit,
    int? caloriesConsumed,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? sugarGrams,
    double? healthyScore,
    Map<String, double>? categoryDistribution,
  }) {
    return NutritionState(
      caloriesLimit: caloriesLimit ?? this.caloriesLimit,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      sugarGrams: sugarGrams ?? this.sugarGrams,
      healthyScore: healthyScore ?? this.healthyScore,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
    );
  }
}

// ==========================================
// 7. AI SHOPPING INSIGHTS STATE
// ==========================================
class ShoppingInsightsState {
  final double monthlySpending;
  final double monthlySavings;
  final int couponsUsed;
  final Map<String, double> categoryBreakdown; // {'Snacks': 150.0, 'Organic': 350.0}
  final List<Product> topPurchases;
  final List<double> weeklySpendingTrend; // 4 values for past 4 weeks

  const ShoppingInsightsState({
    required this.monthlySpending,
    required this.monthlySavings,
    required this.couponsUsed,
    required this.categoryBreakdown,
    required this.topPurchases,
    required this.weeklySpendingTrend,
  });
}
