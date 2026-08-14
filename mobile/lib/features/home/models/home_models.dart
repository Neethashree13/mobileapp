// import 'package:flutter/material.dart';

// class Product {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final double originalPrice;
//   final int discountPercentage;
//   final double rating;
//   final int reviewCount;
//   final String imageUrl; // Emoji fallback combined with beautiful unsplash image urls
//   final String emoji; // Emoji representation for visual backup
//   final Color fallbackColor; // Gradient fallback color
//   final String categoryId;
//   final int deliveryTimeMins;
//   final bool isBestSeller;
//   final bool isFlashDeal;
//   final bool isTrending;
//   final bool isSeasonal;
//   final bool isCombo;
//   final String brand;
//   final int stock;
//   final List<String> ingredients;
//   final Map<String, String> nutritionInfo;
//   final String weight;

//   const Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.originalPrice,
//     required this.discountPercentage,
//     required this.rating,
//     required this.reviewCount,
//     required this.imageUrl,
//     required this.emoji,
//     required this.fallbackColor,
//     required this.categoryId,
//     required this.deliveryTimeMins,
//     this.isBestSeller = false,
//     this.isFlashDeal = false,
//     this.isTrending = false,
//     this.isSeasonal = false,
//     this.isCombo = false,
//     required this.brand,
//     required this.stock,
//     required this.ingredients,
//     required this.nutritionInfo,
//     required this.weight,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic val, [double def = 0.0]) {
//       if (val == null) return def;
//       if (val is num) return val.toDouble();
//       if (val is String) return double.tryParse(val) ?? def;
//       return def;
//     }

//     int parseInt(dynamic val, [int def = 0]) {
//       if (val == null) return def;
//       if (val is num) return val.toInt();
//       if (val is String) return int.tryParse(val) ?? def;
//       return def;
//     }

//     final price = parseDouble(json['price']);
//     final origPrice = parseDouble(json['originalPrice'], price);
//     final discount = origPrice > price ? (((origPrice - price) / origPrice) * 100).round() : 0;

//     return Product(
//       id: json['id']?.toString() ?? '',
//       name: json['name'] as String? ?? '',
//       description: json['description'] as String? ?? '',
//       price: price,
//       originalPrice: origPrice,
//       discountPercentage: json['discountPercentage'] != null ? parseInt(json['discountPercentage']) : discount,
//       rating: parseDouble(json['rating']),
//       reviewCount: json['reviewsCount'] != null ? parseInt(json['reviewsCount']) : parseInt(json['reviewCount']),
//       imageUrl: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
//       emoji: json['emoji'] as String? ?? '🛒',
//       fallbackColor: const Color(0xFFE8F5E9),
//       categoryId: json['category'] as String? ?? json['categoryId'] as String? ?? 'grocery',
//       deliveryTimeMins: parseInt(json['deliveryTimeMins'], 10),
//       isBestSeller: json['isBestSeller'] as bool? ?? false,
//       isFlashDeal: json['isFlashDeal'] as bool? ?? false,
//       isTrending: json['isTrending'] as bool? ?? false,
//       isSeasonal: json['isSeasonal'] as bool? ?? false,
//       isCombo: json['isCombo'] as bool? ?? false,
//       brand: json['brand'] as String? ?? '',
//       stock: json['inventory'] != null ? parseInt(json['inventory']) : parseInt(json['stock']),
//       ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
//       nutritionInfo: json['nutritionInfo'] is Map
//           ? (json['nutritionInfo'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
//           : const {},
//       weight: json['unit'] as String? ?? json['weight'] as String? ?? '',
//     );
//   }
// }

// class Category {
//   final String id;
//   final String name;
//   final String emoji;
//   final Color color;

//   const Category({
//     required this.id,
//     required this.name,
//     required this.emoji,
//     required this.color,
//   });
// }

// class Offer {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String code;
//   final String discountText;
//   final Color bgColor;

//   const Offer({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.code,
//     required this.discountText,
//     required this.bgColor,
//   });
// }

// class BannerItem {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String code;
//   final String buttonText;
//   final String imagePath; // We can use eco_banner or online placeholders
//   final Color bgColor;

//   const BannerItem({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.code,
//     required this.buttonText,
//     required this.imagePath,
//     required this.bgColor,
//   });
// }

// class Brand {
//   final String id;
//   final String name;
//   final String logoEmoji;
//   final String description;
//   final Color color;

