// import pg from "pg";
// import path from "path";
// import fs from "fs";
// import { isProduction } from "./env";
// import { DB_STATE } from "./dbState";

// const dbConfig = {
//   host: process.env.PGHOST || process.env.SQL_HOST || 'localhost',
//   user: process.env.PGUSER || process.env.SQL_USER || 'postgres',
//   password: process.env.PGPASSWORD || process.env.SQL_PASSWORD || 'password',
//   database: process.env.PGDATABASE || process.env.SQL_DB_NAME || 'flashcart_db',
//   port: parseInt(process.env.PGPORT || process.env.SQL_PORT || '5432', 10),
//   max: 10,
//   idleTimeoutMillis: 30000,
//   connectionTimeoutMillis: 5000,
// };

// export let dbPool: any = null;
// export let usePostgreSQL = false;

// try {
//   const pgModule: any = pg || {};
//   const PoolClass = pgModule.Pool || (pgModule.default ? pgModule.default.Pool : undefined);
//   if (PoolClass) {
//     dbPool = new PoolClass(dbConfig);
//     dbPool.on('error', (err: any) => {
//       console.warn('Unexpected database pool error on idle client:', err);
//     });
//   } else {
//     console.warn("⚠️ Pool class is undefined on pg import.");
//   }
// } catch (err) {
//   console.warn("⚠️ Could not instantiate PostgreSQL Pool:", err);
// }

// // Resilient query helper
// export async function dbQuery(text: string, params?: any[]) {
//   if (dbPool && usePostgreSQL) {
//     try {
//       return await dbPool.query(text, params);
//     } catch (err: any) {
//       console.error("PostgreSQL Query Error:", err);
//       throw err;
//     }
//   }
  
//   if (isProduction) {
//     throw new Error("PostgreSQL is not active or connected in production!");
//   }
//   throw new Error("PostgreSQL is not active or connected");
// }

// // Activity logger helper
// export async function logActivity(userId: string | null, actionType: string, details: string) {
//   console.log(`[ACTIVITY LOG] User: ${userId || 'Anonymous'}, Action: ${actionType}, Details: ${details}`);
//   if (dbPool && usePostgreSQL) {
//     try {
//       let actualUserId = userId;
//       if (userId && userId.startsWith('FBAUTH_UID')) {
//         const userRes = await dbPool.query("SELECT id FROM users WHERE firebase_uid = $1", [userId]);
//         if (userRes.rows.length > 0) {
//           actualUserId = userRes.rows[0].id;
//         } else {
//           actualUserId = null;
//         }
//       } else if (userId && userId === 'u1') {
//         actualUserId = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
//       }
//       await dbPool.query(
//         "INSERT INTO activity_logs (user_id, action_type, details) VALUES ($1, $2, $3)",
//         [actualUserId, actionType, details]
//       );
//     } catch (err) {
//       console.warn("Could not log activity in database:", err);
//     }
//   }
// }

// export async function bootstrapDb() {
//   if (!dbPool) return;
//   try {
//     const client = await dbPool.connect();
//     try {
//       const checkRes = await client.query(`
//         SELECT EXISTS (
//           SELECT FROM information_schema.tables 
//           WHERE table_schema = 'public' 
//           AND table_name = 'users'
//         );
//       `);
//       if (!checkRes.rows[0].exists) {
//         console.log("PostgreSQL tables missing, auto-bootstrapping SCHEMA.sql...");
//         const schemaPath = path.join(process.cwd(), 'docs', 'SCHEMA.sql');
//         if (fs.existsSync(schemaPath)) {
//           const schemaSql = fs.readFileSync(schemaPath, 'utf8');
//           try {
//             await client.query(schemaSql);
//             console.log("SCHEMA.sql auto-bootstrapped successfully!");
//           } catch (schemaErr: any) {
//             console.warn("Error running complete SCHEMA.sql directly, trying without extension:", schemaErr);
//             const cleanSql = schemaSql.replace(/CREATE EXTENSION IF NOT EXISTS "uuid-ossp";/gi, "");
//             await client.query(cleanSql);
//             console.log("SCHEMA.sql auto-bootstrapped (without extension) successfully!");
//           }

//           // Seed categories if empty
//           const catCheck = await client.query("SELECT COUNT(*) FROM categories");
//           if (parseInt(catCheck.rows[0].count) === 0) {
//             console.log("Seeding default categories...");
//             await client.query(`
//               INSERT INTO categories (id, name, icon_name, color_hex, is_active, sort_order) VALUES
//               ('veggies', 'Fresh Vegetables', 'Utensils', '#4ADE80', true, 1),
//               ('dairy', 'Dairy & Milk', 'ShoppingBag', '#60A5FA', true, 2),
//               ('bakery', 'Bakery & Bread', 'Sparkles', '#FBBF24', true, 3),
//               ('snacks', 'Munchies & Snacks', 'Smile', '#F87171', true, 4),
//               ('beverages', 'Cold Beverages', 'Flame', '#A78BFA', true, 5),
//               ('pantry', 'Kitchen Pantry', 'Activity', '#FB7185', true, 6),
//               ('medicine', 'Pharmacy & Wellness', 'Zap', '#2DD4BF', true, 7),
//               ('baby', 'Baby Care Essentials', 'Heart', '#34D399', true, 8)
//               ON CONFLICT DO NOTHING;
//             `);
//           }

//           // Seed products if empty
//           const prodCheck = await client.query("SELECT COUNT(*) FROM products");
//           if (parseInt(prodCheck.rows[0].count) === 0) {
//             console.log("Seeding default products...");
//             for (const prod of DB_STATE.products) {
//               await client.query(`
//                 INSERT INTO products (id, name, category_id, price, original_price, unit, image_url, rating, reviews_count, calories, protein_g, is_organic, is_healthy, eco_score, carbon_emission_kg, inventory_count, delivery_time_mins, description)
//                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
//                 ON CONFLICT DO NOTHING;
//               `, [
//                 prod.id, prod.name, prod.category, prod.price, prod.originalPrice || null, prod.unit, prod.image,
//                 prod.rating, prod.reviewsCount, prod.calories, prod.protein, prod.isOrganic || false,
//                 prod.isHealthy || false, prod.ecoScore, prod.carbonEmission, prod.inventory, prod.deliveryTimeMins,
//                 prod.description || ''
//               ]);
//             }
//           }

//           // Seed default user if empty
//           // const userCheck = await client.query("SELECT COUNT(*) FROM users");
//           // if (parseInt(userCheck.rows[0].count) === 0) {
//           //   console.log("Seeding default user...");
//           //   await client.query(`
//           //     INSERT INTO users (id, firebase_uid, email, first_name, last_name, phone_number, wallet_balance, streak_count)
//           //     VALUES ('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'FBAUTH_UID_9921', 'arav@example.com', 'Arav', 'Sharma', '+91 98765 43210', 1200.00, 5)
//           //     ON CONFLICT DO NOTHING;
//           //   `);
//           // }

//           // Seed default addresses if empty
//           const addrCheck = await client.query("SELECT COUNT(*) FROM addresses");
//           if (parseInt(addrCheck.rows[0].count) === 0) {
//             console.log("Seeding default address...");
//             await client.query(`
//               INSERT INTO addresses (user_id, title, address_line_1, address_line_2, landmark, city, state, postal_code, latitude, longitude, is_default)
//               VALUES ('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'Home', 'Symphony Premium Apts', 'Koramangala 3rd Block', 'Near Sony Signal', 'Bangalore', 'Karnataka', '560034', 12.9279, 77.6250, true)
//               ON CONFLICT DO NOTHING;
//             `);
//           }

//           // Seed default coupons if empty
//           const couponCheck = await client.query("SELECT COUNT(*) FROM coupons");
//           if (parseInt(couponCheck.rows[0].count) === 0) {
//             console.log("Seeding default coupons...");
//             await client.query(`
//               INSERT INTO coupons (code, discount_type, discount_value, max_discount, min_order_value, expires_at, is_active)
//               VALUES ('FLASH50', 'flat_rate', 50.00, 50.00, 300.00, CURRENT_TIMESTAMP + INTERVAL '30 days', true)
//               ON CONFLICT DO NOTHING;
//             `);
//           }
//         }
//       } else {
//         console.log("PostgreSQL database tables already present.");
//       }

