# FlashCart AI - Enterprise PostgreSQL 17 Database Architecture

**Version:** 1.0.0  
**Database Engine:** PostgreSQL 17  
**Architect:** Principal Database Architect  
**Scale Target:** 10 Million Registered Users | 100 Million Historical Orders | 1 Million Daily Active Users (DAU) | Sub-100ms Read Latency

---

## 📁 1. Folder Structure Overview

```text
FlashCart-AI/
└── database/
    ├── 01_extensions_and_enums.sql        # Extensions (uuid-ossp, pgcrypto, pg_trgm, btree_gist) & Custom Enums
    ├── 02_schema_auth_and_users.sql       # RBAC, User Profiles, Auth Tokens, Sessions, OTPs, Addresses
    ├── 03_schema_catalog_and_inventory.sql  # Categories, Brands, Products, Variants, Warehouses, Dark Stores, Stock
    ├── 04_schema_shopping_and_orders.sql   # Carts, Wishlists, Coupons, Partitioned Orders & Order Items
    ├── 05_schema_payments_and_wallets.sql  # Payments, Gateway Transactions, User Wallets & Wallet Ledgers
    ├── 06_schema_delivery_and_logistics.sql# Fleet Vehicles, Delivery Partners, Assignments, Partitioned GPS Tracking
    ├── 07_schema_ai_and_engagement.sql     # AI Engine (Search, Recipes, Budget, Pantry), Reviews, Support, Notifications
    ├── 08_schema_audit_and_analytics.sql   # Partitioned High-Throughput Analytics Events & Security Audit Logs
    ├── 09_indexes_views_procedures.sql     # Trigram Indexes, Analytical Views, Materialized Views & Stored Procedures
    ├── 10_partitioning_and_triggers.sql    # Updated-at Timestamps, Optimistic Lock Incrementing & Audit Triggers
    └── seed_data.sql                       # Enterprise Quick-Commerce Seed Data
```

---

## 🔄 2. Sequential Migration Execution Order

To respect foreign key constraints, dependencies, and extension requirements, migrations **MUST** be executed in exact numeric sequence:

```bash
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/01_extensions_and_enums.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/02_schema_auth_and_users.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/03_schema_catalog_and_inventory.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/04_schema_shopping_and_orders.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/05_schema_payments_and_wallets.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/06_schema_delivery_and_logistics.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/07_schema_ai_and_engagement.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/08_schema_audit_and_analytics.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/09_indexes_views_procedures.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/10_partitioning_and_triggers.sql
psql -h <POSTGRES_HOST> -U flashcart_admin -d flashcart_db -f database/seed_data.sql
```

---

## 🗺️ 3. Entity Relationship Diagram (ERD) & Schema Map

```text
+---------------------+         1:N         +---------------------+
|        Users        |-------------------->|      Addresses      |
+---------------------+                     +---------------------+
| id: UUID (PK)       |                     | id: UUID (PK)       |
| phone: VARCHAR      |--+                  | user_id: UUID (FK)  |
| role_id: UUID (FK)  |  | 1:1              | geo: (Lat, Lng)     |
+---------------------+  +----------------->+---------------------+
     |                   |                       ^
     | 1:N               | 1:1                   | 1:N
     v                   v                       |
+---------------------+ +---------------------+  |
|    User Sessions    | |       Wallets       |  |
+---------------------+ +---------------------+  |
| id: UUID (PK)       | | balance: DECIMAL    |  |
| user_id: UUID (FK)  | +---------------------+  |
+---------------------+                          |
     |                                           |
     | 1:N                                       |
     v                                           |
+---------------------+         1:N              |
|       Orders        |--------------------------+
+---------------------+
| id: UUID (PK)       |         1:N         +---------------------+
| user_id: UUID (FK)  |-------------------->|     Order Items     |
| dark_store_id (FK)  |                     +---------------------+
| status: ENUM        |                     | product_id: UUID    |
| total_amount        |                     | quantity: INT       |
+---------------------+                     +---------------------+
     |
     | 1:N
     v
+---------------------+         N:1         +---------------------+
| DeliveryAssignments |-------------------->|   DeliveryPartners  |
+---------------------+                     +---------------------+
| order_id: UUID      |                     | rating: DECIMAL     |
| partner_id: UUID    |                     | status: ENUM        |
+---------------------+                     +---------------------+
```

---

## 📊 4. Performance & Table Size Projections (At 100M Orders Scale)

| Table Name | Estimated Row Count | Avg Row Size | Total Storage (Raw Data) | Index Size Estimate | Partitioning Strategy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `users` | 10,000,000 | ~450 Bytes | ~4.5 GB | ~1.2 GB | B-tree Indexing |
| `orders` | 100,000,000 | ~600 Bytes | ~60 GB | ~18 GB | Range Partitioned by `created_at` (Monthly) |
| `order_items` | 350,000,000 | ~250 Bytes | ~87.5 GB | ~22 GB | Range Partitioned by `created_at` (Monthly) |
| `delivery_tracking` | 1,200,000,000 | ~120 Bytes | ~144 GB | ~35 GB | Range Partitioned by `recorded_at` (Monthly) |
| `analytics_events` | 2,500,000,000 | ~350 Bytes | ~875 GB | ~120 GB | Range Partitioned by `created_at` (Monthly) |
| `audit_logs` | 500,000,000 | ~500 Bytes | ~250 GB | ~40 GB | Range Partitioned by `created_at` (Monthly) |
| `product_stock` | 500,000 | ~180 Bytes | ~90 MB | ~25 MB | In-Memory Working Set (Hot B-Tree) |

---

## ⚡ 5. Future Scaling & High-Availability (HA) Strategy

1. **Sub-100ms Read Optimization:**
   - **GIN Trigram Indexing:** Product search queries run under 15ms using `pg_trgm` GIN indexes on `products(name)`.
   - **PgBouncer Connection Pooling:** Transaction-level connection pooling configured to support up to 20,000 concurrent client connections with 100 active PostgreSQL backend processes.

2. **Partition Maintenance & Lifecycle:**
   - Automated `pg_partman` or cron procedure runs monthly to detach and archive partitions older than 12 months to cold Google Cloud Storage bucket object storage.

3. **Replication & High Availability (HA):**
   - **Primary Write Node:** Synchronous commit enabled for financial ledgers (`payments`, `wallets`).
   - **Read Replicas:** 3 Read Replicas across multiple availability zones using Cloud SQL Read Replicas or Patroni with Streaming Replication.

4. **Security & Optimistic Locking:**
   - Every updated entity tracks row version (`version BIGINT DEFAULT 1`). Concurrent updates throw `STALE_DATA_EXCEPTION` if version mismatches, guarding against race conditions during high-demand quick commerce flash sales.