//   const Brand({
//     required this.id,
//     required this.name,
//     required this.logoEmoji,
//     required this.description,
//     required this.color,
//   });
// }

// class Collection {
//   final String id;
//   final String title;
//   final String subtitle;
//   final List<String> productIds;
//   final String emoji;
//   final Color color;

//   const Collection({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.productIds,
//     required this.emoji,
//     required this.color,
//   });
// }

// // Global Static Datasets representing premium curated list
// class MockData {
//   static const List<Category> categories = [
//     Category(id: 'veg_fruits', name: 'Fruits & Vegetables', emoji: '🥦', color: Color(0xFFE8F5E9)),
//     Category(id: 'dairy_bread', name: 'Dairy, Bread & Eggs', emoji: '🥛', color: Color(0xFFE3F2FD)),
//     Category(id: 'munchies', name: 'Munchies & Chips', emoji: '🍿', color: Color(0xFFFFF3E0)),
//     Category(id: 'drinks', name: 'Cold Drinks & Juices', emoji: '🥤', color: Color(0xFFF3E5F5)),
//     Category(id: 'instant', name: 'Instant & Frozen Food', emoji: '🍜', color: Color(0xFFFFEBEE)),
//     Category(id: 'bakery', name: 'Bakery & Sweet Cakes', emoji: '🍰', color: Color(0xFFFDF2E9)),
//     Category(id: 'meat_fish', name: 'Meat, Fish & Seafood', emoji: '🍗', color: Color(0xFFEFEBE9)),
//     Category(id: 'household', name: 'Household & Cleaning', emoji: '🧼', color: Color(0xFFE0F7FA)),
//   ];

//   static const List<Offer> offers = [
//     Offer(
//       id: 'o1',
//       title: 'Mega Organic Sale',
//       subtitle: 'Flat 50% off on first organic order',
//       code: 'ORGANIC50',
//       discountText: '50% OFF',
//       bgColor: Color(0xFF047857),
//     ),
//     Offer(
//       id: 'o2',
//       title: 'Midnight Munchies Rush',
//       subtitle: 'Get free delivery on snacks above \$15',
//       code: 'CRUNCHY',
//       discountText: 'FREE DEL',
//       bgColor: Color(0xFF7C3AED),
//     ),
//     Offer(
//       id: 'o3',
//       title: 'Dairy Fresh Morning',
//       subtitle: 'Save 20% on fresh premium whole milk & buns',
//       code: 'FRESH20',
//       discountText: '20% OFF',
//       bgColor: Color(0xFF2563EB),
//     ),
//   ];

//   static const List<BannerItem> banners = [
//     BannerItem(
//       id: 'b1',
//       title: 'Organic Produce Farm Fresh',
//       subtitle: 'Guaranteed 10-Minute Delivery directly to your doorstep',
//       code: 'FARM10',
//       buttonText: 'Shop Fresh',
//       imagePath: 'assets/images/eco_banner.jpg',
//       bgColor: Color(0xFF0F5132),
//     ),
//     BannerItem(
//       id: 'b2',
//       title: 'Craving Late Night Munchies?',
//       subtitle: 'Hot chips, sodas, and ice-creams delivered in 8 mins',
//       code: 'CRAVE8',
//       buttonText: 'Order Now',
//       imagePath: '', // fallback to gradient
//       bgColor: Color(0xFF51103F),
//     ),
//     BannerItem(
//       id: 'b3',
//       title: 'Pre-Cooked Gourmet Combos',
//       subtitle: 'Saves 30% time & money. Healthy single portions',
//       code: 'COMBO30',
//       buttonText: 'Explore Combos',
//       imagePath: '', // fallback to gradient
//       bgColor: Color(0xFF0B3F54),
//     ),
//   ];

//   static const List<Brand> brands = [
//     Brand(id: 'br1', name: 'Organic Farms Co.', logoEmoji: '🚜', description: '100% Certified Organic growers', color: Color(0xFFE8F5E9)),
//     Brand(id: 'br2', name: 'DairyLand Premium', logoEmoji: '🐄', description: 'Fresh, pasteurized pasture milk products', color: Color(0xFFE3F2FD)),
//     Brand(id: 'br3', name: 'SnackOverload', logoEmoji: '🍟', description: 'Delicious gourmet crisps & dips', color: Color(0xFFFFF3E0)),
//     Brand(id: 'br4', name: 'Gourmet Kitchen', logoEmoji: '🍳', description: 'Healthy ready-to-eat frozen culinary arts', color: Color(0xFFFFEBEE)),
//   ];

