-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 03_schema_catalog_and_inventory.sql
-- Description: Categories, Brands, Products, Variants, Warehouses, Dark Stores, & Stock Engine
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Categories & Hierarchy
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100) DEFAULT 'shopping-bag' NOT NULL,
    color VARCHAR(30) DEFAULT '#00B87C' NOT NULL,
    display_order INT DEFAULT 0 NOT NULL,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL
);

-- ----------------------------------------------------------------------------
-- 2. Brands
-- ----------------------------------------------------------------------------
CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    logo_url TEXT,
    description TEXT,
    website VARCHAR(255),
    is_verified BOOLEAN DEFAULT TRUE NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL
);

-- ----------------------------------------------------------------------------
-- 3. Master Products
-- ----------------------------------------------------------------------------
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    category_id UUID NOT NULL REFERENCES categories(id),
    brand_id UUID REFERENCES brands(id) ON DELETE SET NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    unit VARCHAR(50) NOT NULL, -- e.g., '1 kg', '500g', '1 L'
    image_url TEXT NOT NULL,
    rating DECIMAL(3, 2) DEFAULT 0.00 NOT NULL,
    reviews_count INT DEFAULT 0 NOT NULL,
    calories INT DEFAULT 0 NOT NULL,
    protein_grams DECIMAL(6, 2) DEFAULT 0.00 NOT NULL,
    fat_grams DECIMAL(6, 2) DEFAULT 0.00 NOT NULL,
    carbs_grams DECIMAL(6, 2) DEFAULT 0.00 NOT NULL,
    fiber_grams DECIMAL(6, 2) DEFAULT 0.00 NOT NULL,
    is_organic BOOLEAN DEFAULT FALSE NOT NULL,
    is_healthy BOOLEAN DEFAULT FALSE NOT NULL,
    eco_score eco_score DEFAULT 'B' NOT NULL,
    carbon_emission_kg DECIMAL(6, 3) DEFAULT 0.100 NOT NULL,
    badge VARCHAR(50),
    delivery_time_mins INT DEFAULT 10 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    
    -- Audit & Optimistic Locking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL,

    CONSTRAINT check_price_positive CHECK (base_price >= 0),
    CONSTRAINT check_rating_range CHECK (rating BETWEEN 0.00 AND 5.00)
);

CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ----------------------------------------------------------------------------
-- 4. Product Variants
-- ----------------------------------------------------------------------------
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    variant_name VARCHAR(100) NOT NULL, -- e.g., '500g Pack', '1kg Family Pack'
    unit VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    is_default BOOLEAN DEFAULT FALSE NOT NULL,
    attributes JSONB DEFAULT '{}'::jsonb, -- e.g., {"pack_size": "2", "flavor": "Mango"}
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL,

    CONSTRAINT check_variant_price_positive CHECK (price >= 0)
);

-- ----------------------------------------------------------------------------
-- 5. Warehouses & Dark Stores
-- ----------------------------------------------------------------------------
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE dark_stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    service_radius_km DECIMAL(4, 2) DEFAULT 3.50 NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL
);

CREATE TABLE store_managers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES dark_stores(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_primary BOOLEAN DEFAULT TRUE NOT NULL,
    UNIQUE(store_id, user_id)
);

-- ----------------------------------------------------------------------------
-- 6. Product Stock & Inventory Movements
-- ----------------------------------------------------------------------------
CREATE TABLE product_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dark_store_id UUID NOT NULL REFERENCES dark_stores(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    reorder_threshold INT DEFAULT 10 NOT NULL,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version BIGINT DEFAULT 1 NOT NULL,

    UNIQUE(dark_store_id, product_id, variant_id),
    CONSTRAINT check_stock_positive CHECK (quantity_on_hand >= 0 AND quantity_reserved >= 0)
);

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dark_store_id UUID NOT NULL REFERENCES dark_stores(id),
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    movement_type stock_movement_type NOT NULL,
    quantity_change INT NOT NULL,
    reference_id VARCHAR(100), -- Order ID or Transfer ID
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
