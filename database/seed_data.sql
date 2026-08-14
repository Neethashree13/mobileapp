-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: seed_data.sql
-- Description: Realistic Seed Data for Quick Commerce (Roles, Users, Dark Stores, Products, Carts, Orders)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Roles Seed
-- ----------------------------------------------------------------------------
INSERT INTO roles (id, code, name, description) VALUES
('b0d912a2-5b91-4e78-9e12-82f2812a0001', 'SUPER_ADMIN', 'Super Admin', 'Full system access'),
('b0d912a2-5b91-4e78-9e12-82f2812a0002', 'ADMIN', 'Admin', 'Platform administrator'),
('b0d912a2-5b91-4e78-9e12-82f2812a0003', 'STORE_MANAGER', 'Store Manager', 'Dark store operations manager'),
('b0d912a2-5b91-4e78-9e12-82f2812a0004', 'RIDER', 'Delivery Partner', 'Fleet delivery partner'),
('b0d912a2-5b91-4e78-9e12-82f2812a0005', 'CUSTOMER', 'Customer', 'End user customer account')
ON CONFLICT (code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. Users Seed
-- ----------------------------------------------------------------------------
INSERT INTO users (id, email, phone, password_hash, first_name, last_name, role_id, referral_code) VALUES
('a0192384-1111-4444-8888-000000000001', 'admin@flashcart.ai', '+919999999999', '$2a$12$K12345678901234567890u123456789012345678901234567890', 'Admin', 'User', 'b0d912a2-5b91-4e78-9e12-82f2812a0002', 'ADMIN100'),
('a0192384-1111-4444-8888-000000000002', 'manager.indiranagar@flashcart.ai', '+919876543211', '$2a$12$K12345678901234567890u123456789012345678901234567890', 'Suresh', 'Kumar', 'b0d912a2-5b91-4e78-9e12-82f2812a0003', 'MGR100'),
('a0192384-1111-4444-8888-000000000003', 'rider.vikram@flashcart.ai', '+919876543212', '$2a$12$K12345678901234567890u123456789012345678901234567890', 'Vikram', 'Rider', 'b0d912a2-5b91-4e78-9e12-82f2812a0004', 'RIDER100'),
('a0192384-1111-4444-8888-000000000004', 'rahul.sharma@flashcart.ai', '+919876543210', '$2a$12$K12345678901234567890u123456789012345678901234567890', 'Rahul', 'Sharma', 'b0d912a2-5b91-4e78-9e12-82f2812a0005', 'RAHUL100')
ON CONFLICT (phone) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 3. Dark Stores Seed
-- ----------------------------------------------------------------------------
INSERT INTO dark_stores (id, code, name, pincode, service_radius_km, latitude, longitude) VALUES
('c0192384-2222-4444-8888-000000000001', 'DS-BLR-IND-01', 'FlashCart DarkStore Indiranagar', '560038', 3.50, 12.9716, 77.5946),
('c0192384-2222-4444-8888-000000000002', 'DS-BLR-KOR-02', 'FlashCart DarkStore Koramangala', '560034', 3.50, 12.9352, 77.6245)
ON CONFLICT (code) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 4. Categories & Products Seed
-- ----------------------------------------------------------------------------
INSERT INTO categories (id, name, slug, icon, color) VALUES
('cat-1001-0000-0000-000000000001', 'Fruits & Vegetables', 'fruits-vegetables', 'apple', '#10B981'),
('cat-1001-0000-0000-000000000002', 'Dairy & Breakfast', 'dairy-breakfast', 'milk', '#3B82F6'),
('cat-1001-0000-0000-000000000003', 'Munchies & Snacks', 'munchies-snacks', 'cookie', '#F59E0B')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO products (id, name, slug, category_id, base_price, unit, image_url, rating, eco_score, carbon_emission_kg, delivery_time_mins) VALUES
('p0010000-0000-0000-0000-000000000001', 'Organic Alphonso Mangoes', 'organic-alphonso-mangoes', 'cat-1001-0000-0000-000000000001', 499.00, '1 kg', 'https://images.unsplash.com/photo-1553279768-865429fa0078', 4.80, 'A', 0.120, 10),
('p0010000-0000-0000-0000-000000000002', 'Fresh Farm Whole Milk', 'fresh-farm-whole-milk', 'cat-1001-0000-0000-000000000002', 68.00, '1 L', 'https://images.unsplash.com/photo-1563636619-e9143da7973b', 4.90, 'B', 0.250, 10)
ON CONFLICT (slug) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 5. Product Stock Seed
-- ----------------------------------------------------------------------------
INSERT INTO product_stock (dark_store_id, product_id, quantity_on_hand, reorder_threshold) VALUES
('c0192384-2222-4444-8888-000000000001', 'p0010000-0000-0000-0000-000000000001', 120, 15),
('c0192384-2222-4444-8888-000000000001', 'p0010000-0000-0000-0000-000000000002', 250, 30)
ON CONFLICT (dark_store_id, product_id, variant_id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 6. User Wallets Seed
-- ----------------------------------------------------------------------------
INSERT INTO wallets (user_id, balance) VALUES
('a0192384-1111-4444-8888-000000000004', 500.00)
ON CONFLICT (user_id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 7. Coupons Seed
-- ----------------------------------------------------------------------------
INSERT INTO coupons (code, title, description, type, discount_value, min_order_amount, valid_from, valid_until) VALUES
('FLASH50', 'Flash 50 Off', 'Get Flat ₹50 OFF on orders above ₹299', 'FLAT_DISCOUNT', 50.00, 299.00, '2026-01-01 00:00:00+00', '2026-12-31 23:59:59+00')
ON CONFLICT (code) DO NOTHING;
