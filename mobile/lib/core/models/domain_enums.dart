/// FlashCart AI Domain Enums for Flutter App
library domain_enums;

enum UserRole {
  customer,
  rider,
  storeManager,
  admin,
}

enum AuthProviderType {
  email,
  phone,
  google,
  apple,
}

enum OrderStatus {
  pending,
  placed,
  accepted,
  packing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  authorized,
  captured,
  failed,
  refunded,
}

enum PaymentMethodType {
  creditCard,
  debitCard,
  upi,
  wallet,
  netBanking,
  cashOnDelivery,
}

enum TransactionType {
  credit,
  debit,
  refund,
  cashback,
  topup,
}

enum CouponType {
  percentage,
  flatDiscount,
  freeDelivery,
}

enum NotificationType {
  orderUpdate,
  promotion,
  aiAlert,
  walletUpdate,
  system,
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

enum SubscriptionStatus {
  active,
  paused,
  cancelled,
  expired,
}

enum PantryStatus {
  full,
  low,
  empty,
}

enum DeliveryPartnerStatus {
  offline,
  available,
  onTrip,
  busy,
}

enum AIRecommendationType {
  freshReplenishment,
  recipeMatch,
  budgetSaver,
  nutritionBoost,
}

enum EcoScore {
  a,
  b,
  c,
  d,
}
