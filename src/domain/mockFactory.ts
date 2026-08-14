/**
 * FlashCart AI Mock Data Factory
 * Provides pre-populated, validated model instances with UUIDs, timestamps,
 * soft-delete metadata, copyWith, and serialization test helpers.
 */

import {
  UserRole,
  AuthProviderType,
  OrderStatus,
  PaymentStatus,
  PaymentMethodType,
  TransactionType,
  CouponType,
  NotificationType,
  TicketStatus,
  TicketPriority,
  SubscriptionStatus,
  PantryStatus,
  DeliveryPartnerStatus,
  AIRecommendationType,
  EcoScore
} from './enums';

import {
  User,
  Address,
  Product,
  Category,
  Cart,
  Order,
  Wallet,
  Coupon,
  DeliveryPartner,
  AIRecommendation,
  PantryItem,
  Recipe,
  BudgetPlan,
  SupportTicket,
  Subscription,
  Banner,
  Offer
} from './models';

/**
 * Generate mock UUID v4 equivalent string
 */
export function generateMockUUID(prefix = 'id'): string {
  const randomHex = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  return `${prefix}-${randomHex()}${randomHex()}-${randomHex()}-4${randomHex().substring(1)}-8${randomHex().substring(1)}-${randomHex()}${randomHex()}${randomHex()}`;
}

export function currentISODate(): string {
  return new Date().toISOString();
}

/**
 * Mock Data Factory Generators
 */
export const MockDataFactory = {
  createMockAddress(overrides?: Partial<Address>): Address {
    const now = currentISODate();
    return {
      id: generateMockUUID('addr'),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      userId: generateMockUUID('usr'),
      label: 'Home',
      addressLine1: '42, Indiranagar 100ft Road',
      addressLine2: 'Near Metro Station',
      landmark: 'Above Coffee Day',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560038',
      country: 'India',
      geo: { lat: 12.9716, lng: 77.5946, addressString: 'Indiranagar, Bengaluru' },
      isDefault: true,
      contactName: 'Rahul Sharma',
      contactPhone: '+919876543210',
      ...overrides
    };
  },

  createMockUser(overrides?: Partial<User>): User {
    const now = currentISODate();
    const userId = generateMockUUID('usr');
    return {
      id: userId,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      email: 'rahul.sharma@flashcart.ai',
      phone: '+919876543210',
      role: UserRole.CUSTOMER,
      isEmailVerified: true,
      isPhoneVerified: true,
      profile: {
        id: generateMockUUID('prof'),
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        userId,
        firstName: 'Rahul',
        lastName: 'Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        dietaryPreferences: ['Organic', 'High Protein'],
        preferredLanguage: 'en'
      },
      addresses: [],
      referralCode: 'RAHUL100',
      ...overrides
    };
  },

  createMockProduct(overrides?: Partial<Product>): Product {
    const now = currentISODate();
    return {
      id: generateMockUUID('prod'),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      name: 'Organic Alphonso Mangoes',
      slug: 'organic-alphonso-mangoes',
      description: 'Handpicked, naturally ripened Ratnagiri Alphonso mangoes.',
      categoryId: generateMockUUID('cat'),
      categoryName: 'Fruits & Vegetables',
      price: 499,
      originalPrice: 599,
      unit: '1 kg (approx 3-4 pcs)',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
      rating: 4.8,
      reviewsCount: 320,
      calories: 60,
      protein: 0.8,
      isOrganic: true,
      isHealthy: true,
      ecoScore: EcoScore.A,
      carbonEmission: 0.2,
      inventoryQuantity: 50,
      badge: 'Best Seller',
      deliveryTimeMins: 10,
      variants: [],
      tags: ['fresh', 'organic', 'fruit', 'seasonal'],
      ...overrides
    };
  },

  createMockCategory(overrides?: Partial<Category>): Category {
    const now = currentISODate();
    return {
      id: generateMockUUID('cat'),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      name: 'Fruits & Vegetables',
      slug: 'fruits-vegetables',
      icon: 'Apple',
      color: '#10B981',
      description: 'Farm fresh organic fruits and fresh green vegetables.',
      displayOrder: 1,
      ...overrides
    };
  },

  createMockOrder(overrides?: Partial<Order>): Order {
    const now = currentISODate();
    const product = this.createMockProduct();
    return {
      id: generateMockUUID('ord'),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      orderNumber: 'FC-' + Math.floor(100000 + Math.random() * 900000),
      userId: generateMockUUID('usr'),
      storeId: generateMockUUID('str'),
      items: [
        {
          id: generateMockUUID('item'),
          productId: product.id,
          product,
          quantity: 2,
          unitPrice: product.price,
          totalPrice: product.price * 2
        }
      ],
      subtotal: 998,
      deliveryFee: 0,
      discount: 50,
      tax: 25,
      total: 973,
      status: OrderStatus.OUT_FOR_DELIVERY,
      paymentMethod: PaymentMethodType.UPI,
      paymentStatus: 'CAPTURED',
      deliveryAddress: '42, Indiranagar 100ft Road, Bengaluru',
      deliveryGeo: { lat: 12.9716, lng: 77.5946 },
      trackingStep: 4,
      estimatedDeliveryTime: '10 mins',
      statusHistory: [
        {
          id: generateMockUUID('hist'),
          orderId: 'ord-1',
          status: OrderStatus.PLACED,
          timestamp: now
        }
      ],
      ...overrides
    };
  },

  createMockAIRecommendation(overrides?: Partial<AIRecommendation>): AIRecommendation {
    const now = currentISODate();
    return {
      id: generateMockUUID('airec'),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      userId: generateMockUUID('usr'),
      type: AIRecommendationType.FRESH_REPLENISHMENT,
      title: 'Time to Restock Organic Milk',
      reasoning: 'Based on your 4-day consumption cycle, your pantry milk level is predicted LOW.',
      confidenceScore: 0.94,
      recommendedProducts: [this.createMockProduct({ name: 'Farm Fresh Organic Whole Milk', price: 68 })],
      actionLabel: '1-Tap Restock',
      ...overrides
    };
  }
};
