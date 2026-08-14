# FlashCart AI - Shared Domain Model Layer Architecture

This document specifies the unified enterprise domain model architecture for FlashCart AI across:
- **Flutter Customer App** (`mobile/lib/`)
- **Flutter Delivery Partner App** (`mobile/lib/features/delivery_partner/`)
- **Store Manager App** (`mobile/lib/features/store_manager/`)
- **React Admin Panel** (`src/components/AdminPanel/`)
- **Node.js Backend Microservices** (`server/`)

---

## 📁 1. Folder Structure Overview

```text
FlashCart-AI/
├── src/                                  # Web / React & Node Backend Shared Types
│   ├── domain/                           # Central Enterprise Domain Layer
│   │   ├── enums.ts                      # Shared Domain Enums (UserRole, OrderStatus, etc.)
│   │   ├── types.ts                      # Base Domain Contracts & API Wrappers
│   │   ├── validators.ts                 # UUID, Email, Phone, and Model Validation Rules
│   │   ├── mockFactory.ts                # TypeScript Mock Data Factory
│   │   ├── index.ts                      # Barrel Export Entrypoint
│   │   └── models/                       # Entity Interfaces
│   │       ├── auth.ts                   # AuthToken, Session, AuthCredentials, AuthProvider
│   │       ├── user.ts                   # User, UserProfile, Address
│   │       ├── catalog.ts                # Product, ProductVariant, Brand, Category
│   │       ├── inventory.ts              # Inventory, Warehouse, Store, StoreManager
│   │       ├── shopping.ts               # Cart, CartItem, Wishlist, Coupon, Offer, Banner
│   │       ├── order.ts                  # Order, OrderItem, OrderStatusHistory, DeliveryPartner
│   │       ├── payment.ts                # Payment, Transaction, Wallet
│   │       ├── engagement.ts             # Notification, Review, Rating, SupportTicket, ChatMessage, Referral
│   │       ├── ai.ts                     # AIRecommendation, Recipe, BudgetPlan, NutritionInfo, PantryItem
│   │       └── subscription.ts           # Subscription, AnalyticsEvent, AnalyticsSummary
│   └── types.ts                          # App-wide Backward-Compatible Type Re-exports
│
└── mobile/lib/core/models/               # Flutter Mobile Apps Domain Layer
    ├── base_model.dart                   # Abstract Base Domain Entity with UUID & Soft Delete
    ├── domain_enums.dart                 # Dart Domain Enums
    ├── domain_models.dart                # Production Dart Data Models (copyWith, toJson, fromJson, ==)
    └── mock_data_factory.dart            # Dart Mock Data Generator
```

---

## 🗺️ 2. Entity Relationship Diagram (ERD)

```text
+-----------------------+           1:N           +-----------------------+
|         User          | ----------------------->|        Address        |
+-----------------------+                         +-----------------------+
| id: UUID              | 1:1                     | id: UUID              |
| email: String         | ------> UserProfile     | userId: UUID          |
| phone: String         | 1:1                     | geo: GeoLocation      |
| role: UserRole        | ------> Wallet          +-----------------------+
+-----------------------+ 1:1
     |                    ------> Cart
     | 1:N
     v
+-----------------------+           1:N           +-----------------------+
|         Order         | ----------------------->|       OrderItem       |
+-----------------------+                         +-----------------------+
| id: UUID              |                         | id: UUID              |
| orderNumber: String   |                         | productId: UUID       |
| userId: UUID          |                         | unitPrice: Double     |
| storeId: UUID         |                         +-----------------------+
| deliveryPartnerId     |
| status: OrderStatus   |           N:1           +-----------------------+
+-----------------------+ ----------------------->|    DeliveryPartner    |
     |                                            +-----------------------+
     | 1:N                                        | id: UUID              |
     v                                            | status: PartnerStatus |
+-----------------------+                         +-----------------------+
|  OrderStatusHistory   |
+-----------------------+
| id: UUID              |
| status: OrderStatus   |
| timestamp: ISOString  |
+-----------------------+

+-----------------------+           1:N           +-----------------------+
|       Category        | ----------------------->|        Product        |
+-----------------------+                         +-----------------------+
| id: UUID              |                         | id: UUID              |
| name: String          |                         | categoryId: UUID      |
| slug: String          |                         | brandId: UUID         |
+-----------------------+                         | price: Double         |
                                                  | ecoScore: EcoScore    |
+-----------------------+           1:N           +-----------------------+
|         Store         | ----------------------->|       Inventory       |
+-----------------------+                         +-----------------------+
| id: UUID              |                         | id: UUID              |
| warehouseId: UUID     |                         | productId: UUID       |
| managerId: UUID       |                         | quantityOnHand: Int   |
+-----------------------+                         +-----------------------+
```

---

## 2. Dependency Graph

```text
[ BaseDomainModel ]
  ├── Auth & User Layer (User, Address, AuthToken, Session)
  ├── Catalog & Inventory Layer (Category, Brand, Product, ProductVariant, Warehouse, Store, Inventory)
  ├── Shopping & Cart Layer (Cart, CartItem, Wishlist, Coupon, Offer, Banner)
  ├── Order & Delivery Layer (Order, OrderItem, OrderStatusHistory, DeliveryPartner)
  ├── Payment & Financials (Payment, Transaction, Wallet)
  ├── Engagement & Support (Notification, Review, Rating, SupportTicket, ChatMessage, Referral)
  ├── AI & Pantry Engine (AIRecommendation, Recipe, BudgetPlan, PantryItem, NutritionInfo, SearchHistory)
  └── Subscription & Analytics (Subscription, AnalyticsEvent, AnalyticsSummary)
```
