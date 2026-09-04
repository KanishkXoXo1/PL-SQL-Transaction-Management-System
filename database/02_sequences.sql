-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 02_sequences.sql
-- Description: Sequences for automatic primary key generation
-- ============================================================


-- Customer ID sequence
CREATE SEQUENCE seq_customer_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Credit Card ID sequence
CREATE SEQUENCE seq_card_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Merchant Category ID sequence
CREATE SEQUENCE seq_category_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Merchant ID sequence
CREATE SEQUENCE seq_merchant_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Transaction ID sequence
CREATE SEQUENCE seq_transaction_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Payment ID sequence
CREATE SEQUENCE seq_payment_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Fraud Alert ID sequence
CREATE SEQUENCE seq_alert_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- Audit Log ID sequence
CREATE SEQUENCE seq_audit_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- ============================================================
-- END OF SEQUENCE CREATION
-- ============================================================