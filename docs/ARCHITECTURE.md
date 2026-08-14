# FlashCart AI - High-Performance Production Architecture Design

This document details the production-ready architecture of the next-generation quick commerce mobile application, **FlashCart AI**. Designed for sub-10 minute hyper-local deliveries, it incorporates AI-driven shopping, computer vision pantry tracking, and sustainable micro-logistics.

---

## 1. System Technology Stack

The production architecture is divided into three key boundaries: Client Apps (Flutter), Backend Services (Express / NestJS on Node.js + TypeScript), and Infrastructure Layers (PostgreSQL, Redis, Firebase, Socket.IO, Gemini).

```
   ┌────────────────────────────────────────────────────────┐
   │                  CLIENT LAYER (Flutter)                │
   │    ┌─────────────────────────┐ ┌──────────────────┐    │
   │    │  Customer App (iOS/And) │ │  Rider App (iOS) │    │
   │    └─────────────────────────┘ └──────────────────┘    │
   └───────────────────────────┬───────────────▲────────────┘
                      REST API │               │ WebSockets / Socket.io
                      HTTPS    │               │ (Live Coordinates, State Sync)
                               ▼               │
   ┌───────────────────────────────────────────┴────────────┐
   │                    API BACKEND LAYER                   │
   │  ┌──────────────────────────────────────────────────┐  │
   │  │   TypeScript Express / NestJS Core Microservices │  │
   │  │                                                  │  │
   │  │  • Auth Middleware (Firebase Admin JWT)          │  │
   │  │  • Controller Routers (Users, Orders, Cart, etc) │  │
   │  │  • Gemini AI Services (Assistant, Scanner)       │  │
   │  │  • Push Notification Engine (FCM Broker)         │  │
   │  └───────────┬───────────────┬────────────────┬─────┘  │
   └──────────────┼───────────────┼────────────────┼────────┘
                  │               │                │
                  ▼ pg_pool       ▼ redis_client   ▼ https / grpc
   ┌──────────────────────┐ ┌─────────────┐ ┌─────────────────────┐
   │  POSTGRESQL DATABASE │ │ REDIS CACHE │ │ GOOGLE CLOUD SUITE  │
   │  • Normalized Rel.   │ │ • Sess State│ │ • Gemini AI (Flash) │
   │  • Index Optimized   │ │ • Geo-Cache │ │ • Firebase Auth     │
   │  • Strict Triggers   │ │ • Rate-Limit│ │ • Firebase FCM      │
   └──────────────────────┘ └─────────────┘ └─────────────────────┘
```

### Infrastructure Components & Roles:
1. **Flutter Mobile SDK**: Powers both client applications (Customer and Rider) using a single cross-platform Dart codebase, configured with Clean Architecture, MVVM (Model-View-ViewModel), and Riverpod or BLoC state management.
2. **Node.js API Services**: Written in TypeScript using Express (or NestJS), handling core business rules, payments, ordering workflows, and routing proxy.
3. **PostgreSQL Database**: Provides reliable, relational ACID-compliant data storage for transactions, orders, inventory, catalog items, and profile schemas.
4. **Redis Cache Layer**: Used for sub-millisecond lookups of heavy product catalogs, geo-spatial rider tracking updates, active session caching, and API rate-limiting.
5. **Firebase Auth & FCM**: 
   - **Authentication**: JWT-based identity tokens generated securely on-device and validated server-side by the Firebase Admin SDK.
   - **Push Notifications (FCM)**: Immediate transactional alerts (e.g., "Rider has arrived", "Order accepted") dispatched from the background workers.
6. **Socket.IO (WebSockets)**: Operates bi-directional state synchronization channels to coordinate rider GPS routes, live map movements, and collaborative cart additions in real-time.
7. **Gemini AI Developer Engine**: Connects via the `@google/genai` TypeScript SDK to evaluate visual screenshots of pantries, build hyper-personalized nutrition plans, and perform natural language semantic queries on the localized store catalog.

---

## 2. Directory Structure Blueprint

To organize this robust enterprise-scale architecture cleanly, we establish the following folder structure:

