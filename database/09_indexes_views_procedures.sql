-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 09_indexes_views_procedures.sql
-- Description: Indexes, Views, Materialized Views, and Stored Procedures
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. High-Performance Indexes
-- ----------------------------------------------------------------------------

-- Trigram Index on Products for Sub-100ms Fuzzy Search
CREATE INDEX idx_products_search_trgm ON products USING gin (name gin_trgm_ops);
CREATE INDEX idx_products_category ON products(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_brand ON products(brand_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_eco_active ON products(eco_score, is_active) WHERE deleted_at IS NULL;

-- Inventory & Stock Indexes
CREATE INDEX idx_stock_store_product ON product_stock(dark_store_id, product_id);
CREATE INDEX idx_stock_low_inventory ON product_stock(dark_store_id) WHERE quantity_on_hand <= reorder_threshold;

-- Users & Auth Indexes
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_sessions_user_active ON user_sessions(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_addresses_user ON addresses(user_id) WHERE deleted_at IS NULL;

-- Orders & Delivery Indexes
CREATE INDEX idx_orders_user ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_store_status ON orders(dark_store_id, status);
CREATE INDEX idx_delivery_assignments_partner ON delivery_assignments(delivery_partner_id, status);

-- ----------------------------------------------------------------------------
-- 2. Views & Materialized Views
-- ----------------------------------------------------------------------------

-- View: Active Inventory with Product Details
CREATE OR REPLACE VIEW vw_active_inventory AS
SELECT 
    ps.id AS stock_id,
    ds.id AS dark_store_id,
    ds.name AS dark_store_name,
    p.id AS product_id,
    p.name AS product_name,
    p.base_price,
    ps.quantity_on_hand,
    ps.quantity_reserved,
    (ps.quantity_on_hand - ps.quantity_reserved) AS quantity_available,
    ps.reorder_threshold,
    CASE WHEN (ps.quantity_on_hand - ps.quantity_reserved) <= ps.reorder_threshold THEN TRUE ELSE FALSE END AS needs_reorder
FROM product_stock ps
JOIN dark_stores ds ON ps.dark_store_id = ds.id
JOIN products p ON ps.product_id = p.id
WHERE p.deleted_at IS NULL AND p.is_active = TRUE AND ds.is_active = TRUE;

-- Materialized View: Daily Dark Store Sales Analytics
CREATE MATERIALIZED VIEW mv_daily_sales_analytics AS
SELECT 
    o.dark_store_id,
    DATE_TRUNC('day', o.created_at) AS sales_date,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS gross_revenue,
    SUM(o.discount_amount) AS total_discounts,
    AVG(o.total_amount) AS average_order_value,
    AVG(o.estimated_delivery_time_mins) AS avg_delivery_time_mins
FROM orders o
WHERE o.status = 'DELIVERED'
GROUP BY o.dark_store_id, DATE_TRUNC('day', o.created_at);

CREATE UNIQUE INDEX idx_mv_daily_sales ON mv_daily_sales_analytics(dark_store_id, sales_date);

-- View: Delivery Partner Performance Metrics
CREATE OR REPLACE VIEW vw_delivery_partner_performance AS
SELECT 
    dp.id AS delivery_partner_id,
    u.first_name || ' ' || u.last_name AS rider_name,
    dp.status,
    dp.rating,
    COUNT(da.id) AS total_assignments,
    COUNT(CASE WHEN da.status = 'DELIVERED' THEN 1 END) AS successful_deliveries,
    AVG(EXTRACT(EPOCH FROM (da.delivery_time - da.pickup_time))/60) AS avg_fulfillment_mins
FROM delivery_partners dp
JOIN users u ON dp.user_id = u.id
LEFT JOIN delivery_assignments da ON dp.id = da.delivery_partner_id
GROUP BY dp.id, u.first_name, u.last_name, dp.status, dp.rating;

-- ----------------------------------------------------------------------------
-- 3. Stored Procedures & Transaction Functions
-- ----------------------------------------------------------------------------

-- Function: Atomic Inventory Reservation on Order Placement
CREATE OR REPLACE FUNCTION fn_reserve_inventory(
    p_dark_store_id UUID,
    p_product_id UUID,
    p_quantity INT
) RETURNS BOOLEAN AS $$
DECLARE
    v_available_stock INT;
BEGIN
    -- Lock row for update
    SELECT (quantity_on_hand - quantity_reserved) INTO v_available_stock
    FROM product_stock
    WHERE dark_store_id = p_dark_store_id AND product_id = p_product_id
    FOR UPDATE;

    IF v_available_stock IS NULL OR v_available_stock < p_quantity THEN
        RETURN FALSE;
    END IF;

    -- Deduct stock & increment reserved
    UPDATE product_stock
    SET quantity_reserved = quantity_reserved + p_quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE dark_store_id = p_dark_store_id AND product_id = p_product_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Procedure: Refresh Materialized Views (Scheduled Job)
CREATE OR REPLACE PROCEDURE proc_refresh_analytics()
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_analytics;
END;
$$ LANGUAGE plpgsql;
