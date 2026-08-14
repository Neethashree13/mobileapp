-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 01_extensions_and_enums.sql
-- Description: Core PostgreSQL extensions, custom domains, and enterprise enums
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PostgreSQL Extensions
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Trigram matching for fast text search
CREATE EXTENSION IF NOT EXISTS "btree_gist";    -- Multi-column GIST indexes

-- ----------------------------------------------------------------------------
-- 2. Domain Custom Types & Enums
-- ----------------------------------------------------------------------------

-- User & Auth Enums
CREATE TYPE user_role AS ENUM (
    'CUSTOMER',
    'RIDER',
    'STORE_MANAGER',
    'DARK_STORE_PICKER',
    'ADMIN',
    'SUPER_ADMIN'
);

CREATE TYPE user_status AS ENUM (
    'PENDING_VERIFICATION',
    'ACTIVE',
    'SUSPENDED',
    'BANNED',
    'DEACTIVATED'
);

CREATE TYPE auth_provider AS ENUM (
    'LOCAL',
    'GOOGLE',
    'APPLE',
    'PHONE_OTP'
);

-- Catalog & Product Enums
CREATE TYPE eco_score AS ENUM ('A', 'B', 'C', 'D', 'E');

CREATE TYPE stock_movement_type AS ENUM (
    'RESTOCK',
    'SALE_DEDUCTION',
    'RETURN_RESTOCK',
    'DAMAGED_EXPIRED',
    'AUDIT_ADJUSTMENT',
    'INTER_STORE_TRANSFER'
);

-- Order & Delivery Enums
CREATE TYPE order_status AS ENUM (
    'PLACED',
    'CONFIRMED',
    'PICKING',
    'PACKED',
    'ASSIGNED_TO_RIDER',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED',
    'REFUNDED',
    'RETURNED'
);

CREATE TYPE delivery_assignment_status AS ENUM (
    'OFFERED',
    'ACCEPTED',
    'REJECTED',
    'PICKED_UP',
    'DELIVERED',
    'CANCELLED'
);

CREATE TYPE rider_status AS ENUM (
    'OFFLINE',
    'AVAILABLE',
    'ON_DELIVERY',
    'ON_BREAK'
);

CREATE TYPE vehicle_type AS ENUM (
    'BICYCLE',
    'E_SCOOTER',
    'MOTORCYCLE',
    'THREE_WHEELER'
);

-- Financial & Payment Enums
CREATE TYPE payment_method AS ENUM (
    'UPI',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'FLASHCART_WALLET',
    'NET_BANKING',
    'CASH_ON_DELIVERY'
);

CREATE TYPE payment_status AS ENUM (
    'PENDING',
    'PROCESSING',
    'SUCCESSFUL',
    'FAILED',
    'REFUNDED',
    'PARTIALLY_REFUNDED'
);

CREATE TYPE wallet_transaction_type AS ENUM (
    'TOP_UP',
    'ORDER_PAYMENT',
    'CASHBACK',
    'REFUND',
    'REFERRAL_BONUS',
    'RIDER_EARNING_PAYOUT'
);

-- Coupon & Engagement Enums
CREATE TYPE coupon_type AS ENUM (
    'PERCENTAGE',
    'FLAT_DISCOUNT',
    'FREE_DELIVERY',
    'BUY_X_GET_Y'
);

CREATE TYPE ticket_status AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'WAITING_ON_CUSTOMER',
    'RESOLVED',
    'CLOSED'
);

CREATE TYPE ticket_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');