//   static const List<Collection> collections = [
//     Collection(
//       id: 'col1',
//       title: 'Rainy Day Essentials',
//       subtitle: 'Tea, hot snacks, ginger, and instant soups',
//       productIds: ['p5', 'p10', 'p12'],
//       emoji: '🌧️',
//       color: Color(0xFFECEFF1),
//     ),
//     Collection(
//       id: 'col2',
//       title: 'High Protein Breakfast',
//       subtitle: 'Whole milk, free-range eggs, sourdough bread',
//       productIds: ['p3', 'p4', 'p8'],
//       emoji: '💪',
//       color: Color(0xFFE8EAF6),
//     ),
//   ];

//   static final List<Product> products = [
//     // Fruits & Vegetables
//     const Product(
//       id: 'p1',
//       name: 'Organic Red Apples',
//       description: 'Crisp, sweet, and handpicked premium organic apples from Shimla farms. Perfect for healthy snacking or making fresh morning juices.',
//       price: 2.99,
//       originalPrice: 3.99,
//       discountPercentage: 25,
//       rating: 4.8,
//       reviewCount: 142,
//       imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍎',
//       fallbackColor: Color(0xFFFFEBEE),
//       categoryId: 'veg_fruits',
//       deliveryTimeMins: 9,
//       isBestSeller: true,
//       isSeasonal: true,
//       brand: 'Organic Farms Co.',
//       stock: 35,
//       ingredients: ['100% Organic Red Apples'],
//       nutritionInfo: {'Calories': '95 kcal', 'Fiber': '4.4g', 'Sugar': '19g', 'Vitamin C': '14% DV'},
//       weight: '500g',
//     ),
//     const Product(
//       id: 'p2',
//       name: 'Fresh Hydroponic Spinach',
//       description: 'Zero pesticide, iron-rich fresh green baby spinach leaves. Cultivated in high-tech hydroponic facilities under safe sanitization guidelines.',
//       price: 1.49,
//       originalPrice: 1.99,
//       discountPercentage: 25,
//       rating: 4.6,
//       reviewCount: 98,
//       imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&auto=format&fit=crop&q=60',
//       emoji: '🥬',
//       fallbackColor: Color(0xFFE8F5E9),
//       categoryId: 'veg_fruits',
//       deliveryTimeMins: 11,
//       isFlashDeal: true,
//       brand: 'Organic Farms Co.',
//       stock: 15,
//       ingredients: ['Fresh Clean Hydroponic Spinach'],
//       nutritionInfo: {'Calories': '23 kcal', 'Protein': '2.9g', 'Iron': '15% DV', 'Vitamin A': '188% DV'},
//       weight: '200g',
//     ),
    
//     // Dairy, Bread & Eggs
//     const Product(
//       id: 'p3',
//       name: 'Pasteurized Whole Milk',
//       description: 'Rich, creamy farm-fresh pasteurized whole cow milk. Bottled under sterile environment and cold-chain distributed under 4 degrees Celsius.',
//       price: 1.99,
//       originalPrice: 2.20,
//       discountPercentage: 10,
//       rating: 4.9,
//       reviewCount: 354,
//       imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=60',
//       emoji: '🥛',
//       fallbackColor: Color(0xFFE3F2FD),
//       categoryId: 'dairy_bread',
//       deliveryTimeMins: 8,
//       isBestSeller: true,
//       brand: 'DairyLand Premium',
//       stock: 60,
//       ingredients: ['Homogenized Whole Milk', 'Vitamin D3'],
//       nutritionInfo: {'Calories': '150 kcal', 'Fat': '8g', 'Calcium': '30% DV', 'Protein': '8g'},
//       weight: '1 Litre',
//     ),
//     const Product(
//       id: 'p4',
//       name: 'Artisanal Sourdough Bread',
//       description: 'Naturally leavened rustic sourdough bread with a hard crispy crust and soft chewy interior. Freshly baked at dawn using wild yeast culture.',
//       price: 3.49,
//       originalPrice: 4.50,
//       discountPercentage: 22,
//       rating: 4.7,
//       reviewCount: 115,
//       imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍞',
//       fallbackColor: Color(0xFFFFF8E1),
//       categoryId: 'dairy_bread',
//       deliveryTimeMins: 12,
//       isTrending: true,
//       brand: 'Gourmet Kitchen',
//       stock: 8,
//       ingredients: ['Organic Wheat Flour', 'Natural Yeast Culture', 'Sea Salt', 'Filtered Water'],
//       nutritionInfo: {'Calories': '180 kcal', 'Carbohydrates': '36g', 'Fiber': '2g', 'Sodium': '380mg'},
//       weight: '400g',
//     ),

