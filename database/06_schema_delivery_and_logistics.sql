-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 06_schema_delivery_and_logistics.sql
-- Description: Delivery Partners, Fleet Vehicles, Assignments, & Partitioned GPS Tracking
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Fleet Vehicles & Delivery Partners
-- ----------------------------------------------------------------------------
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_plate VARCHAR(50) NOT NULL UNIQUE,
    vehicle_type vehicle_type NOT NULL,
    brand_model VARCHAR(100),
    is_electric BOOLEAN DEFAULT FALSE NOT NULL,
    battery_level_percent INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE delivery_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    status rider_status DEFAULT 'OFFLINE' NOT NULL,
    current_store_id UUID REFERENCES dark_stores(id) ON DELETE SET NULL,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    rating DECIMAL(3, 2) DEFAULT 5.00 NOT NULL,
    total_deliveries INT DEFAULT 0 NOT NULL,
    kyc_verified BOOLEAN DEFAULT FALSE NOT NULL,
    
    -- Audit & Versioning
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 1 NOT NULL,

    CONSTRAINT check_partner_rating_range CHECK (rating BETWEEN 0.00 AND 5.00)
);

-- ----------------------------------------------------------------------------
-- 2. Delivery Assignments
-- ----------------------------------------------------------------------------
CREATE TABLE delivery_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL, -- Order reference
    delivery_partner_id UUID NOT NULL REFERENCES delivery_partners(id),
    status delivery_assignment_status DEFAULT 'OFFERED' NOT NULL,
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivery_time TIMESTAMP WITH TIME ZONE,
    distance_km DECIMAL(5, 2) NOT NULL,
    earnings_inr DECIMAL(8, 2) NOT NULL,
    cancellation_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version BIGINT DEFAULT 1 NOT NULL
);

-- ----------------------------------------------------------------------------
-- 3. High-Frequency Delivery GPS Tracking (Partitioned)
-- ----------------------------------------------------------------------------
CREATE TABLE delivery_tracking (
    id UUID DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES delivery_assignments(id) ON DELETE CASCADE,
    delivery_partner_id UUID NOT NULL REFERENCES delivery_partners(id),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    speed_kmh DECIMAL(5, 2) DEFAULT 0.00,
    heading_degrees DECIMAL(5, 2),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    PRIMARY KEY (id, recorded_at)
) PARTITION BY RANGE (recorded_at);

-- Monthly Partitions for GPS Tracking
CREATE TABLE delivery_tracking_2026_q3 PARTITION OF delivery_tracking
    FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');

CREATE TABLE delivery_tracking_default PARTITION OF delivery_tracking DEFAULT;
