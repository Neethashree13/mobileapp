-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 05_schema_payments_and_wallets.sql
-- Description: Financial Transactions, Payments, Gateway Logs, & User Wallets
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Payments Engine
-- ----------------------------------------------------------------------------
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL, -- Logical reference to partitioned orders
    user_id UUID NOT NULL REFERENCES users(id),
    payment_method payment_method NOT NULL,
    payment_status payment_status DEFAULT 'PENDING' NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR' NOT NULL,
    gateway_reference VARCHAR(255),
    gateway_name VARCHAR(50), -- e.g., 'RAZORPAY', 'CASHFREE', 'STRIPE'
    gateway_response JSONB DEFAULT '{}'::jsonb,
    error_message TEXT,
    paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit & Versioning
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version BIGINT DEFAULT 1 NOT NULL,

    CONSTRAINT check_payment_amount_positive CHECK (amount > 0)
);

CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'AUTHORIZATION', 'CAPTURE', 'REFUND'
    amount DECIMAL(10, 2) NOT NULL,
    status payment_status NOT NULL,
    gateway_transaction_id VARCHAR(255),
    raw_payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ----------------------------------------------------------------------------
-- 2. User Wallets
-- ----------------------------------------------------------------------------
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR' NOT NULL,
    is_frozen BOOLEAN DEFAULT FALSE NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version BIGINT DEFAULT 1 NOT NULL,

    CONSTRAINT check_wallet_balance_non_negative CHECK (balance >= 0.00)
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type wallet_transaction_type NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    balance_before DECIMAL(10, 2) NOT NULL,
    balance_after DECIMAL(10, 2) NOT NULL,
    reference_id VARCHAR(100), -- Order ID or TopUp ID
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT check_balance_calculation CHECK (
        (type IN ('TOP_UP', 'CASHBACK', 'REFUND', 'REFERRAL_BONUS', 'RIDER_EARNING_PAYOUT') AND balance_after = balance_before + amount)
        OR
        (type IN ('ORDER_PAYMENT') AND balance_after = balance_before - amount)
    )
);