//     // Munchies & Chips
//     const Product(
//       id: 'p5',
//       name: 'Salted Truffle Potato Crisps',
//       description: 'Slow-cooked handcut kettle potato chips flavored with rare Italian black truffles and sea salt crystals. Exquisite premium crunch.',
//       price: 2.49,
//       originalPrice: 2.99,
//       discountPercentage: 16,
//       rating: 4.5,
//       reviewCount: 201,
//       imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d20?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍿',
//       fallbackColor: Color(0xFFFFF3E0),
//       categoryId: 'munchies',
//       deliveryTimeMins: 8,
//       isTrending: true,
//       brand: 'SnackOverload',
//       stock: 45,
//       ingredients: ['Select Potatoes', 'Sunflower Oil', 'Black Truffle Powder', 'Sea Salt'],
//       nutritionInfo: {'Calories': '150 kcal', 'Total Fat': '9g', 'Saturated Fat': '1g', 'Sodium': '170mg'},
//       weight: '150g',
//     ),
//     const Product(
//       id: 'p6',
//       name: 'Spiced Jalapeno Tortilla Chips',
//       description: 'Classic corn tortilla chips loaded with fiery Mexican jalapeno spices and cool lime zest. Fantastic accompaniment with fresh cheese salsa.',
//       price: 1.89,
//       originalPrice: 2.49,
//       discountPercentage: 24,
//       rating: 4.3,
//       reviewCount: 76,
//       imageUrl: 'https://images.unsplash.com/photo-1518047601542-79f18c655718?w=500&auto=format&fit=crop&q=60',
//       emoji: '🌮',
//       fallbackColor: Color(0xFFFFE0B2),
//       categoryId: 'munchies',
//       deliveryTimeMins: 10,
//       isFlashDeal: true,
//       brand: 'SnackOverload',
//       stock: 22,
//       ingredients: ['Ground Yellow Corn', 'Vegetable Oil', 'Jalapeno Pepper Powder', 'Lime Powder', 'Spices'],
//       nutritionInfo: {'Calories': '140 kcal', 'Total Fat': '7g', 'Sodium': '150mg', 'Carbohydrates': '18g'},
//       weight: '180g',
//     ),

//     // Cold Drinks & Juices
//     const Product(
//       id: 'p7',
//       name: 'Zero Sugar Spark Cola',
//       description: 'Sugar-free crisp fizzy cola drink with refreshing natural caffeine extracts. Maximum guilt-free chilling experience.',
//       price: 0.99,
//       originalPrice: 1.25,
//       discountPercentage: 20,
//       rating: 4.2,
//       reviewCount: 412,
//       imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500&auto=format&fit=crop&q=60',
//       emoji: '🥤',
//       fallbackColor: Color(0xFFECEFF1),
//       categoryId: 'drinks',
//       deliveryTimeMins: 7,
//       isBestSeller: true,
//       brand: 'SnackOverload',
//       stock: 120,
//       ingredients: ['Carbonated Water', 'Caramel Color', 'Phosphoric Acid', 'Aspartame', 'Natural Flavors', 'Caffeine'],
//       nutritionInfo: {'Calories': '0 kcal', 'Total Fat': '0g', 'Sodium': '40mg', 'Total Carbs': '0g'},
//       weight: '330ml',
//     ),
//     const Product(
//       id: 'p8',
//       name: 'Cold Pressed Orange Juice',
//       description: '100% natural, freshly squeezed high-pulp Florida oranges. Never concentrated, pasteurized using safe hyperbaric pressure (HPP) to preserve vitamins.',
//       price: 3.99,
//       originalPrice: 4.99,
//       discountPercentage: 20,
//       rating: 4.8,
//       reviewCount: 184,
//       imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍊',
//       fallbackColor: Color(0xFFFFF3E0),
//       categoryId: 'drinks',
//       deliveryTimeMins: 11,
//       isTrending: true,
//       isSeasonal: true,
//       brand: 'Organic Farms Co.',
//       stock: 18,
//       ingredients: ['100% Squeezed Cold-Pressed Orange Juice with pulp'],
//       nutritionInfo: {'Calories': '110 kcal', 'Sugar': '21g', 'Vitamin C': '120% DV', 'Potassium': '450mg'},
//       weight: '350ml',
//     ),

