-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 08_schema_audit_and_analytics.sql
-- Description: High-Throughput Analytics Events & Enterprise Audit Logging
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Analytics Events (Partitioned)
-- ----------------------------------------------------------------------------
CREATE TABLE analytics_events (
    id UUID DEFAULT gen_random_uuid(),
    event_name VARCHAR(100) NOT NULL,
    user_id UUID,
    session_id UUID,
    device_type VARCHAR(50),
    ip_address INET,
    properties JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Monthly Partitions for Analytics
CREATE TABLE analytics_events_2026_q3 PARTITION OF analytics_events
    FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');

CREATE TABLE analytics_events_default PARTITION OF analytics_events DEFAULT;

-- ----------------------------------------------------------------------------
-- 2. Audit Logs (Partitioned)
-- ----------------------------------------------------------------------------
CREATE TABLE audit_logs (
    id UUID DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_data JSONB,
    new_data JSONB,
    performed_by_user_id UUID,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,

    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Monthly Partitions for Audit Logs
CREATE TABLE audit_logs_2026_q3 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');

CREATE TABLE audit_logs_default PARTITION OF audit_logs DEFAULT;