```
├── /docs                    # Architecture, Database, and REST Specs
│   ├── ARCHITECTURE.md      # System design and cache structures
│   ├── SCHEMA.sql           # Production PostgreSQL relational schema
│   └── API_DOCUMENTATION.md # OpenAPI style REST contract specs
│
├── /shared                  # Code structures shared between layers
│   └── types.ts             # Direct TypeScript Interfaces and models
│
├── /backend                 # Node.js TypeScript API Codebase
│   ├── package.json         # Server dependency manifest
│   ├── tsconfig.json        # TypeScript configuration rules
│   ├── /src
│   │   ├── app.ts           # Core entry point (Express, Server, Socket.IO)
│   │   ├── /config          # System configs (Firebase Admin, pg-pool, Redis)
│   │   ├── /controllers     # Route controller endpoints (Cart, Orders, etc)
│   │   ├── /services        # Pure business logic and AI catalog mapping
│   │   ├── /middleware      # Verification, Auth, validation schemas
│   │   └── /db              # Drizzle schema ORM mappings & seed scripts
│
└── /mobile                  # Multiplatform Flutter Dart App
    ├── pubspec.yaml         # Dart dependencies configuration
    └── /lib
        ├── main.dart        # Client startup script and Provider definitions
        ├── /core            # Common constants, network clients, routers
        ├── /features        # Domain, Data, Presentation layers (Clean Arch)
        │   ├── /customer    # Customer-facing shopping, AI planners
        │   └── /rider       # Delivery-partner tracking, delivery logs
```

---

## 3. Core Data Sync & Live Coordinates Flow

The sequence diagram below displays how an order transition initiates WebSocket coordinate streams and sends transaction push alerts synchronously:

```
  Customer App             Backend API Server              Rider App
       │                           │                           │
       │─── (1) Place Order ──────>│                           │
       │    (HTTP POST)            │                           │
       │                           │── (2) Dispatch Rider ────>│
       │                           │    (Firebase FCM Alert)   │
       │                           │                           │
       │                           │<── (3) Accept Delivery ───│
       │                           │    (WebSocket Connect)    │
       │                           │                           │
       │<── (4) Dispatch Info ─────│                           │
       │    (Socket.IO Sub)        │                           │
       │                           │<── (5) Push GPS Coords ───│
       │                           │    (WebSocket Stream)     │
       │<── (6) Broadcast Coords ──│                           │
       │    (Real-time Map Move)   │                           │
       │                           │                           │
       │                           │── (7) At Location ───────>│
       │                           │    (Trigger Near-Notif)   │
       │<── (8) Push: Near ────────│                           │
       │    (FCM background toast) │                           │
       ▼                           ▼                           ▼
```

---

## 4. Redis Caching Strategy

To support ultra-fast sub-second render times, Redis caches are placed ahead of the primary PostgreSQL database for three specific reads:

1. **Category & Product Catalog (TTL: 1 Hour)**: 
   - On catalog query: Cache is read first. If a cache miss occurs, SQL is queried, results are saved back to Redis under the key `catalog:category:<id>` or `catalog:product:<id>`, and returned.
   - On inventory modification or administrative updates: The specific redis keys are invalidated instantly.
2. **Rider Live Spatial Coordinates (TTL: 10 Seconds)**:
   - High-frequency GPS pings from the Rider app are captured via WebSocket, pushed straight to Redis `rider:active:coords:<rider_id>` as geographical hashes (`GEOADD`), and flushed to PostgreSQL only when the status changes to `delivered`.
3. **Discount Coupon Codes (TTL: 1 Day)**:
   - Available promotional codes and structures are kept in memory under `coupon:list` for extremely fast checkout deductions.

---

## 5. Security & Verification Policy

1. **Identity Safeguard**: All endpoints located on `/api/*` (except general product/category lookups) mandate authorization header matching `Bearer <Firebase_ID_Token>`.
2. **Server-Side Token Validation**:
   - Client sends token -> Express validates using Firebase Admin `adminAuth.verifyIdToken(token)`.
   - Verified metadata is extracted (UID, Email), synchronized with the PostgreSQL `users` table via upsert operations, and passed to local controller functions.
3. **Secure Gemini Integration**: Raw model API keys are isolated server-side. Prompt injection vectors are managed using explicit JSON Output Schemas and type-checking.