//     // Instant & Frozen Food
//     const Product(
//       id: 'p9',
//       name: 'Artisan Frozen Pepperoni Pizza',
//       description: 'Thin crust hand-stretched woodfired pizza topped with Italian salami pepperoni, whole milk mozzarella cheese, and rich San Marzano tomato puree.',
//       price: 6.99,
//       originalPrice: 8.99,
//       discountPercentage: 22,
//       rating: 4.6,
//       reviewCount: 153,
//       imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍕',
//       fallbackColor: Color(0xFFFFEBEE),
//       categoryId: 'instant',
//       deliveryTimeMins: 14,
//       brand: 'Gourmet Kitchen',
//       stock: 14,
//       ingredients: ['Wheat Flour', 'Mozzarella Cheese', 'Pepperoni Salami', 'San Marzano Tomato Sauce', 'Oregano'],
//       nutritionInfo: {'Calories': '320 kcal / slice', 'Protein': '15g', 'Sodium': '680mg', 'Calcium': '20% DV'},
//       weight: '450g',
//     ),

//     // Sweet Cakes
//     const Product(
//       id: 'p10',
//       name: 'Belgian Chocolate Mousse Cake',
//       description: 'Heavenly layers of dark chocolate sponge cake filled with velvety Belgian chocolate mousse and decorated with golden chocolate flakes.',
//       price: 8.49,
//       originalPrice: 10.99,
//       discountPercentage: 22,
//       rating: 4.9,
//       reviewCount: 220,
//       imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍰',
//       fallbackColor: Color(0xFFEFEBE9),
//       categoryId: 'bakery',
//       deliveryTimeMins: 12,
//       isTrending: true,
//       brand: 'Gourmet Kitchen',
//       stock: 6,
//       ingredients: ['Belgian Dark Chocolate', 'Fresh Whipped Cream', 'Eggs', 'Sugar', 'Wheat Flour', 'Cocoa Butter'],
//       nutritionInfo: {'Calories': '410 kcal', 'Total Fat': '24g', 'Saturated Fat': '14g', 'Sugar': '32g'},
//       weight: '500g',
//     ),

//     // Combo Packs
//     const Product(
//       id: 'p11',
//       name: 'Perfect Breakfast Combo',
//       description: 'Super healthy bundle containing 1L Pasteurized Whole Milk, 6 Free-Range Eggs, and a loaf of fresh Artisanal Sourdough Bread. Saves 25%!',
//       price: 5.99,
//       originalPrice: 8.50,
//       discountPercentage: 29,
//       rating: 4.8,
//       reviewCount: 310,
//       imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500&auto=format&fit=crop&q=60',
//       emoji: '🍳',
//       fallbackColor: Color(0xFFF1F8E9),
//       categoryId: 'dairy_bread',
//       deliveryTimeMins: 11,
//       isCombo: true,
//       brand: 'DairyLand Premium',
//       stock: 25,
//       ingredients: ['1L Pasteurized Milk', '6 Large Organic Eggs', '400g Sourdough Bread'],
//       nutritionInfo: {'Package Contents': 'Milk, Eggs, Sourdough Bread. Rich source of protein, carbs and calcium'},
//       weight: '1 Combo Pack',
//     ),
//     const Product(
//       id: 'p12',
//       name: 'Guacamole DIY Combo Pack',
//       description: 'Convenient DIY pack including 2 Hass Avocados, 1 Red Onion, 1 Lime, Fresh Coriander, and 1 Jalapeno chili. Make ultra-fresh guacamole at home in minutes.',
//       price: 4.49,
//       originalPrice: 6.00,
//       discountPercentage: 25,
//       rating: 4.7,
//       reviewCount: 88,
//       imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&auto=format&fit=crop&q=60',
//       emoji: '🥑',
//       fallbackColor: Color(0xFFF1F8E9),
//       categoryId: 'veg_fruits',
//       deliveryTimeMins: 10,
//       isCombo: true,
//       isSeasonal: true,
//       brand: 'Organic Farms Co.',
//       stock: 12,
//       ingredients: ['2 Avocados', '1 Onion', '1 Lemon', 'Coriander bunch', '1 Chili'],
//       nutritionInfo: {'Vitamins': 'Rich in Healthy Fats, Potassium, Vitamin E and dietary Fiber'},
//       weight: '1 DIY Pack',
//     ),
//   ];
// }


