-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 05_views.sql
-- Description: Reporting and analytical views
-- ============================================================


-- ============================================================
-- 1. CUSTOMER CARD SUMMARY VIEW
-- Shows customer, card and credit information
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_card_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    cc.card_id,
    cc.card_number,
    cc.card_type,
    cc.credit_limit,
    cc.available_credit,
    cc.outstanding_balance,
    ROUND(
        (cc.outstanding_balance / cc.credit_limit) * 100,
        2
    ) AS credit_utilization_percent,
    cc.card_status
FROM customers c
JOIN credit_cards cc
    ON c.customer_id = cc.customer_id;


-- ============================================================
-- 2. TRANSACTION SUMMARY VIEW
-- Shows transaction details with customer and merchant data
-- ============================================================

CREATE OR REPLACE VIEW vw_transaction_summary AS
SELECT
    ct.transaction_id,
    ct.transaction_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    cc.card_id,
    cc.card_type,
    m.merchant_id,
    m.merchant_name,
    mc.category_name,
    mc.risk_level AS merchant_risk_level,
    ct.transaction_amount,
    ct.transaction_type,
    ct.transaction_status,
    ct.transaction_location,
    ct.payment_channel
FROM card_transactions ct
JOIN credit_cards cc
    ON ct.card_id = cc.card_id
JOIN customers c
    ON cc.customer_id = c.customer_id
JOIN merchants m
    ON ct.merchant_id = m.merchant_id
JOIN merchant_categories mc
    ON m.category_id = mc.category_id;


-- ============================================================
-- 3. FRAUD ALERT SUMMARY VIEW
-- Shows flagged transactions and fraud details
-- ============================================================

CREATE OR REPLACE VIEW vw_fraud_alert_summary AS
SELECT
    fa.alert_id,
    fa.created_at,
    fa.alert_status,
    fa.risk_score,
    fa.fraud_reason,
    ct.transaction_id,
    ct.transaction_amount,
    ct.transaction_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    m.merchant_name,
    mc.category_name,
    mc.risk_level AS merchant_risk_level
FROM fraud_alerts fa
JOIN card_transactions ct
    ON fa.transaction_id = ct.transaction_id
JOIN credit_cards cc
    ON ct.card_id = cc.card_id
JOIN customers c
    ON cc.customer_id = c.customer_id
JOIN merchants m
    ON ct.merchant_id = m.merchant_id
JOIN merchant_categories mc
    ON m.category_id = mc.category_id;


-- ============================================================
-- 4. DAILY TRANSACTION ANALYTICS VIEW
-- Provides daily transaction metrics
-- ============================================================

CREATE OR REPLACE VIEW vw_daily_transaction_analytics AS
SELECT
    TRUNC(transaction_date) AS transaction_day,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN transaction_status IN ('APPROVED', 'FLAGGED')
            THEN transaction_amount
            ELSE 0
        END
    ) AS total_transaction_amount,
    SUM(
        CASE
            WHEN transaction_status = 'APPROVED'
            THEN 1
            ELSE 0
        END
    ) AS approved_transactions,
    SUM(
        CASE
            WHEN transaction_status = 'DECLINED'
            THEN 1
            ELSE 0
        END
    ) AS declined_transactions,
    SUM(
        CASE
            WHEN transaction_status = 'FLAGGED'
            THEN 1
            ELSE 0
        END
    ) AS flagged_transactions
FROM card_transactions
GROUP BY TRUNC(transaction_date);


-- ============================================================
-- 5. MERCHANT RISK ANALYTICS VIEW
-- Shows transaction activity by merchant
-- ============================================================

CREATE OR REPLACE VIEW vw_merchant_risk_analytics AS
SELECT
    m.merchant_id,
    m.merchant_name,
    mc.category_name,
    mc.risk_level,
    COUNT(ct.transaction_id) AS transaction_count,
    NVL(SUM(ct.transaction_amount), 0) AS total_transaction_value,
    SUM(
        CASE
            WHEN ct.transaction_status = 'FLAGGED'
            THEN 1
            ELSE 0
        END
    ) AS flagged_transaction_count
FROM merchants m
JOIN merchant_categories mc
    ON m.category_id = mc.category_id
LEFT JOIN card_transactions ct
    ON m.merchant_id = ct.merchant_id
GROUP BY
    m.merchant_id,
    m.merchant_name,
    mc.category_name,
    mc.risk_level;


-- ============================================================
-- END OF VIEW CREATION
-- ============================================================