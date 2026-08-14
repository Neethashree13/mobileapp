import 'package:flashcart_ai/features/home/models/home_models.dart';

class WishlistResponseModel {
  final List<String> wishlist;
  final List<Product> items;

  const WishlistResponseModel({
    required this.wishlist,
    required this.items,
  });

  factory WishlistResponseModel.fromJson(Map<String, dynamic> json) {
    final wishlistIds = (json['wishlist'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return WishlistResponseModel(
      wishlist: wishlistIds,
      items: itemsList,
    );
  }
}