import 'package:flutter/material.dart';

typedef ProductModel = Product;

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int discountPercentage;
  final double rating;
  final int reviewCount;
  final String imageUrl; // Emoji fallback combined with beautiful unsplash image urls
  final String emoji; // Emoji representation for visual backup
  final Color fallbackColor; // Gradient fallback color
  final String categoryId;
  final int deliveryTimeMins;
  final bool isBestSeller;
  final bool isFlashDeal;
  final bool isTrending;
  final bool isSeasonal;
  final bool isCombo;
  final String brand;
  final int stock;
  final List<String> ingredients;
  final Map<String, String> nutritionInfo;
  final String weight;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.emoji,
    required this.fallbackColor,
    required this.categoryId,
    required this.deliveryTimeMins,
    this.isBestSeller = false,
    this.isFlashDeal = false,
    this.isTrending = false,
    this.isSeasonal = false,
    this.isCombo = false,
    required this.brand,
    required this.stock,
    required this.ingredients,
    required this.nutritionInfo,
    required this.weight,
  });

factory Product.fromJson(Map<String,dynamic> json){

double parseDouble(dynamic value){
  if(value == null) return 0;
  if(value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}


int parseInt(dynamic value){
  if(value == null) return 0;
  if(value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}


final price=parseDouble(json['price']);

final originalPrice=parseDouble(
 json['originalPrice']
);


return Product(

id: json['id']?.toString() ?? '',


name:
json['name']?.toString() ?? '',


description:
json['description']?.toString() ??
'Fresh quality product',


price:price,


originalPrice:originalPrice,


discountPercentage:
originalPrice>price
?
(((originalPrice-price)/originalPrice)*100).round()
:
0,


rating:
parseDouble(json['rating']),


reviewCount:
parseInt(
 json['reviewsCount'] ??
 json['reviewCount']
),



imageUrl:
json['image']?.toString()
??
json['imageUrl']?.toString()
??
'',



emoji:'🛒',


fallbackColor:
const Color(0xffE8F5E9),



categoryId:
json['category']
?.toString()
.toLowerCase()
??
'',



deliveryTimeMins:
parseInt(
json['deliveryTimeMins']
??
10
),



isBestSeller:
json['isBestSeller'] ?? false,


isFlashDeal:
json['isFlashDeal'] ?? false,


isTrending:
json['isTrending'] ?? false,


isSeasonal:false,


isCombo:false,



brand:
json['brand']?.toString()
??
json['brandId']?.toString()
??
'',



stock:
parseInt(
json['inventory']
??
json['inventoryCount']
),



ingredients:
const [],



nutritionInfo:{
'Calories':
'${json['calories'] ?? 0}',

'Protein':
'${json['protein'] ?? 0} g'
},



weight:
json['unit']?.toString()
??
'1 pc'

);

}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': weight.isNotEmpty ? weight : '1 pc',
      'image': imageUrl,
      'category': categoryId,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String emoji;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class Offer {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String discountText;
  final Color bgColor;

  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.discountText,
    required this.bgColor,
  });
}

class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String buttonText;
  final String imagePath; // We can use eco_banner or online placeholders
  final Color bgColor;

  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.buttonText,
    required this.imagePath,
    required this.bgColor,
  });
}

class Brand {
  final String id;
  final String name;
  final String logoEmoji;
  final String description;
  final Color color;

  const Brand({
    required this.id,
    required this.name,
    required this.logoEmoji,
    required this.description,
    required this.color,
  });
}

class Collection {
  final String id;
  final String title;
  final String subtitle;
  final List<String> productIds;
  final String emoji;
  final Color color;

  const Collection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.productIds,
    required this.emoji,
    required this.color,
  });
}

