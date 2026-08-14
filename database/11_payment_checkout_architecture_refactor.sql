-- File: database/11_payment_checkout_architecture_refactor.sql
-- Production-Grade Payment + Wallet + Checkout Architecture Consolidation

-- 1. Ensure payment_transactions table has all required columns & constraints
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
    idempotency_key VARCHAR(100),
    gateway_ref VARCHAR(100),
    error_message TEXT,
    risk_score NUMERIC(5, 2) DEFAULT 0.0,
    is_flagged BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Ensure idempotency_key is UNIQUE when provided
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_payment_tx_idempotency_key'
    ) THEN
        ALTER TABLE payment_transactions ADD CONSTRAINT uq_payment_tx_idempotency_key UNIQUE (idempotency_key);
    END IF;
EXCEPTION
    WHEN OTHERS THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_payment_tx_user_id ON payment_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_order_id ON payment_transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_status ON payment_transactions(status);

-- 2. Ensure wallet_ledger table exists and has proper indexes
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

-- 3. Ensure refund_records table exists with proper status enum/check
CREATE TABLE IF NOT EXISTS refund_records (
    id VARCHAR(100) PRIMARY KEY,
    payment_id VARCHAR(100) REFERENCES payment_transactions(id) ON DELETE CASCADE,
    order_id VARCHAR(100),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    refund_type VARCHAR(20) DEFAULT 'FULL' NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'PROCESSING' NOT NULL,
    gateway_refund_id VARCHAR(100),
    approved_by VARCHAR(100) DEFAULT 'System',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_refund_records_payment_id ON refund_records(payment_id);
CREATE INDEX IF NOT EXISTS idx_refund_records_user_id ON refund_records(user_id);

-- 4. Ensure reward_ledger has reference_id for cashback & reward points idempotency
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

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'reward_ledger' AND column_name = 'reference_id'
    ) THEN
        ALTER TABLE reward_ledger ADD COLUMN reference_id VARCHAR(100);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_reward_ledger_user_id ON reward_ledger(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_ledger_ref ON reward_ledger(reference_id, type);

-- 5. Gateway logs with event_id for webhook idempotency
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

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'gateway_logs' AND column_name = 'event_id'
    ) THEN
        ALTER TABLE gateway_logs ADD COLUMN event_id VARCHAR(100);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_gateway_logs_provider_event ON gateway_logs(provider, event_id);
