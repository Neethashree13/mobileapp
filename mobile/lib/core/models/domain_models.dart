/// FlashCart AI Production Domain Models for Flutter Apps
import 'package:flutter/foundation.dart';
import 'base_model.dart';
import 'domain_enums.dart';

// ==========================================
// 1. AUTHENTICATION & USER MODELS
// ==========================================

@immutable
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;
  final DateTime issuedAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresInSeconds,
    required this.issuedAt,
  });

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresInSeconds': expiresInSeconds,
        'issuedAt': issuedAt.toIso8601String(),
      };

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
        accessToken: json['accessToken'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        tokenType: json['tokenType'] as String? ?? 'Bearer',
        expiresInSeconds: json['expiresInSeconds'] as int? ?? 3600,
        issuedAt: BaseDomainModel.parseDateTime(json['issuedAt']),
      );
}

@immutable
class Address extends BaseDomainModel {
  final String userId;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String contactName;
  final String contactPhone;

  const Address({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.userId,
    this.label = 'Home',
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.contactName,
    required this.contactPhone,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Address copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? userId,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? contactName,
    String? contactPhone,
  }) {
    return Address(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'userId': userId,
        'label': label,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
        'contactName': contactName,
        'contactPhone': contactPhone,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        userId: json['userId'] as String? ?? '',
        label: json['label'] as String? ?? 'Home',
        addressLine1: json['addressLine1'] as String? ?? '',
        addressLine2: json['addressLine2'] as String?,
        landmark: json['landmark'] as String?,
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        country: json['country'] as String? ?? 'India',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        isDefault: json['isDefault'] as bool? ?? false,
        contactName: json['contactName'] as String? ?? '',
        contactPhone: json['contactPhone'] as String? ?? '',
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('ID cannot be empty');
    if (addressLine1.isEmpty) errors.add('Address line 1 cannot be empty');
    if (city.isEmpty) errors.add('City cannot be empty');
    if (postalCode.isEmpty) errors.add('Postal code cannot be empty');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Address && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class User extends BaseDomainModel {
  final String email;
  final String phone;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final List<Address> addresses;
  final String? defaultAddressId;
  final String referralCode;

  const User({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
    this.isEmailVerified = true,
    this.isPhoneVerified = true,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.addresses = const [],
    this.defaultAddressId,
    required this.referralCode,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  String get fullName => '$firstName $lastName'.trim();

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? email,
    String? phone,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    List<Address>? addresses,
    String? defaultAddressId,
    String? referralCode,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'email': email,
        'phone': phone,
        'role': role.name,
        'isEmailVerified': isEmailVerified,
        'isPhoneVerified': isPhoneVerified,
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'defaultAddressId': defaultAddressId,
        'referralCode': referralCode,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: UserRole.values.firstWhere((r) => r.name == json['role'], orElse: () => UserRole.customer),
        isEmailVerified: json['isEmailVerified'] as bool? ?? true,
        isPhoneVerified: json['isPhoneVerified'] as bool? ?? true,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        addresses: (json['addresses'] as List<dynamic>?)?.map((a) => Address.fromJson(a as Map<String, dynamic>)).toList() ?? const [],
        defaultAddressId: json['defaultAddressId'] as String?,
        referralCode: json['referralCode'] as String? ?? '',
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('User ID cannot be empty');
    if (email.isEmpty || !email.contains('@')) errors.add('Invalid email format');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// 2. PRODUCT CATALOG MODELS
// ==========================================

@immutable
class Category extends BaseDomainModel {
  final String name;
  final String slug;
  final String icon;
  final String color;
  final String? description;
  final int displayOrder;

  const Category({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
    this.description,
    this.displayOrder = 1,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Category copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? name,
    String? slug,
    String? icon,
    String? color,
    String? description,
    int? displayOrder,
  }) {
    return Category(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'name': name,
        'slug': slug,
        'icon': icon,
        'color': color,
        'description': description,
        'displayOrder': displayOrder,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
        color: json['color'] as String? ?? '#10B981',
        description: json['description'] as String?,
        displayOrder: json['displayOrder'] as int? ?? 1,
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Category ID cannot be empty');
    if (name.isEmpty) errors.add('Category name cannot be empty');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Product extends BaseDomainModel {
  final String name;
  final String slug;
  final String description;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? originalPrice;
  final String unit;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final int calories;
  final double protein;
  final bool isOrganic;
  final bool isHealthy;
  final EcoScore ecoScore;
  final double carbonEmission;
  final int inventoryQuantity;
  final String? badge;
  final int deliveryTimeMins;
  final List<String> tags;

  const Product({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.name,
    required this.slug,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.imageUrl,
    this.rating = 4.5,
    this.reviewsCount = 100,
    this.calories = 50,
    this.protein = 1.0,
    this.isOrganic = false,
    this.isHealthy = true,
    this.ecoScore = EcoScore.a,
    this.carbonEmission = 0.2,
    this.inventoryQuantity = 100,
    this.badge,
    this.deliveryTimeMins = 10,
    this.tags = const [],
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Product copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? name,
    String? slug,
    String? description,
    String? categoryId,
    String? categoryName,
    double? price,
    double? originalPrice,
    String? unit,
    String? imageUrl,
    double? rating,
    int? reviewsCount,
    int? calories,
    double? protein,
    bool? isOrganic,
    bool? isHealthy,
    EcoScore? ecoScore,
    double? carbonEmission,
    int? inventoryQuantity,
    String? badge,
    int? deliveryTimeMins,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      isOrganic: isOrganic ?? this.isOrganic,
      isHealthy: isHealthy ?? this.isHealthy,
      ecoScore: ecoScore ?? this.ecoScore,
      carbonEmission: carbonEmission ?? this.carbonEmission,
      inventoryQuantity: inventoryQuantity ?? this.inventoryQuantity,
      badge: badge ?? this.badge,
      deliveryTimeMins: deliveryTimeMins ?? this.deliveryTimeMins,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'name': name,
        'slug': slug,
        'description': description,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'price': price,
        'originalPrice': originalPrice,
        'unit': unit,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'calories': calories,
        'protein': protein,
        'isOrganic': isOrganic,
        'isHealthy': isHealthy,
        'ecoScore': ecoScore.name.toUpperCase(),
        'carbonEmission': carbonEmission,
        'inventoryQuantity': inventoryQuantity,
        'badge': badge,
        'deliveryTimeMins': deliveryTimeMins,
        'tags': tags,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble(),
        unit: json['unit'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        reviewsCount: json['reviewsCount'] as int? ?? 100,
        calories: json['calories'] as int? ?? 50,
        protein: (json['protein'] as num?)?.toDouble() ?? 1.0,
        isOrganic: json['isOrganic'] as bool? ?? false,
        isHealthy: json['isHealthy'] as bool? ?? true,
        ecoScore: EcoScore.values.firstWhere((e) => e.name.toUpperCase() == (json['ecoScore'] as String? ?? 'A'), orElse: () => EcoScore.a),
        carbonEmission: (json['carbonEmission'] as num?)?.toDouble() ?? 0.2,
        inventoryQuantity: json['inventoryQuantity'] as int? ?? 100,
        badge: json['badge'] as String?,
        deliveryTimeMins: json['deliveryTimeMins'] as int? ?? 10,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Product ID cannot be empty');
    if (name.isEmpty) errors.add('Product name cannot be empty');
    if (price < 0) errors.add('Price cannot be negative');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// 3. CART & SHOPPING MODELS
// ==========================================

@immutable
class CartItem {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'product': product.toJson(),
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String? ?? '',
        productId: json['productId'] as String? ?? '',
        product: Product.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

@immutable
class Cart extends BaseDomainModel {
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String? appliedCouponCode;

  const Cart({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.userId,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.appliedCouponCode,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Cart copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    String? appliedCouponCode,
  }) {
    return Cart(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'userId': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discountAmount': discountAmount,
        'taxAmount': taxAmount,
        'totalAmount': totalAmount,
        'appliedCouponCode': appliedCouponCode,
      };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        userId: json['userId'] as String? ?? '',
        items: (json['items'] as List<dynamic>?)?.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList() ?? const [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        appliedCouponCode: json['appliedCouponCode'] as String?,
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Cart ID cannot be empty');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Cart && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// 4. ORDER & DELIVERY MODELS
// ==========================================

@immutable
class Order extends BaseDomainModel {
  final String orderNumber;
  final String userId;
  final String storeId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double tax;
  final double total;
  final OrderStatus status;
  final PaymentMethodType paymentMethod;
  final String deliveryAddress;
  final int trackingStep;
  final String estimatedDeliveryTime;

  const Order({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.orderNumber,
    required this.userId,
    required this.storeId,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.status = OrderStatus.placed,
    this.paymentMethod = PaymentMethodType.upi,
    required this.deliveryAddress,
    this.trackingStep = 1,
    required this.estimatedDeliveryTime,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Order copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? orderNumber,
    String? userId,
    String? storeId,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? tax,
    double? total,
    OrderStatus? status,
    PaymentMethodType? paymentMethod,
    String? deliveryAddress,
    int? trackingStep,
    String? estimatedDeliveryTime,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      trackingStep: trackingStep ?? this.trackingStep,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'orderNumber': orderNumber,
        'userId': userId,
        'storeId': storeId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'tax': tax,
        'total': total,
        'status': status.name,
        'paymentMethod': paymentMethod.name,
        'deliveryAddress': deliveryAddress,
        'trackingStep': trackingStep,
        'estimatedDeliveryTime': estimatedDeliveryTime,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        orderNumber: json['orderNumber'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        storeId: json['storeId'] as String? ?? '',
        items: (json['items'] as List<dynamic>?)?.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList() ?? const [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        status: OrderStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => OrderStatus.placed),
        paymentMethod: PaymentMethodType.values.firstWhere((m) => m.name == json['paymentMethod'], orElse: () => PaymentMethodType.upi),
        deliveryAddress: json['deliveryAddress'] as String? ?? '',
        trackingStep: json['trackingStep'] as int? ?? 1,
        estimatedDeliveryTime: json['estimatedDeliveryTime'] as String? ?? '10 mins',
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Order ID cannot be empty');
    if (orderNumber.isEmpty) errors.add('Order number cannot be empty');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Order && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// 5. WALLET & PAYMENTS
// ==========================================

@immutable
class Wallet extends BaseDomainModel {
  final String userId;
  final double balance;
  final String currency;
  final double cashbackEarned;

  const Wallet({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.userId,
    this.balance = 0.0,
    this.currency = 'INR',
    this.cashbackEarned = 0.0,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  Wallet copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? userId,
    double? balance,
    String? currency,
    double? cashbackEarned,
  }) {
    return Wallet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'userId': userId,
        'balance': balance,
        'currency': currency,
        'cashbackEarned': cashbackEarned,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        userId: json['userId'] as String? ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'INR',
        cashbackEarned: (json['cashbackEarned'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Wallet ID cannot be empty');
    if (balance < 0) errors.add('Wallet balance cannot be negative');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Wallet && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ==========================================
// 6. AI & PANTRY MODELS
// ==========================================

@immutable
class PantryItem extends BaseDomainModel {
  final String userId;
  final String name;
  final String category;
  final String quantity;
  final PantryStatus status;
  final DateTime? expiryDate;
  final bool autoReplenish;

  const PantryItem({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    this.status = PantryStatus.full,
    this.expiryDate,
    this.autoReplenish = false,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isDeleted: isDeleted,
          deletedAt: deletedAt,
        );

  PantryItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? userId,
    String? name,
    String? category,
    String? quantity,
    PantryStatus? status,
    DateTime? expiryDate,
    bool? autoReplenish,
  }) {
    return PantryItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      autoReplenish: autoReplenish ?? this.autoReplenish,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'userId': userId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'status': status.name,
        'expiryDate': expiryDate?.toIso8601String(),
        'autoReplenish': autoReplenish,
      };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        id: json['id'] as String? ?? '',
        createdAt: BaseDomainModel.parseDateTime(json['createdAt']),
        updatedAt: BaseDomainModel.parseDateTime(json['updatedAt']),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: json['deletedAt'] != null ? BaseDomainModel.parseDateTime(json['deletedAt']) : null,
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        quantity: json['quantity'] as String? ?? '',
        status: PantryStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => PantryStatus.full),
        expiryDate: json['expiryDate'] != null ? BaseDomainModel.parseDateTime(json['expiryDate']) : null,
        autoReplenish: json['autoReplenish'] as bool? ?? false,
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Pantry Item ID cannot be empty');
    if (name.isEmpty) errors.add('Name cannot be empty');
    return errors;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PantryItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