// Global Static Datasets representing premium curated list
class MockData {
  static const List<Category> categories = [
    Category(
      id: 'fruits',
      name: 'Fruits',
      emoji: '🍎',
      color: Color(0xFFE8F5E9),
    ),
    Category(
      id: 'vegetables',
      name: 'Vegetables',
      emoji: '🥦',
      color: Color(0xFFE8F5E9),
    ),
    Category(
      id: 'dairy',
      name: 'Dairy',
      emoji: '🥛',
      color: Color(0xFFE3F2FD),
    ),
    Category(
      id: 'snacks',
      name: 'Snacks',
      emoji: '🍿',
      color: Color(0xFFFFF3E0),
    ),
    Category(
      id: 'beverages',
      name: 'Beverages',
      emoji: '🥤',
      color: Color(0xFFF3E5F5),
    ),
    Category(
      id: 'bakery',
      name: 'Bakery',
      emoji: '🍰',
      color: Color(0xFFFDF2E9),
    ),
    Category(
      id: 'meat',
      name: 'Meat & Seafood',
      emoji: '🍗',
      color: Color(0xFFEFEBE9),
    ),
    Category(
      id: 'household',
      name: 'Household',
      emoji: '🧼',
      color: Color(0xFFE0F7FA),
    ),
  ];

  static const List<Offer> offers = [
    Offer(
      id: 'o1',
      title: 'Mega Organic Sale',
      subtitle: 'Flat 50% off on first organic order',
      code: 'ORGANIC50',
      discountText: '50% OFF',
      bgColor: Color(0xFF047857),
    ),
    Offer(
      id: 'o2',
      title: 'Midnight Munchies Rush',
      subtitle: 'Get free delivery on snacks above \$15',
      code: 'CRUNCHY',
      discountText: 'FREE DEL',
      bgColor: Color(0xFF7C3AED),
    ),
    Offer(
      id: 'o3',
      title: 'Dairy Fresh Morning',
      subtitle: 'Save 20% on fresh premium whole milk & buns',
      code: 'FRESH20',
      discountText: '20% OFF',
      bgColor: Color(0xFF2563EB),
    ),
  ];

  static const List<BannerItem> banners = [
    BannerItem(
      id: 'b1',
      title: 'Organic Produce Farm Fresh',
      subtitle: 'Guaranteed 10-Minute Delivery directly to your doorstep',
      code: 'FARM10',
      buttonText: 'Shop Fresh',
      imagePath: 'assets/images/eco_banner.jpg',
      bgColor: Color(0xFF0F5132),
    ),
    BannerItem(
      id: 'b2',
      title: 'Craving Late Night Munchies?',
      subtitle: 'Hot chips, sodas, and ice-creams delivered in 8 mins',
      code: 'CRAVE8',
      buttonText: 'Order Now',
      imagePath: '',
      bgColor: Color(0xFF51103F),
    ),
    BannerItem(
      id: 'b3',
      title: 'Pre-Cooked Gourmet Combos',
      subtitle: 'Saves 30% time & money. Healthy single portions',
      code: 'COMBO30',
      buttonText: 'Explore Combos',
      imagePath: '',
      bgColor: Color(0xFF0B3F54),
    ),
  ];

  static const List<Brand> brands = [
    Brand(
      id: 'br1',
      name: 'Organic Farms Co.',
      logoEmoji: '🚜',
      description: '100% Certified Organic growers',
      color: Color(0xFFE8F5E9),
    ),
    Brand(
      id: 'br2',
      name: 'DairyLand Premium',
      logoEmoji: '🐄',
      description: 'Fresh dairy products',
      color: Color(0xFFE3F2FD),
    ),
    Brand(
      id: 'br3',
      name: 'SnackOverload',
      logoEmoji: '🍟',
      description: 'Snacks & Chips',
      color: Color(0xFFFFF3E0),
    ),
    Brand(
      id: 'br4',
      name: 'Gourmet Kitchen',
      logoEmoji: '🍳',
      description: 'Ready to Eat',
      color: Color(0xFFFFEBEE),
    ),
  ];

  static const List<Collection> collections = [
    Collection(
      id: 'col1',
      title: 'Rainy Day Essentials',
      subtitle: 'Perfect for rainy days',
      productIds: [],
      emoji: '🌧️',
      color: Color(0xFFECEFF1),
    ),
    Collection(
      id: 'col2',
      title: 'High Protein Breakfast',
      subtitle: 'Healthy breakfast',
      productIds: [],
      emoji: '💪',
      color: Color(0xFFE8EAF6),
    ),
  ];

  static final List<Product> products = [];
}