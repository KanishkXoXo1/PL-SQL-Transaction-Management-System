-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 06_functions.sql
-- Description: Standalone analytical and reporting functions
-- ============================================================


-- ============================================================
-- 1. GET CUSTOMER TOTAL SPENDING
-- Calculates total approved purchase spending for a customer
-- ============================================================

CREATE OR REPLACE FUNCTION fn_get_customer_total_spending (
    p_customer_id IN NUMBER
) RETURN NUMBER AS
    v_total_spending NUMBER;
BEGIN

    SELECT NVL(SUM(ct.transaction_amount), 0)
    INTO v_total_spending
    FROM credit_cards cc
    JOIN card_transactions ct
        ON cc.card_id = ct.card_id
    WHERE cc.customer_id = p_customer_id
      AND ct.transaction_type = 'PURCHASE'
      AND ct.transaction_status IN ('APPROVED', 'FLAGGED');

    RETURN v_total_spending;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/
-- ============================================================
-- 2. GET CUSTOMER TRANSACTION COUNT
-- ============================================================

CREATE OR REPLACE FUNCTION fn_get_customer_transaction_count (
    p_customer_id IN NUMBER
) RETURN NUMBER AS
    v_transaction_count NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_transaction_count
    FROM credit_cards cc
    JOIN card_transactions ct
        ON cc.card_id = ct.card_id
    WHERE cc.customer_id = p_customer_id;

    RETURN v_transaction_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/
-- ============================================================
-- 3. CALCULATE CREDIT UTILIZATION
-- Returns credit utilization percentage
-- ============================================================

CREATE OR REPLACE FUNCTION fn_calculate_credit_utilization (
    p_card_id IN NUMBER
) RETURN NUMBER AS
    v_credit_limit        NUMBER;
    v_outstanding_balance NUMBER;
BEGIN

    SELECT credit_limit, outstanding_balance
    INTO v_credit_limit, v_outstanding_balance
    FROM credit_cards
    WHERE card_id = p_card_id;

    IF v_credit_limit = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(
        (v_outstanding_balance / v_credit_limit) * 100,
        2
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/
-- ============================================================
-- 4. GET CUSTOMER FRAUD ALERT COUNT
-- ============================================================

CREATE OR REPLACE FUNCTION fn_get_fraud_alert_count (
    p_customer_id IN NUMBER
) RETURN NUMBER AS
    v_alert_count NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_alert_count
    FROM credit_cards cc
    JOIN card_transactions ct
        ON cc.card_id = ct.card_id
    JOIN fraud_alerts fa
        ON ct.transaction_id = fa.transaction_id
    WHERE cc.customer_id = p_customer_id
      AND fa.alert_status IN ('OPEN', 'UNDER_REVIEW');

    RETURN v_alert_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/