//       // Ensure profile_photo and last_login columns exist on users table, plus Module 1 Auth additions
//       console.log("Upgrading users schema for Module 1 Auth...");
//       await client.query(`
//         ALTER TABLE users ALTER COLUMN firebase_uid DROP NOT NULL;
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image TEXT;
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_photo TEXT;
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(20);
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
//         ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
//       `);

//       // Enforce default values for nullable columns that should be non-nullable going forward
//       await client.query(`
//         UPDATE users SET is_verified = false WHERE is_verified IS NULL;
//         UPDATE users SET is_active = true WHERE is_active IS NULL;
//         ALTER TABLE users ALTER COLUMN is_verified SET NOT NULL;
//         ALTER TABLE users ALTER COLUMN is_active SET NOT NULL;
//       `);

//       // Ensure index constraints exist
//       await client.query(`
//         CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
//         CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
//       `);

//       // Upgrade addresses table with modular fields
//       console.log("Upgrading addresses schema for Module 1...");
//       await client.query(`
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS house_no VARCHAR(100);
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS apartment VARCHAR(100);
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS street VARCHAR(255);
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS country VARCHAR(100) DEFAULT 'India';
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS pincode VARCHAR(20);
//         ALTER TABLE addresses ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20);
//         ALTER TABLE addresses ALTER COLUMN address_line_1 DROP NOT NULL;
//       `);

//       // Ensure core Auth modules' auxiliary tables exist
//       console.log("Ensuring auth auxiliary tables exist (otp_verifications, user_sessions, referrals)...");
//       await client.query(`
//         CREATE TABLE IF NOT EXISTS otp_verifications (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             phone VARCHAR(20) NOT NULL,
//             otp VARCHAR(6) NOT NULL,
//             expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
//             verified BOOLEAN DEFAULT false NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_otp_verifications_phone ON otp_verifications(phone);

//         CREATE TABLE IF NOT EXISTS user_sessions (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
//             device_id VARCHAR(255),
//             device_name VARCHAR(255),
//             firebase_token TEXT,
//             refresh_token TEXT,
//             ip_address VARCHAR(45),
//             login_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             logout_time TIMESTAMP WITH TIME ZONE
//         );
//         CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
//         CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh_token ON user_sessions(refresh_token);

//         CREATE TABLE IF NOT EXISTS referrals (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
//             referral_code VARCHAR(50) UNIQUE NOT NULL,
//             referred_by UUID REFERENCES users(id) ON DELETE SET NULL,
//             reward_points INT DEFAULT 0 CHECK (reward_points >= 0) NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_referrals_user_id ON referrals(user_id);
//         CREATE INDEX IF NOT EXISTS idx_referrals_code ON referrals(referral_code);

//         -- Module 3 Tables
//         CREATE TABLE IF NOT EXISTS subcategories (
//             id VARCHAR(50) PRIMARY KEY,
//             category_id VARCHAR(50) REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
//             name VARCHAR(100) NOT NULL,
//             slug VARCHAR(100) NOT NULL,
//             image_url TEXT,
//             is_active BOOLEAN DEFAULT true NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS brands (
//             id VARCHAR(50) PRIMARY KEY,
//             name VARCHAR(100) UNIQUE NOT NULL,
//             slug VARCHAR(100) NOT NULL,
//             logo_url TEXT,
//             description TEXT,
//             is_featured BOOLEAN DEFAULT false NOT NULL,
//             is_active BOOLEAN DEFAULT true NOT NULL
//         );

//         ALTER TABLE products ADD COLUMN IF NOT EXISTS slug VARCHAR(255);
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS subcategory_id VARCHAR(50);
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS brand_id VARCHAR(50);
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false;
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS is_trending BOOLEAN DEFAULT false;
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS is_best_seller BOOLEAN DEFAULT false;
//         ALTER TABLE products ADD COLUMN IF NOT EXISTS is_flash_deal BOOLEAN DEFAULT false;

//         CREATE TABLE IF NOT EXISTS product_variants (
//             id VARCHAR(50) PRIMARY KEY,
//             product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
//             sku VARCHAR(100) UNIQUE NOT NULL,
//             name VARCHAR(100) NOT NULL,
//             attribute_values JSONB,
//             price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
//             original_price NUMERIC(10, 2),
//             inventory_count INT DEFAULT 0 NOT NULL CHECK (inventory_count >= 0),
//             is_default BOOLEAN DEFAULT false NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS warehouses (
//             id VARCHAR(50) PRIMARY KEY,
//             name VARCHAR(100) NOT NULL,
//             code VARCHAR(50) UNIQUE NOT NULL,
//             address TEXT NOT NULL,
//             city VARCHAR(100) NOT NULL,
//             state VARCHAR(100) NOT NULL,
//             postal_code VARCHAR(20) NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS dark_stores (
//             id VARCHAR(50) PRIMARY KEY,
//             warehouse_id VARCHAR(50) REFERENCES warehouses(id) ON DELETE SET NULL,
//             name VARCHAR(100) NOT NULL,
//             code VARCHAR(50) UNIQUE NOT NULL,
//             latitude DOUBLE PRECISION NOT NULL,
//             longitude DOUBLE PRECISION NOT NULL,
//             address TEXT NOT NULL,
//             is_active BOOLEAN DEFAULT true NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS store_inventory (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE NOT NULL,
//             product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
//             variant_id VARCHAR(50) REFERENCES product_variants(id) ON DELETE CASCADE,
//             stock_quantity INT DEFAULT 0 NOT NULL CHECK (stock_quantity >= 0),
//             low_stock_threshold INT DEFAULT 10 NOT NULL,
//             is_available BOOLEAN DEFAULT true NOT NULL,
//             UNIQUE(store_id, product_id, variant_id)
//         );

