/// FlashCart AI Dart Mock Data Factory
import 'domain_enums.dart';
import 'domain_models.dart';

class DartMockDataFactory {
  static String generateId([String prefix = 'id']) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return '$prefix-$now';
  }

  static User createMockUser({String? id, String? email, String? name}) {
    final now = DateTime.now();
    return User(
      id: id ?? generateId('usr'),
      createdAt: now,
      updatedAt: now,
      email: email ?? 'rahul.sharma@flashcart.ai',
      phone: '+919876543210',
      firstName: name ?? 'Rahul',
      lastName: 'Sharma',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      referralCode: 'RAHUL100',
    );
  }

  static Product createMockProduct({String? id, String? name, double? price}) {
    final now = DateTime.now();
    return Product(
      id: id ?? generateId('prod'),
      createdAt: now,
      updatedAt: now,
      name: name ?? 'Organic Alphonso Mangoes',
      slug: 'organic-alphonso-mangoes',
      description: 'Farm fresh Ratnagiri mangoes.',
      categoryId: 'cat-1',
      categoryName: 'Fruits & Vegetables',
      price: price ?? 499.0,
      unit: '1 kg',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
    );
  }

  static Order createMockOrder({String? id, double? total}) {
    final now = DateTime.now();
    final product = createMockProduct();
    return Order(
      id: id ?? generateId('ord'),
      createdAt: now,
      updatedAt: now,
      orderNumber: 'FC-102938',
      userId: 'usr-1',
      storeId: 'str-1',
      items: [
        CartItem(
          id: 'item-1',
          productId: product.id,
          product: product,
          quantity: 2,
          unitPrice: product.price,
          totalPrice: product.price * 2,
        )
      ],
      subtotal: 998.0,
      total: total ?? 973.0,
      deliveryAddress: '42, Indiranagar 100ft Road, Bengaluru',
      estimatedDeliveryTime: '10 mins',
    );
  }
}
