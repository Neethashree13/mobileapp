class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double? originalPrice;
  final String unit;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final int calories;
  final double proteinG;
  final bool isOrganic;
  final bool isHealthy;
  final String ecoScore;
  final double carbonEmissionKg;
  final int inventoryCount;
  final int deliveryTimeMins;
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.calories,
    required this.proteinG,
    required this.isOrganic,
    required this.isHealthy,
    required this.ecoScore,
    required this.carbonEmissionKg,
    required this.inventoryCount,
    required this.deliveryTimeMins,
    this.description,
  });

 factory ProductModel.fromJson(Map<String, dynamic> json) {
  return ProductModel(
    id: json['id'] ?? '',

    name: json['name'] ?? '',

    categoryId:
        json['category'] ?? '',

    price:
        double.tryParse(
          json['price'].toString(),
        ) ??
        0.0,

    originalPrice:
        json['originalPrice'] != null
            ? double.tryParse(
                json['originalPrice'].toString(),
              )
            : null,

    unit:
        json['unit'] ?? '',


    imageUrl:
        json['image'] ?? '',


    rating:
        double.tryParse(
          json['rating'].toString(),
        ) ??
        0.0,


    reviewsCount:
        json['reviewsCount'] ?? 0,


    calories:
        json['calories'] ?? 0,


    proteinG:
        double.tryParse(
          json['protein'].toString(),
        ) ??
        0.0,


    isOrganic:
        json['isOrganic'] ?? false,


    isHealthy:
        json['isHealthy'] ?? false,


    ecoScore:
        json['ecoScore'] ?? 'C',


    carbonEmissionKg:
        double.tryParse(
          json['carbonEmission'].toString(),
        ) ??
        0.0,


    inventoryCount:
        json['inventory'] ?? 0,


    deliveryTimeMins:
        json['deliveryTimeMins'] ?? 0,


    description:
        json['description'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'original_price': originalPrice,
      'unit': unit,
      'image_url': imageUrl,
      'rating': rating,
      'reviews_count': reviewsCount,
      'calories': calories,
      'protein_g': proteinG,
      'is_organic': isOrganic,
      'is_healthy': isHealthy,
      'eco_score': ecoScore,
      'carbon_emission_kg': carbonEmissionKg,
      'inventory_count': inventoryCount,
      'delivery_time_mins': deliveryTimeMins,
      'description': description,
    };
  }
}
