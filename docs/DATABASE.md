# FlashCart AI - Database Documentation

FlashCart AI relies on a relational model implemented on **PostgreSQL**. This ensures ACID transactions, rich querying capabilities for geo-locations, and absolute data integrity.

---

## 1. Database Specifications

* **Engine**: PostgreSQL (v14+)
* **Geo-Tracking Engine**: Standard Lat/Lng float coordinates with continuous bearing vectors.
* **ORM Recommendation**: Drizzle ORM or TypeORM for seamless migrations.

---

## 2. Schema Structure & Table Definitions

The schema is defined in `/docs/SCHEMA.sql` and is normalized into 6 primary relational tables:

### A. `products`
Stores the complete grocery and wellness catalog.
* `id` (VARCHAR(50), Primary Key)
* `name` (VARCHAR(100), NOT NULL)
* `category` (VARCHAR(50), NOT NULL)
* `price` (INTEGER, NOT NULL): Represented in minor currency units (Paise / Cents) to eliminate floating-point calculation errors.
* `unit` (VARCHAR(50))
* `image_url` (TEXT)
* `rating` (DECIMAL(3,2))
* `reviews_count` (INTEGER)
* `calories` (INTEGER)
* `protein` (DECIMAL(4,1))
* `is_organic` (BOOLEAN)
* `is_healthy` (BOOLEAN)
* `eco_score` (CHAR(1))
* `carbon_emission` (DECIMAL(4,2))
* `inventory` (INTEGER)
* `delivery_time_mins` (INTEGER)
* `original_price` (INTEGER)
* `description` (TEXT)

### B. `users`
Tracks shopper accounts, wallets, and retention metrics.
* `id` (SERIAL, Primary Key)
* `firebase_uid` (VARCHAR(128), Unique)
* `email` (VARCHAR(100), Unique)
* `first_name` (VARCHAR(50))
* `last_name` (VARCHAR(50))
* `phone_number` (VARCHAR(15))
* `wallet_balance` (INTEGER): Represented in minor units.
* `streak_count` (INTEGER, Default 0)

### C. `addresses`
Supports multiple addresses per user.
* `id` (SERIAL, Primary Key)
* `user_id` (INTEGER, Foreign Key referencing `users(id)`)
* `title` (VARCHAR(50)): e.g., 'Home', 'Work'
* `address_line1` (TEXT, NOT NULL)
* `address_line2` (TEXT)
* `landmark` (VARCHAR(100))
* `city` (VARCHAR(50))
* `state` (VARCHAR(50))
* `postal_code` (VARCHAR(10))
* `latitude` (DECIMAL(9,6))
* `longitude` (DECIMAL(9,6))
* `is_default` (BOOLEAN, Default false)

### D. `orders`
Stores transactional metadata and payment statuses.
* `id` (VARCHAR(50), Primary Key)
* `user_id` (INTEGER, Foreign Key referencing `users(id)`)
* `subtotal` (INTEGER, NOT NULL)
* `delivery_fee` (INTEGER, NOT NULL)
* `discount` (INTEGER, Default 0)
* `total` (INTEGER, NOT NULL)
* `status` (VARCHAR(30)): 'placed', 'accepted', 'packing', 'out_for_delivery', 'delivered'
* `created_at` (TIMESTAMP, Default NOW())
* `delivery_address` (TEXT, NOT NULL)
* `payment_method` (VARCHAR(50))
* `tracking_step` (INTEGER, Default 1)
* `estimated_delivery_time` (VARCHAR(20))

### E. `order_items`
Tracks individual line items of purchased orders.
* `id` (SERIAL, Primary Key)
* `order_id` (VARCHAR(50), Foreign Key referencing `orders(id)`)
* `product_id` (VARCHAR(50), Foreign Key referencing `products(id)`)
* `quantity` (INTEGER, NOT NULL)
* `price_at_purchase` (INTEGER, NOT NULL)

### F. `rider_locations`
Live geo-tracking streams.
* `rider_id` (VARCHAR(50), Primary Key)
* `name` (VARCHAR(100))
* `phone` (VARCHAR(15))
* `avatar_url` (TEXT)
* `latitude` (DECIMAL(9,6))
* `longitude` (DECIMAL(9,6))
* `bearing` (DECIMAL(5,2))
* `status` (VARCHAR(30))
* `rating` (DECIMAL(3,2))

---

## 3. Relationships

* **One-to-Many**: `users` → `addresses` (A user can have multiple saved delivery addresses)
* **One-to-Many**: `users` → `orders` (A user can place multiple grocery orders)
* **One-to-Many**: `orders` → `order_items` (An order contains multiple products with purchased volumes)
* **One-to-One**: `order_items` → `products` (Each line item references exactly one product catalog entry)

---

## 4. Connecting a New Database

To point the backend to a fresh PostgreSQL instance:
1. Update your backend `.env` file with the connection parameters:
   ```env
   PGHOST=your-new-db-host.gcp.com
   PGPORT=5432
   PGDATABASE=flashcart_db
   PGUSER=postgres_admin
   PGPASSWORD=super_secure_password
   ```
2. The core initialization pool in `backend/src/config/db.ts` will connect natively:
   ```typescript
   import pg from 'pg';
   const pool = new pg.Pool({
     host: process.env.PGHOST,
     port: parseInt(process.env.PGPORT || '5432'),
     database: process.env.PGDATABASE,
     user: process.env.PGUSER,
     password: process.env.PGPASSWORD,
     ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
   });
   ```
