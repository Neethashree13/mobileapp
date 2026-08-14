/**
 * FlashCart AI Domain Enums
 * Shared across Customer, Rider, Store Manager, Admin, and Node.js Backend.
 */

export enum UserRole {
  CUSTOMER = 'CUSTOMER',
  RIDER = 'RIDER',
  STORE_MANAGER = 'STORE_MANAGER',
  ADMIN = 'ADMIN'
}

export enum AuthProviderType {
  EMAIL = 'EMAIL',
  PHONE = 'PHONE',
  GOOGLE = 'GOOGLE',
  APPLE = 'APPLE'
}

export enum OrderStatus {
  PENDING = 'PENDING',
  PLACED = 'PLACED',
  ACCEPTED = 'ACCEPTED',
  PACKING = 'PACKING',
  READY_FOR_PICKUP = 'READY_FOR_PICKUP',
  OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
  REFUNDED = 'REFUNDED'
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  AUTHORIZED = 'AUTHORIZED',
  CAPTURED = 'CAPTURED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED'
}

export enum PaymentMethodType {
  CREDIT_CARD = 'CREDIT_CARD',
  DEBIT_CARD = 'DEBIT_CARD',
  UPI = 'UPI',
  WALLET = 'WALLET',
  NET_BANKING = 'NET_BANKING',
  CASH_ON_DELIVERY = 'CASH_ON_DELIVERY'
}

export enum TransactionType {
  CREDIT = 'CREDIT',
  DEBIT = 'DEBIT',
  REFUND = 'REFUND',
  CASHBACK = 'CASHBACK',
  TOPUP = 'TOPUP'
}

export enum CouponType {
  PERCENTAGE = 'PERCENTAGE',
  FLAT_DISCOUNT = 'FLAT_DISCOUNT',
  FREE_DELIVERY = 'FREE_DELIVERY'
}

export enum NotificationType {
  ORDER_UPDATE = 'ORDER_UPDATE',
  PROMOTION = 'PROMOTION',
  AI_ALERT = 'AI_ALERT',
  WALLET_UPDATE = 'WALLET_UPDATE',
  SYSTEM = 'SYSTEM'
}

export enum TicketStatus {
  OPEN = 'OPEN',
  IN_PROGRESS = 'IN_PROGRESS',
  RESOLVED = 'RESOLVED',
  CLOSED = 'CLOSED'
}

export enum TicketPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

export enum SubscriptionStatus {
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  CANCELLED = 'CANCELLED',
  EXPIRED = 'EXPIRED'
}

export enum PantryStatus {
  FULL = 'FULL',
  LOW = 'LOW',
  EMPTY = 'EMPTY'
}

export enum DeliveryPartnerStatus {
  OFFLINE = 'OFFLINE',
  AVAILABLE = 'AVAILABLE',
  ON_TRIP = 'ON_TRIP',
  BUSY = 'BUSY'
}

export enum AIRecommendationType {
  FRESH_REPLENISHMENT = 'FRESH_REPLENISHMENT',
  RECIPE_MATCH = 'RECIPE_MATCH',
  BUDGET_SAVER = 'BUDGET_SAVER',
  NUTRITION_BOOST = 'NUTRITION_BOOST'
}

export enum EcoScore {
  A = 'A',
  B = 'B',
  C = 'C',
  D = 'D'
}