//         CREATE TABLE IF NOT EXISTS stock_movements (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE NOT NULL,
//             product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
//             variant_id VARCHAR(50) REFERENCES product_variants(id) ON DELETE SET NULL,
//             movement_type VARCHAR(50) NOT NULL,
//             quantity INT NOT NULL,
//             reason TEXT,
//             notes TEXT,
//             created_by VARCHAR(100) DEFAULT 'System',
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS recently_viewed_products (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
//             product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
//             viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             UNIQUE(user_id, product_id)
//         );

//         -- Module 6 Payments & Wallet Tables
//         CREATE TABLE IF NOT EXISTS payment_transactions (
//             id VARCHAR(100) PRIMARY KEY,
//             order_id VARCHAR(100),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE,
//             amount NUMERIC(12, 2) NOT NULL,
//             currency VARCHAR(10) DEFAULT 'INR' NOT NULL,
//             payment_method VARCHAR(50) NOT NULL,
//             provider VARCHAR(50) NOT NULL,
//             status VARCHAR(50) NOT NULL,
//             transaction_id VARCHAR(100) UNIQUE,
//             idempotency_key VARCHAR(100),
//             gateway_ref VARCHAR(100),
//             error_message TEXT,
//             risk_score NUMERIC(5, 2) DEFAULT 0.0,
//             is_flagged BOOLEAN DEFAULT false,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_payment_tx_user_id ON payment_transactions(user_id);
//         CREATE INDEX IF NOT EXISTS idx_payment_tx_order_id ON payment_transactions(order_id);
//         CREATE INDEX IF NOT EXISTS idx_payment_tx_status ON payment_transactions(status);

//         CREATE TABLE IF NOT EXISTS wallet_ledger (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
//             type VARCHAR(20) NOT NULL,
//             category VARCHAR(50) NOT NULL,
//             amount NUMERIC(12, 2) NOT NULL,
//             balance_after NUMERIC(12, 2) NOT NULL,
//             reference_id VARCHAR(100),
//             description TEXT,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_wallet_ledger_user_id ON wallet_ledger(user_id);

//         CREATE TABLE IF NOT EXISTS refund_records (
//             id VARCHAR(100) PRIMARY KEY,
//             payment_id VARCHAR(100) REFERENCES payment_transactions(id) ON DELETE CASCADE,
//             order_id VARCHAR(100),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE,
//             amount NUMERIC(12, 2) NOT NULL,
//             refund_type VARCHAR(20) DEFAULT 'FULL' NOT NULL,
//             reason TEXT,
//             status VARCHAR(50) DEFAULT 'PROCESSED' NOT NULL,
//             gateway_refund_id VARCHAR(100),
//             approved_by VARCHAR(100) DEFAULT 'System',
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_refund_records_payment_id ON refund_records(payment_id);

//         CREATE TABLE IF NOT EXISTS reward_ledger (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
//             points INT NOT NULL,
//             type VARCHAR(20) NOT NULL,
//             reason TEXT,
//             expiry_date TIMESTAMP WITH TIME ZONE,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//         CREATE INDEX IF NOT EXISTS idx_reward_ledger_user_id ON reward_ledger(user_id);

//         CREATE TABLE IF NOT EXISTS gateway_logs (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             provider VARCHAR(50) NOT NULL,
//             event_type VARCHAR(100) NOT NULL,
//             payload JSONB,
//             signature VARCHAR(255),
//             status VARCHAR(50) NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         -- Module 7 Delivery & Logistics Platform Tables
//         CREATE TABLE IF NOT EXISTS rider_availability (
//             id VARCHAR(50) PRIMARY KEY,
//             name VARCHAR(100) NOT NULL,
//             phone VARCHAR(20) NOT NULL,
//             avatar TEXT,
//             vehicle_type VARCHAR(50) DEFAULT 'Scooter',
//             vehicle_number VARCHAR(50),
//             is_online BOOLEAN DEFAULT true NOT NULL,
//             current_store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE SET NULL,
//             active_delivery_id VARCHAR(100),
//             rating NUMERIC(3, 2) DEFAULT 4.95 CHECK (rating >= 1.0 AND rating <= 5.0),
//             total_trips INT DEFAULT 0 CHECK (total_trips >= 0),
//             total_earnings NUMERIC(12, 2) DEFAULT 0.00 CHECK (total_earnings >= 0),
//             current_latitude DOUBLE PRECISION DEFAULT 12.9279 NOT NULL,
//             current_longitude DOUBLE PRECISION DEFAULT 77.6250 NOT NULL,
//             bearing NUMERIC(6, 2) DEFAULT 0.00 NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS vehicle_details (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE CASCADE NOT NULL,
//             vehicle_type VARCHAR(50) DEFAULT 'Scooter' NOT NULL,
//             vehicle_number VARCHAR(50) NOT NULL,
//             model VARCHAR(100),
//             license_number VARCHAR(100),
//             is_active BOOLEAN DEFAULT true NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS delivery_tracking (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             order_id VARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE UNIQUE NOT NULL,
//             store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE RESTRICT,
//             rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE SET NULL,
//             rider_name VARCHAR(100) DEFAULT 'Unassigned',
//             rider_phone VARCHAR(20) DEFAULT '',
//             rider_avatar TEXT,
//             current_latitude DOUBLE PRECISION DEFAULT 12.9279 NOT NULL,
//             current_longitude DOUBLE PRECISION DEFAULT 77.6250 NOT NULL,
//             bearing NUMERIC(6, 2) DEFAULT 0.00 NOT NULL,
//             status VARCHAR(50) DEFAULT 'READY_FOR_PICKUP' NOT NULL,
//             otp_code VARCHAR(10) DEFAULT '4932' NOT NULL,
//             proof_photo_url TEXT,
//             signature_url TEXT,
//             eta_mins INT DEFAULT 10 NOT NULL,
//             distance_km NUMERIC(6, 2) DEFAULT 2.4 NOT NULL,
//             delivery_fee NUMERIC(8, 2) DEFAULT 35.00 NOT NULL,
//             surge_multiplier NUMERIC(4, 2) DEFAULT 1.00 NOT NULL,
//             failure_reason TEXT,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS delivery_assignments (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
//             order_id VARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
//             rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE CASCADE NOT NULL,
//             store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE,
//             status VARCHAR(50) DEFAULT 'ASSIGNED' NOT NULL,
//             assignment_mode VARCHAR(20) DEFAULT 'AUTO' NOT NULL,
//             assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             accepted_at TIMESTAMP WITH TIME ZONE,
//             rejected_at TIMESTAMP WITH TIME ZONE,
//             rejection_reason TEXT,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS gps_location_history (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
//             rider_id VARCHAR(50) NOT NULL,
//             latitude DOUBLE PRECISION NOT NULL,
//             longitude DOUBLE PRECISION NOT NULL,
//             bearing NUMERIC(6, 2) DEFAULT 0.00,
//             speed NUMERIC(6, 2) DEFAULT 0.00,
//             battery_level INT DEFAULT 100,
//             recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS delivery_audit_logs (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
//             order_id VARCHAR(50) NOT NULL,
//             actor_type VARCHAR(50) NOT NULL,
//             actor_id VARCHAR(100),
//             event VARCHAR(100) NOT NULL,
//             previous_state VARCHAR(50),
//             new_state VARCHAR(50) NOT NULL,
//             payload JSONB,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         -- Module 8 Notification & Communication Platform Tables
//         CREATE TABLE IF NOT EXISTS notifications (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) NOT NULL,
//             role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
//             title VARCHAR(255) NOT NULL,
//             body TEXT NOT NULL,
//             category VARCHAR(50) DEFAULT 'ORDER' NOT NULL,
//             channel VARCHAR(50) DEFAULT 'IN_APP' NOT NULL,
//             read BOOLEAN DEFAULT false NOT NULL,
//             metadata JSONB,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS notification_templates (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             code VARCHAR(100) UNIQUE NOT NULL,
//             title VARCHAR(255) NOT NULL,
//             body_template TEXT NOT NULL,
//             category VARCHAR(50) NOT NULL,
//             channels JSONB DEFAULT '["IN_APP", "PUSH", "EMAIL", "SMS"]'::jsonb NOT NULL,
//             is_active BOOLEAN DEFAULT true NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS notification_preferences (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) UNIQUE NOT NULL,
//             role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
//             email_enabled BOOLEAN DEFAULT true NOT NULL,
//             sms_enabled BOOLEAN DEFAULT true NOT NULL,
//             push_enabled BOOLEAN DEFAULT true NOT NULL,
//             in_app_enabled BOOLEAN DEFAULT true NOT NULL,
//             categories JSONB DEFAULT '{"ORDER": true, "WALLET": true, "PROMO": true, "SYSTEM": true, "DELIVERY": true, "INVENTORY": true}'::jsonb NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS notification_logs (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             notification_id UUID,
//             channel VARCHAR(50) NOT NULL,
//             recipient VARCHAR(255) NOT NULL,
//             status VARCHAR(50) DEFAULT 'DELIVERED' NOT NULL,
//             retry_count INT DEFAULT 0 NOT NULL,
//             error_message TEXT,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         -- Module 9 AI Intelligence Platform Tables
//         CREATE TABLE IF NOT EXISTS ai_conversations (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1' NOT NULL,
//             role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
//             topic VARCHAR(100) DEFAULT 'SHOPPING' NOT NULL,
//             messages JSONB DEFAULT '[]'::jsonb NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
//             updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS ai_usage_logs (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1',
//             feature VARCHAR(50) NOT NULL,
//             model_name VARCHAR(100) DEFAULT 'gemini-3.6-flash' NOT NULL,
//             prompt_tokens INT DEFAULT 0 NOT NULL,
//             completion_tokens INT DEFAULT 0 NOT NULL,
//             latency_ms INT DEFAULT 0 NOT NULL,
//             status VARCHAR(20) DEFAULT 'SUCCESS' NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS ai_recommendations (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1',
//             type VARCHAR(50) NOT NULL,
//             data JSONB NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS prompt_history (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1',
//             feature VARCHAR(50) NOT NULL,
//             prompt TEXT NOT NULL,
//             response TEXT NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS recipe_history (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1',
//             recipe_name VARCHAR(255) NOT NULL,
//             recipe_data JSONB NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );

//         CREATE TABLE IF NOT EXISTS nutrition_logs (
//             id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
//             user_id VARCHAR(50) DEFAULT 'u1',
//             log_data JSONB NOT NULL,
//             health_score INT DEFAULT 85 NOT NULL,
//             created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
//         );
//       `);

//       // Seed Dark Stores and Warehouse if empty
//       const dsCheck = await client.query("SELECT COUNT(*) FROM dark_stores");
//       if (parseInt(dsCheck.rows[0].count) === 0) {
//         await client.query(`
//           INSERT INTO warehouses (id, name, code, address, city, state, postal_code)
//           VALUES ('w1', 'Central Logistics Hub', 'WH-BLR-01', '100 Feet Rd, Indiranagar', 'Bangalore', 'Karnataka', '560038')
//           ON CONFLICT DO NOTHING;

//           INSERT INTO dark_stores (id, warehouse_id, name, code, latitude, longitude, address, is_active)
//           VALUES 
//           ('s1', 'w1', 'Koramangala Dark Store', 'DS-BLR-01', 12.9279, 77.6250, 'Block 3, Koramangala, Bangalore', true),
//           ('s2', 'w1', 'Indiranagar Quick Hub', 'DS-BLR-02', 12.9716, 77.6412, '100ft Road, Indiranagar, Bangalore', true),
//           ('s3', 'w1', 'HSR Layout Depot', 'DS-BLR-03', 12.9121, 77.6445, 'Sector 1, HSR Layout, Bangalore', true)
//           ON CONFLICT DO NOTHING;
//         `);
//       }

//       // Seed Riders if empty
//       const riderCheck = await client.query("SELECT COUNT(*) FROM rider_availability");
//       if (parseInt(riderCheck.rows[0].count) === 0) {
//         await client.query(`
//           INSERT INTO rider_availability (id, name, phone, avatar, vehicle_type, vehicle_number, is_online, current_store_id, rating, total_trips, total_earnings, current_latitude, current_longitude)
//           VALUES
//           ('r1', 'Suresh Kumar', '+91 98765 43210', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120', 'Scooter', 'KA-01-EQ-9041', true, 's1', 4.95, 142, 12450.00, 12.9279, 77.6250),
//           ('r2', 'Ramesh Patel', '+91 98123 45678', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120', 'E-Bike', 'KA-01-EV-3312', true, 's1', 4.88, 98, 8900.00, 12.9300, 77.6280),
//           ('r3', 'Vikram Singh', '+91 99887 76655', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=120', 'EV Van', 'KA-01-EV-8821', false, 's2', 4.90, 210, 18900.00, 12.9716, 77.6412)
//           ON CONFLICT DO NOTHING;

//           INSERT INTO vehicle_details (rider_id, vehicle_type, vehicle_number, model, license_number)
//           VALUES
//           ('r1', 'Scooter', 'KA-01-EQ-9041', 'Ather 450X EV', 'DL-BLR-2022-0091'),
//           ('r2', 'E-Bike', 'KA-01-EV-3312', 'Revolt RV400', 'DL-BLR-2023-0142'),
//           ('r3', 'EV Van', 'KA-01-EV-8821', 'Tata Ace EV', 'DL-BLR-2021-0012')
//           ON CONFLICT DO NOTHING;
//         `);
//       }

//       // Seed default Brands
//       const brandCheck = await client.query("SELECT COUNT(*) FROM brands");
//       if (parseInt(brandCheck.rows[0].count) === 0) {
//         await client.query(`
//           INSERT INTO brands (id, name, slug, description, is_featured) VALUES
//           ('b1', 'Organic India', 'organic-india', 'Pure, natural, organic products', true),
//           ('b2', 'Amul', 'amul', 'The Taste of India', true),
//           ('b3', 'Britannia', 'britannia', 'Fresh bakery and biscuits', true),
//           ('b4', 'Nestle', 'nestle', 'Good food, good life', false),
//           ('b5', 'Catch', 'catch', '100% pure spices and herbs', false)
//           ON CONFLICT DO NOTHING;
//         `);
//       }

//       // Seed Notification Templates
//       const templateCheck = await client.query("SELECT COUNT(*) FROM notification_templates");
//       if (parseInt(templateCheck.rows[0].count) === 0) {
//         await client.query(`
//           INSERT INTO notification_templates (code, title, body_template, category, channels) VALUES
//           ('ORDER_PLACED', 'Order Placed Successfully! 🛒', 'Your order {{orderId}} for ₹{{amount}} has been received and sent to {{storeName}}.', 'ORDER', '["IN_APP", "PUSH", "EMAIL", "SMS"]'::jsonb),
//           ('RIDER_ASSIGNED', 'Rider Assigned 🛵', '{{riderName}} ({{vehicleNumber}}) is assigned to deliver your order #{{orderId}}.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
//           ('OUT_FOR_DELIVERY', 'Out for Delivery 🚀', 'Your order #{{orderId}} is on its way with {{riderName}}. ETA: {{eta}} mins.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
//           ('RIDER_NEARBY', 'Rider Nearby 📍', '{{riderName}} is less than 500m away! Get ready with OTP: {{otpCode}}.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
//           ('DELIVERED', 'Order Delivered 🎉', 'Order #{{orderId}} was successfully delivered. Enjoy your fresh groceries!', 'ORDER', '["IN_APP", "PUSH", "EMAIL"]'::jsonb),
//           ('WALLET_CREDITED', 'Wallet Credited 💳', '₹{{amount}} has been credited to your FlashCart wallet. Reason: {{reason}}.', 'WALLET', '["IN_APP", "PUSH", "SMS"]'::jsonb),
//           ('PEAK_HOUR_BONUS', 'Peak Hour Bonus Active 🔥', 'Earn 1.5x earnings per trip in Koramangala zone for the next 2 hours!', 'DELIVERY', '["IN_APP", "PUSH"]'::jsonb),
//           ('NEW_DELIVERY_REQUEST', 'New Order Request 📦', 'Order #{{orderId}} available at {{storeName}}. Pickup distance: {{distance}} km.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
//           ('STORE_NEW_ORDER', 'New Express Order 🔔', 'Order #{{orderId}} received with {{itemCount}} items. Start picking immediately!', 'INVENTORY', '["IN_APP", "PUSH"]'::jsonb),
//           ('LOW_INVENTORY_ALERT', 'Low Stock Warning ⚠️', 'Item {{productName}} has reached low stock threshold ({{stock}} left) at {{storeName}}.', 'INVENTORY', '["IN_APP", "EMAIL"]'::jsonb),
//           ('FRAUD_ALERT', 'Security Fraud Alert 🚨', 'Suspicious activity detected for user {{userId}} on order #{{orderId}}.', 'SYSTEM', '["IN_APP", "EMAIL"]'::jsonb),
//           ('SYSTEM_HEALTH_ALERT', 'System Health Alert 🖥️', 'Server API latency spike detected: {{latency}}ms across Cloud Run nodes.', 'SYSTEM', '["IN_APP", "EMAIL"]'::jsonb)
//           ON CONFLICT (code) DO NOTHING;
//         `);
//       }

//       // Add referrals trigger
//       try {
//         await client.query(`
//           CREATE TRIGGER update_referrals_timestamp BEFORE UPDATE ON referrals 
//           FOR EACH ROW EXECUTE FUNCTION update_timestamp_column();
//         `);
//       } catch (triggerErr) {
//         // Ignored if trigger already exists
//       }

//       console.log("✅ Database schema columns, auxiliary tables, and index constraints verified/created successfully.");
//     } finally {
//       client.release();
//     }
//   } catch (err) {
//     console.warn("⚠️ PostgreSQL auto-bootstrap skipped / failed:", err);
//   }
// }

// export async function testConnectionAndBootstrap() {
//   if (!dbPool) {
//     usePostgreSQL = false;
//     return;
//   }
//   try {
//     const client = await dbPool.connect();
//     client.release();
//     usePostgreSQL = true;
//     console.log("✅ Successfully connected to PostgreSQL database! Switching to live database mode.");
//     await bootstrapDb();
//   } catch (err) {
//     console.warn("⚠️ PostgreSQL connection failed on boot.");
//     usePostgreSQL = false;
//     if (isProduction) {
//       console.error("CRITICAL: Database connection failed in production mode!");
//     } else {
//       console.warn("Falling back to In-Memory simulation mode for development.");
//     }
//   }
// }

import pg from "pg";
import path from "path";
import fs from "fs";
import { isProduction } from "./env";
import { DB_STATE } from "./dbState";

const dbConfig = {
  host: process.env.PGHOST || process.env.SQL_HOST || 'localhost',
  user: process.env.PGUSER || process.env.SQL_USER || 'postgres',
  password: process.env.PGPASSWORD || process.env.SQL_PASSWORD || 'root',
  database: process.env.PGDATABASE || process.env.SQL_DB_NAME || 'flashcart_db',
  port: parseInt(process.env.PGPORT || process.env.SQL_PORT || '5432', 10),
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
};

export let dbPool: any = null;
export let usePostgreSQL = false;

try {
  const pgModule: any = pg || {};
  const PoolClass = pgModule.Pool || (pgModule.default ? pgModule.default.Pool : undefined);
  if (PoolClass) {
    dbPool = new PoolClass(dbConfig);
    dbPool.on('error', (err: any) => {
      console.warn('Unexpected database pool error on idle client:', err);
    });
  } else {
    console.warn("⚠️ Pool class is undefined on pg import.");
  }
} catch (err) {
  console.warn("⚠️ Could not instantiate PostgreSQL Pool:", err);
}

// Resilient query helper
export async function dbQuery(text: string, params?: any[]) {
  if (dbPool && usePostgreSQL) {
    try {
      return await dbPool.query(text, params);
    } catch (err: any) {
      console.error("PostgreSQL Query Error:", err);
      throw err;
    }
  }
  
  if (isProduction) {
    throw new Error("PostgreSQL is not active or connected in production!");
  }
  throw new Error("PostgreSQL is not active or connected");
}

// Activity logger helper
export async function logActivity(userId: string | null, actionType: string, details: string) {
  console.log(`[ACTIVITY LOG] User: ${userId || 'Anonymous'}, Action: ${actionType}, Details: ${details}`);
  if (dbPool && usePostgreSQL) {
    try {
      let actualUserId = userId;
      if (userId && userId.startsWith('FBAUTH_UID')) {
        const userRes = await dbPool.query("SELECT id FROM users WHERE firebase_uid = $1", [userId]);
        if (userRes.rows.length > 0) {
          actualUserId = userRes.rows[0].id;
        } else {
          actualUserId = null;
        }
      } else if (userId && userId === 'u1') {
        actualUserId = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
      }
      await dbPool.query(
        "INSERT INTO activity_logs (user_id, action_type, details) VALUES ($1, $2, $3)",
        [actualUserId, actionType, details]
      );
    } catch (err) {
      console.warn("Could not log activity in database:", err);
    }
  }
}

export async function bootstrapDb() {
  if (!dbPool) return;
  try {
    const client = await dbPool.connect();
    try {
      const checkRes = await client.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_name = 'users'
        );
      `);
      if (!checkRes.rows[0].exists) {
        console.log("PostgreSQL tables missing, auto-bootstrapping SCHEMA.sql...");
        const schemaPath = path.join(process.cwd(), 'docs', 'SCHEMA.sql');
        if (fs.existsSync(schemaPath)) {
          const schemaSql = fs.readFileSync(schemaPath, 'utf8');
          try {
            await client.query(schemaSql);
            console.log("SCHEMA.sql auto-bootstrapped successfully!");
          } catch (schemaErr: any) {
            console.warn("Error running complete SCHEMA.sql directly, trying without extension:", schemaErr);
            const cleanSql = schemaSql.replace(/CREATE EXTENSION IF NOT EXISTS "uuid-ossp";/gi, "");
            await client.query(cleanSql);
            console.log("SCHEMA.sql auto-bootstrapped (without extension) successfully!");
          }

          // Seed categories if empty
          const catCheck = await client.query("SELECT COUNT(*) FROM categories");
          if (parseInt(catCheck.rows[0].count) === 0) {
            console.log("Seeding default categories...");
            await client.query(`
              INSERT INTO categories (id, name, icon_name, color_hex, is_active, sort_order) VALUES
              ('veggies', 'Fresh Vegetables', 'Utensils', '#4ADE80', true, 1),
              ('dairy', 'Dairy & Milk', 'ShoppingBag', '#60A5FA', true, 2),
              ('bakery', 'Bakery & Bread', 'Sparkles', '#FBBF24', true, 3),
              ('snacks', 'Munchies & Snacks', 'Smile', '#F87171', true, 4),
              ('beverages', 'Cold Beverages', 'Flame', '#A78BFA', true, 5),
              ('pantry', 'Kitchen Pantry', 'Activity', '#FB7185', true, 6),
              ('medicine', 'Pharmacy & Wellness', 'Zap', '#2DD4BF', true, 7),
              ('baby', 'Baby Care Essentials', 'Heart', '#34D399', true, 8)
              ON CONFLICT DO NOTHING;
            `);
          }

          // Seed products if empty
          const prodCheck = await client.query("SELECT COUNT(*) FROM products");
          if (parseInt(prodCheck.rows[0].count) === 0) {
            console.log("Seeding default products...");
            for (const prod of DB_STATE.products) {
              await client.query(`
                INSERT INTO products (id, name, category_id, price, original_price, unit, image_url, rating, reviews_count, calories, protein_g, is_organic, is_healthy, eco_score, carbon_emission_kg, inventory_count, delivery_time_mins, description)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
                ON CONFLICT DO NOTHING;
              `, [
                prod.id, prod.name, prod.category, prod.price, prod.originalPrice || null, prod.unit, prod.image,
                prod.rating, prod.reviewsCount, prod.calories, prod.protein, prod.isOrganic || false,
                prod.isHealthy || false, prod.ecoScore, prod.carbonEmission, prod.inventory, prod.deliveryTimeMins,
                prod.description || ''
              ]);
            }
          }

          // Seed default user if empty
          const userCheck = await client.query("SELECT COUNT(*) FROM users");
          if (parseInt(userCheck.rows[0].count) === 0) {
            console.log("Seeding default user...");
            await client.query(`
              INSERT INTO users (id, firebase_uid, email, first_name, last_name, phone_number, wallet_balance, streak_count)
              VALUES ('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'FBAUTH_UID_9921', 'arav@example.com', 'Arav', 'Sharma', '+91 98765 43210', 1200.00, 5)
              ON CONFLICT DO NOTHING;
            `);
          }

          // Seed default addresses if empty
          const addrCheck = await client.query("SELECT COUNT(*) FROM addresses");
          if (parseInt(addrCheck.rows[0].count) === 0) {
            console.log("Seeding default address...");
            await client.query(`
              INSERT INTO addresses (user_id, title, address_line_1, address_line_2, landmark, city, state, postal_code, latitude, longitude, is_default)
              VALUES ('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'Home', 'Symphony Premium Apts', 'Koramangala 3rd Block', 'Near Sony Signal', 'Bangalore', 'Karnataka', '560034', 12.9279, 77.6250, true)
              ON CONFLICT DO NOTHING;
            `);
          }

          // Seed default coupons if empty
          const couponCheck = await client.query("SELECT COUNT(*) FROM coupons");
          if (parseInt(couponCheck.rows[0].count) === 0) {
            console.log("Seeding default coupons...");
            await client.query(`
              INSERT INTO coupons (code, discount_type, discount_value, max_discount, min_order_value, expires_at, is_active)
              VALUES ('FLASH50', 'flat_rate', 50.00, 50.00, 300.00, CURRENT_TIMESTAMP + INTERVAL '30 days', true)
              ON CONFLICT DO NOTHING;
            `);
          }
        }
      } else {
        console.log("PostgreSQL database tables already present.");
      }

      // Ensure profile_photo and last_login columns exist on users table, plus Module 1 Auth additions
      console.log("Upgrading users schema for Module 1 Auth...");
      await client.query(`
        ALTER TABLE users ALTER COLUMN firebase_uid DROP NOT NULL;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_photo TEXT;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(20);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
      `);

      // Enforce default values for nullable columns that should be non-nullable going forward
      await client.query(`
        UPDATE users SET is_verified = false WHERE is_verified IS NULL;
        UPDATE users SET is_active = true WHERE is_active IS NULL;
        ALTER TABLE users ALTER COLUMN is_verified SET NOT NULL;
        ALTER TABLE users ALTER COLUMN is_active SET NOT NULL;
      `);

      // Ensure index constraints exist
      await client.query(`
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
        CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
      `);

      // Upgrade addresses table with modular fields
      console.log("Upgrading addresses schema for Module 1...");
      await client.query(`
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS house_no VARCHAR(100);
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS apartment VARCHAR(100);
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS street VARCHAR(255);
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS country VARCHAR(100) DEFAULT 'India';
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS pincode VARCHAR(20);
        ALTER TABLE addresses ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20);
        ALTER TABLE addresses ALTER COLUMN address_line_1 DROP NOT NULL;
      `);

      // Ensure core Auth modules' auxiliary tables exist
      console.log("Ensuring auth auxiliary tables exist (otp_verifications, user_sessions, referrals)...");
      await client.query(`
        CREATE TABLE IF NOT EXISTS otp_verifications (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            phone VARCHAR(20) NOT NULL,
            otp VARCHAR(6) NOT NULL,
            expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
            verified BOOLEAN DEFAULT false NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_otp_verifications_phone ON otp_verifications(phone);

        CREATE TABLE IF NOT EXISTS user_sessions (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
            device_id VARCHAR(255),
            device_name VARCHAR(255),
            firebase_token TEXT,
            refresh_token TEXT,
            ip_address VARCHAR(45),
            login_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            logout_time TIMESTAMP WITH TIME ZONE
        );
        CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
        CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh_token ON user_sessions(refresh_token);

        CREATE TABLE IF NOT EXISTS referrals (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
            referral_code VARCHAR(50) UNIQUE NOT NULL,
            referred_by UUID REFERENCES users(id) ON DELETE SET NULL,
            reward_points INT DEFAULT 0 CHECK (reward_points >= 0) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_referrals_user_id ON referrals(user_id);
        CREATE INDEX IF NOT EXISTS idx_referrals_code ON referrals(referral_code);

        -- Module 3 Tables
        CREATE TABLE IF NOT EXISTS subcategories (
            id VARCHAR(50) PRIMARY KEY,
            category_id VARCHAR(50) REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
            name VARCHAR(100) NOT NULL,
            slug VARCHAR(100) NOT NULL,
            image_url TEXT,
            is_active BOOLEAN DEFAULT true NOT NULL
        );

        CREATE TABLE IF NOT EXISTS brands (
            id VARCHAR(50) PRIMARY KEY,
            name VARCHAR(100) UNIQUE NOT NULL,
            slug VARCHAR(100) NOT NULL,
            logo_url TEXT,
            description TEXT,
            is_featured BOOLEAN DEFAULT false NOT NULL,
            is_active BOOLEAN DEFAULT true NOT NULL
        );

        ALTER TABLE products ADD COLUMN IF NOT EXISTS slug VARCHAR(255);
        ALTER TABLE products ADD COLUMN IF NOT EXISTS subcategory_id VARCHAR(50);
        ALTER TABLE products ADD COLUMN IF NOT EXISTS brand_id VARCHAR(50);
        ALTER TABLE products ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false;
        ALTER TABLE products ADD COLUMN IF NOT EXISTS is_trending BOOLEAN DEFAULT false;
        ALTER TABLE products ADD COLUMN IF NOT EXISTS is_best_seller BOOLEAN DEFAULT false;
        ALTER TABLE products ADD COLUMN IF NOT EXISTS is_flash_deal BOOLEAN DEFAULT false;

        CREATE TABLE IF NOT EXISTS product_variants (
            id VARCHAR(50) PRIMARY KEY,
            product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
            sku VARCHAR(100) UNIQUE NOT NULL,
            name VARCHAR(100) NOT NULL,
            attribute_values JSONB,
            price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
            original_price NUMERIC(10, 2),
            inventory_count INT DEFAULT 0 NOT NULL CHECK (inventory_count >= 0),
            is_default BOOLEAN DEFAULT false NOT NULL
        );

        CREATE TABLE IF NOT EXISTS warehouses (
            id VARCHAR(50) PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            code VARCHAR(50) UNIQUE NOT NULL,
            address TEXT NOT NULL,
            city VARCHAR(100) NOT NULL,
            state VARCHAR(100) NOT NULL,
            postal_code VARCHAR(20) NOT NULL
        );

        CREATE TABLE IF NOT EXISTS dark_stores (
            id VARCHAR(50) PRIMARY KEY,
            warehouse_id VARCHAR(50) REFERENCES warehouses(id) ON DELETE SET NULL,
            name VARCHAR(100) NOT NULL,
            code VARCHAR(50) UNIQUE NOT NULL,
            latitude DOUBLE PRECISION NOT NULL,
            longitude DOUBLE PRECISION NOT NULL,
            address TEXT NOT NULL,
            is_active BOOLEAN DEFAULT true NOT NULL
        );

        CREATE TABLE IF NOT EXISTS store_inventory (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE NOT NULL,
            product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
            variant_id VARCHAR(50) REFERENCES product_variants(id) ON DELETE CASCADE,
            stock_quantity INT DEFAULT 0 NOT NULL CHECK (stock_quantity >= 0),
            low_stock_threshold INT DEFAULT 10 NOT NULL,
            is_available BOOLEAN DEFAULT true NOT NULL,
            UNIQUE(store_id, product_id, variant_id)
        );

        CREATE TABLE IF NOT EXISTS stock_movements (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE NOT NULL,
            product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
            variant_id VARCHAR(50) REFERENCES product_variants(id) ON DELETE SET NULL,
            movement_type VARCHAR(50) NOT NULL,
            quantity INT NOT NULL,
            reason TEXT,
            notes TEXT,
            created_by VARCHAR(100) DEFAULT 'System',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS recently_viewed_products (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
            product_id VARCHAR(50) REFERENCES products(id) ON DELETE CASCADE NOT NULL,
            viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            UNIQUE(user_id, product_id)
        );

        -- Module 6 Payments & Wallet Tables
        CREATE TABLE IF NOT EXISTS payment_transactions (
            id VARCHAR(100) PRIMARY KEY,
            order_id VARCHAR(100),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            amount NUMERIC(12, 2) NOT NULL,
            currency VARCHAR(10) DEFAULT 'INR' NOT NULL,
            payment_method VARCHAR(50) NOT NULL,
            provider VARCHAR(50) NOT NULL,
            status VARCHAR(50) NOT NULL,
            transaction_id VARCHAR(100) UNIQUE,
            idempotency_key VARCHAR(100) UNIQUE,
            gateway_ref VARCHAR(100),
            error_message TEXT,
            risk_score NUMERIC(5, 2) DEFAULT 0.0,
            is_flagged BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_payment_tx_user_id ON payment_transactions(user_id);
        CREATE INDEX IF NOT EXISTS idx_payment_tx_order_id ON payment_transactions(order_id);
        CREATE INDEX IF NOT EXISTS idx_payment_tx_status ON payment_transactions(status);

        CREATE TABLE IF NOT EXISTS wallet_ledger (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
            type VARCHAR(20) NOT NULL,
            category VARCHAR(50) NOT NULL,
            amount NUMERIC(12, 2) NOT NULL,
            balance_after NUMERIC(12, 2) NOT NULL,
            reference_id VARCHAR(100),
            description TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_wallet_ledger_user_id ON wallet_ledger(user_id);
        CREATE INDEX IF NOT EXISTS idx_wallet_ledger_ref_cat ON wallet_ledger(reference_id, category);

        CREATE TABLE IF NOT EXISTS refund_records (
            id VARCHAR(100) PRIMARY KEY,
            payment_id VARCHAR(100) REFERENCES payment_transactions(id) ON DELETE CASCADE,
            order_id VARCHAR(100),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            amount NUMERIC(12, 2) NOT NULL,
            refund_type VARCHAR(20) DEFAULT 'FULL' NOT NULL,
            reason TEXT,
            status VARCHAR(50) DEFAULT 'PROCESSED' NOT NULL,
            gateway_refund_id VARCHAR(100),
            approved_by VARCHAR(100) DEFAULT 'System',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_refund_records_payment_id ON refund_records(payment_id);

        CREATE TABLE IF NOT EXISTS reward_ledger (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
            points INT NOT NULL,
            type VARCHAR(20) NOT NULL,
            reason TEXT,
            reference_id VARCHAR(100),
            expiry_date TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_reward_ledger_user_id ON reward_ledger(user_id);
        CREATE INDEX IF NOT EXISTS idx_reward_ledger_ref ON reward_ledger(reference_id, type);

        CREATE TABLE IF NOT EXISTS gateway_logs (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            provider VARCHAR(50) NOT NULL,
            event_id VARCHAR(100),
            event_type VARCHAR(100) NOT NULL,
            payload JSONB,
            signature VARCHAR(255),
            status VARCHAR(50) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        -- Module 7 Delivery & Logistics Platform Tables
        CREATE TABLE IF NOT EXISTS rider_availability (
            id VARCHAR(50) PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            avatar TEXT,
            vehicle_type VARCHAR(50) DEFAULT 'Scooter',
            vehicle_number VARCHAR(50),
            is_online BOOLEAN DEFAULT true NOT NULL,
            current_store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE SET NULL,
            active_delivery_id VARCHAR(100),
            rating NUMERIC(3, 2) DEFAULT 4.95 CHECK (rating >= 1.0 AND rating <= 5.0),
            total_trips INT DEFAULT 0 CHECK (total_trips >= 0),
            total_earnings NUMERIC(12, 2) DEFAULT 0.00 CHECK (total_earnings >= 0),
            current_latitude DOUBLE PRECISION DEFAULT 12.9279 NOT NULL,
            current_longitude DOUBLE PRECISION DEFAULT 77.6250 NOT NULL,
            bearing NUMERIC(6, 2) DEFAULT 0.00 NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS vehicle_details (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE CASCADE NOT NULL,
            vehicle_type VARCHAR(50) DEFAULT 'Scooter' NOT NULL,
            vehicle_number VARCHAR(50) NOT NULL,
            model VARCHAR(100),
            license_number VARCHAR(100),
            is_active BOOLEAN DEFAULT true NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS delivery_tracking (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            order_id VARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE UNIQUE NOT NULL,
            store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE RESTRICT,
            rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE SET NULL,
            rider_name VARCHAR(100) DEFAULT 'Unassigned',
            rider_phone VARCHAR(20) DEFAULT '',
            rider_avatar TEXT,
            current_latitude DOUBLE PRECISION DEFAULT 12.9279 NOT NULL,
            current_longitude DOUBLE PRECISION DEFAULT 77.6250 NOT NULL,
            bearing NUMERIC(6, 2) DEFAULT 0.00 NOT NULL,
            status VARCHAR(50) DEFAULT 'READY_FOR_PICKUP' NOT NULL,
            otp_code VARCHAR(10) DEFAULT '4932' NOT NULL,
            proof_photo_url TEXT,
            signature_url TEXT,
            eta_mins INT DEFAULT 10 NOT NULL,
            distance_km NUMERIC(6, 2) DEFAULT 2.4 NOT NULL,
            delivery_fee NUMERIC(8, 2) DEFAULT 35.00 NOT NULL,
            surge_multiplier NUMERIC(4, 2) DEFAULT 1.00 NOT NULL,
            failure_reason TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS delivery_assignments (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
            order_id VARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
            rider_id VARCHAR(50) REFERENCES rider_availability(id) ON DELETE CASCADE NOT NULL,
            store_id VARCHAR(50) REFERENCES dark_stores(id) ON DELETE CASCADE,
            status VARCHAR(50) DEFAULT 'ASSIGNED' NOT NULL,
            assignment_mode VARCHAR(20) DEFAULT 'AUTO' NOT NULL,
            assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            accepted_at TIMESTAMP WITH TIME ZONE,
            rejected_at TIMESTAMP WITH TIME ZONE,
            rejection_reason TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS gps_location_history (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
            rider_id VARCHAR(50) NOT NULL,
            latitude DOUBLE PRECISION NOT NULL,
            longitude DOUBLE PRECISION NOT NULL,
            bearing NUMERIC(6, 2) DEFAULT 0.00,
            speed NUMERIC(6, 2) DEFAULT 0.00,
            battery_level INT DEFAULT 100,
            recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS delivery_audit_logs (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            delivery_id UUID REFERENCES delivery_tracking(id) ON DELETE CASCADE,
            order_id VARCHAR(50) NOT NULL,
            actor_type VARCHAR(50) NOT NULL,
            actor_id VARCHAR(100),
            event VARCHAR(100) NOT NULL,
            previous_state VARCHAR(50),
            new_state VARCHAR(50) NOT NULL,
            payload JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        -- Module 8 Notification & Communication Platform Tables
        CREATE TABLE IF NOT EXISTS notifications (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) NOT NULL,
            role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
            title VARCHAR(255) NOT NULL,
            body TEXT NOT NULL,
            category VARCHAR(50) DEFAULT 'ORDER' NOT NULL,
            channel VARCHAR(50) DEFAULT 'IN_APP' NOT NULL,
            read BOOLEAN DEFAULT false NOT NULL,
            metadata JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS notification_templates (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            code VARCHAR(100) UNIQUE NOT NULL,
            title VARCHAR(255) NOT NULL,
            body_template TEXT NOT NULL,
            category VARCHAR(50) NOT NULL,
            channels JSONB DEFAULT '["IN_APP", "PUSH", "EMAIL", "SMS"]'::jsonb NOT NULL,
            is_active BOOLEAN DEFAULT true NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS notification_preferences (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) UNIQUE NOT NULL,
            role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
            email_enabled BOOLEAN DEFAULT true NOT NULL,
            sms_enabled BOOLEAN DEFAULT true NOT NULL,
            push_enabled BOOLEAN DEFAULT true NOT NULL,
            in_app_enabled BOOLEAN DEFAULT true NOT NULL,
            categories JSONB DEFAULT '{"ORDER": true, "WALLET": true, "PROMO": true, "SYSTEM": true, "DELIVERY": true, "INVENTORY": true}'::jsonb NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS notification_logs (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            notification_id UUID,
            channel VARCHAR(50) NOT NULL,
            recipient VARCHAR(255) NOT NULL,
            status VARCHAR(50) DEFAULT 'DELIVERED' NOT NULL,
            retry_count INT DEFAULT 0 NOT NULL,
            error_message TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        -- Module 9 AI Intelligence Platform Tables
        CREATE TABLE IF NOT EXISTS ai_conversations (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1' NOT NULL,
            role VARCHAR(30) DEFAULT 'CUSTOMER' NOT NULL,
            topic VARCHAR(100) DEFAULT 'SHOPPING' NOT NULL,
            messages JSONB DEFAULT '[]'::jsonb NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS ai_usage_logs (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1',
            feature VARCHAR(50) NOT NULL,
            model_name VARCHAR(100) DEFAULT 'gemini-3.6-flash' NOT NULL,
            prompt_tokens INT DEFAULT 0 NOT NULL,
            completion_tokens INT DEFAULT 0 NOT NULL,
            latency_ms INT DEFAULT 0 NOT NULL,
            status VARCHAR(20) DEFAULT 'SUCCESS' NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS ai_recommendations (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1',
            type VARCHAR(50) NOT NULL,
            data JSONB NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS prompt_history (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1',
            feature VARCHAR(50) NOT NULL,
            prompt TEXT NOT NULL,
            response TEXT NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS recipe_history (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1',
            recipe_name VARCHAR(255) NOT NULL,
            recipe_data JSONB NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );

        CREATE TABLE IF NOT EXISTS nutrition_logs (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id VARCHAR(50) DEFAULT 'u1',
            log_data JSONB NOT NULL,
            health_score INT DEFAULT 85 NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
      `);

      // Seed Dark Stores and Warehouse if empty
      const dsCheck = await client.query("SELECT COUNT(*) FROM dark_stores");
      if (parseInt(dsCheck.rows[0].count) === 0) {
        await client.query(`
          INSERT INTO warehouses (id, name, code, address, city, state, postal_code)
          VALUES ('w1', 'Central Logistics Hub', 'WH-BLR-01', '100 Feet Rd, Indiranagar', 'Bangalore', 'Karnataka', '560038')
          ON CONFLICT DO NOTHING;

          INSERT INTO dark_stores (id, warehouse_id, name, code, latitude, longitude, address, is_active)
          VALUES 
          ('s1', 'w1', 'Koramangala Dark Store', 'DS-BLR-01', 12.9279, 77.6250, 'Block 3, Koramangala, Bangalore', true),
          ('s2', 'w1', 'Indiranagar Quick Hub', 'DS-BLR-02', 12.9716, 77.6412, '100ft Road, Indiranagar, Bangalore', true),
          ('s3', 'w1', 'HSR Layout Depot', 'DS-BLR-03', 12.9121, 77.6445, 'Sector 1, HSR Layout, Bangalore', true)
          ON CONFLICT DO NOTHING;
        `);
      }

      // Seed Riders if empty
      const riderCheck = await client.query("SELECT COUNT(*) FROM rider_availability");
      if (parseInt(riderCheck.rows[0].count) === 0) {
        await client.query(`
          INSERT INTO rider_availability (id, name, phone, avatar, vehicle_type, vehicle_number, is_online, current_store_id, rating, total_trips, total_earnings, current_latitude, current_longitude)
          VALUES
          ('r1', 'Suresh Kumar', '+91 98765 43210', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120', 'Scooter', 'KA-01-EQ-9041', true, 's1', 4.95, 142, 12450.00, 12.9279, 77.6250),
          ('r2', 'Ramesh Patel', '+91 98123 45678', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120', 'E-Bike', 'KA-01-EV-3312', true, 's1', 4.88, 98, 8900.00, 12.9300, 77.6280),
          ('r3', 'Vikram Singh', '+91 99887 76655', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=120', 'EV Van', 'KA-01-EV-8821', false, 's2', 4.90, 210, 18900.00, 12.9716, 77.6412)
          ON CONFLICT DO NOTHING;

          INSERT INTO vehicle_details (rider_id, vehicle_type, vehicle_number, model, license_number)
          VALUES
          ('r1', 'Scooter', 'KA-01-EQ-9041', 'Ather 450X EV', 'DL-BLR-2022-0091'),
          ('r2', 'E-Bike', 'KA-01-EV-3312', 'Revolt RV400', 'DL-BLR-2023-0142'),
          ('r3', 'EV Van', 'KA-01-EV-8821', 'Tata Ace EV', 'DL-BLR-2021-0012')
          ON CONFLICT DO NOTHING;
        `);
      }

      // Seed default Brands
      const brandCheck = await client.query("SELECT COUNT(*) FROM brands");
      if (parseInt(brandCheck.rows[0].count) === 0) {
        await client.query(`
          INSERT INTO brands (id, name, slug, description, is_featured) VALUES
          ('b1', 'Organic India', 'organic-india', 'Pure, natural, organic products', true),
          ('b2', 'Amul', 'amul', 'The Taste of India', true),
          ('b3', 'Britannia', 'britannia', 'Fresh bakery and biscuits', true),
          ('b4', 'Nestle', 'nestle', 'Good food, good life', false),
          ('b5', 'Catch', 'catch', '100% pure spices and herbs', false)
          ON CONFLICT DO NOTHING;
        `);
      }

      // Seed Notification Templates
      const templateCheck = await client.query("SELECT COUNT(*) FROM notification_templates");
      if (parseInt(templateCheck.rows[0].count) === 0) {
        await client.query(`
          INSERT INTO notification_templates (code, title, body_template, category, channels) VALUES
          ('ORDER_PLACED', 'Order Placed Successfully! 🛒', 'Your order {{orderId}} for ₹{{amount}} has been received and sent to {{storeName}}.', 'ORDER', '["IN_APP", "PUSH", "EMAIL", "SMS"]'::jsonb),
          ('RIDER_ASSIGNED', 'Rider Assigned 🛵', '{{riderName}} ({{vehicleNumber}}) is assigned to deliver your order #{{orderId}}.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
          ('OUT_FOR_DELIVERY', 'Out for Delivery 🚀', 'Your order #{{orderId}} is on its way with {{riderName}}. ETA: {{eta}} mins.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
          ('RIDER_NEARBY', 'Rider Nearby 📍', '{{riderName}} is less than 500m away! Get ready with OTP: {{otpCode}}.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
          ('DELIVERED', 'Order Delivered 🎉', 'Order #{{orderId}} was successfully delivered. Enjoy your fresh groceries!', 'ORDER', '["IN_APP", "PUSH", "EMAIL"]'::jsonb),
          ('WALLET_CREDITED', 'Wallet Credited 💳', '₹{{amount}} has been credited to your FlashCart wallet. Reason: {{reason}}.', 'WALLET', '["IN_APP", "PUSH", "SMS"]'::jsonb),
          ('PEAK_HOUR_BONUS', 'Peak Hour Bonus Active 🔥', 'Earn 1.5x earnings per trip in Koramangala zone for the next 2 hours!', 'DELIVERY', '["IN_APP", "PUSH"]'::jsonb),
          ('NEW_DELIVERY_REQUEST', 'New Order Request 📦', 'Order #{{orderId}} available at {{storeName}}. Pickup distance: {{distance}} km.', 'DELIVERY', '["IN_APP", "PUSH", "SMS"]'::jsonb),
          ('STORE_NEW_ORDER', 'New Express Order 🔔', 'Order #{{orderId}} received with {{itemCount}} items. Start picking immediately!', 'INVENTORY', '["IN_APP", "PUSH"]'::jsonb),
          ('LOW_INVENTORY_ALERT', 'Low Stock Warning ⚠️', 'Item {{productName}} has reached low stock threshold ({{stock}} left) at {{storeName}}.', 'INVENTORY', '["IN_APP", "EMAIL"]'::jsonb),
          ('FRAUD_ALERT', 'Security Fraud Alert 🚨', 'Suspicious activity detected for user {{userId}} on order #{{orderId}}.', 'SYSTEM', '["IN_APP", "EMAIL"]'::jsonb),
          ('SYSTEM_HEALTH_ALERT', 'System Health Alert 🖥️', 'Server API latency spike detected: {{latency}}ms across Cloud Run nodes.', 'SYSTEM', '["IN_APP", "EMAIL"]'::jsonb)
          ON CONFLICT (code) DO NOTHING;
        `);
      }

      // Add referrals trigger
      try {
        await client.query(`
          CREATE TRIGGER update_referrals_timestamp BEFORE UPDATE ON referrals 
          FOR EACH ROW EXECUTE FUNCTION update_timestamp_column();
        `);
      } catch (triggerErr) {
        // Ignored if trigger already exists
      }

      console.log("✅ Database schema columns, auxiliary tables, and index constraints verified/created successfully.");
    } finally {
      client.release();
    }
  } catch (err) {
    console.warn("⚠️ PostgreSQL auto-bootstrap skipped / failed:", err);
  }
}

export async function testConnectionAndBootstrap() {
  if (!dbPool) {
    usePostgreSQL = false;
    return;
  }
  try {
    const client = await dbPool.connect();
    client.release();
    usePostgreSQL = true;
    console.log("✅ Successfully connected to PostgreSQL database! Switching to live database mode.");
    await bootstrapDb();
  } catch (err) {
    console.warn("⚠️ PostgreSQL connection failed on boot.");
    usePostgreSQL = false;
    if (isProduction) {
      console.error("CRITICAL: Database connection failed in production mode!");
    } else {
      console.warn("Falling back to In-Memory simulation mode for development.");
    }
  }
}
