-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 04_indexes.sql
-- Description: Indexes for frequently queried columns
-- ============================================================


-- ============================================================
-- 1. CREDIT CARD INDEXES
-- ============================================================

CREATE INDEX idx_credit_cards_customer
ON credit_cards(customer_id);

CREATE INDEX idx_credit_cards_status
ON credit_cards(card_status);


-- ============================================================
-- 2. MERCHANT INDEXES
-- ============================================================

CREATE INDEX idx_merchants_category
ON merchants(category_id);


-- ============================================================
-- 3. TRANSACTION INDEXES
-- ============================================================

CREATE INDEX idx_transactions_card
ON card_transactions(card_id);

CREATE INDEX idx_transactions_merchant
ON card_transactions(merchant_id);

CREATE INDEX idx_transactions_date
ON card_transactions(transaction_date);

CREATE INDEX idx_transactions_status
ON card_transactions(transaction_status);


-- ============================================================
-- 4. PAYMENT INDEXES
-- ============================================================

CREATE INDEX idx_payments_card
ON payments(card_id);

CREATE INDEX idx_payments_date
ON payments(payment_date);


-- ============================================================
-- 5. FRAUD ALERT INDEXES
-- ============================================================

CREATE INDEX idx_fraud_alert_transaction
ON fraud_alerts(transaction_id);

CREATE INDEX idx_fraud_alert_status
ON fraud_alerts(alert_status);


-- ============================================================
-- 6. AUDIT LOG INDEXES
-- ============================================================

CREATE INDEX idx_audit_transaction
ON transaction_audit_logs(transaction_id);

CREATE INDEX idx_audit_changed_at
ON transaction_audit_logs(changed_at);


-- ============================================================
-- END OF INDEX CREATION
-- ============================================================