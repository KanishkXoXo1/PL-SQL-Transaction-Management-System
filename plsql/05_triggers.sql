-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 05_triggers.sql
-- Description: Triggers for auditing and data validation
-- ============================================================


-- ============================================================
-- 1. TRANSACTION STATUS AUDIT TRIGGER
-- Logs changes in transaction status
-- ============================================================

CREATE OR REPLACE TRIGGER trg_transaction_status_audit
AFTER UPDATE OF transaction_status ON card_transactions
FOR EACH ROW
BEGIN
    IF NVL(:OLD.transaction_status, 'NULL') <>
       NVL(:NEW.transaction_status, 'NULL') THEN

        INSERT INTO transaction_audit_logs (
            audit_id,
            transaction_id,
            action_type,
            old_status,
            new_status,
            changed_at,
            changed_by
        )
        VALUES (
            seq_audit_id.NEXTVAL,
            :NEW.transaction_id,
            'STATUS_UPDATE',
            :OLD.transaction_status,
            :NEW.transaction_status,
            CURRENT_TIMESTAMP,
            USER
        );

    END IF;
END;
/