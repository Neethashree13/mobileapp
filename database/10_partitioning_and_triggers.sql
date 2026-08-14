-- ============================================================================
-- FlashCart AI - PostgreSQL 17 Production Schema
-- File: 10_partitioning_and_triggers.sql
-- Description: Automated Timestamping, Optimistic Lock Incrementing, & Audit Log Triggers
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Automatic Timestamp & Version Trigger Function
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_touch_updated_at_and_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply Timestamp & Version Triggers to Key Entities
CREATE TRIGGER trg_users_touch
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at_and_version();

CREATE TRIGGER trg_products_touch
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at_and_version();

CREATE TRIGGER trg_dark_stores_touch
    BEFORE UPDATE ON dark_stores
    FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at_and_version();

CREATE TRIGGER trg_payments_touch
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at_and_version();

-- ----------------------------------------------------------------------------
-- 2. Audit Trail Trigger Function
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_audit_log_change()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id UUID;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_record_id := OLD.id;
        INSERT INTO audit_logs (table_name, record_id, action, old_data)
        VALUES (TG_TABLE_NAME, v_record_id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        v_record_id := NEW.id;
        INSERT INTO audit_logs (table_name, record_id, action, old_data, new_data)
        VALUES (TG_TABLE_NAME, v_record_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        v_record_id := NEW.id;
        INSERT INTO audit_logs (table_name, record_id, action, new_data)
        VALUES (TG_TABLE_NAME, v_record_id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply Audit Log Triggers to Core Security & Financial Tables
CREATE TRIGGER trg_audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_audit_log_change();

CREATE TRIGGER trg_audit_payments
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION fn_audit_log_change();

CREATE TRIGGER trg_audit_wallets
    AFTER INSERT OR UPDATE OR DELETE ON wallets
    FOR EACH ROW EXECUTE FUNCTION fn_audit_log_change();
