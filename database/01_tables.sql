-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 01_tables.sql
-- Description: Database tables and constraints
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone VARCHAR2(15),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_status VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (customer_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
);


-- ============================================================
-- 2. CREDIT CARDS
-- ============================================================

CREATE TABLE credit_cards (
    card_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    card_number VARCHAR2(19) NOT NULL UNIQUE,
    card_type VARCHAR2(20) NOT NULL
        CHECK (card_type IN ('VISA', 'MASTERCARD', 'AMEX')),
    credit_limit NUMBER(12,2) NOT NULL
        CHECK (credit_limit > 0),
    available_credit NUMBER(12,2) NOT NULL,
    outstanding_balance NUMBER(12,2) DEFAULT 0
        CHECK (outstanding_balance >= 0),
    card_status VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (card_status IN ('ACTIVE', 'BLOCKED', 'EXPIRED')),
    issue_date DATE DEFAULT SYSDATE,
    expiry_date DATE NOT NULL,

    CONSTRAINT fk_card_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT chk_available_credit
        CHECK (available_credit >= 0)
);


-- ============================================================
-- 3. MERCHANT CATEGORIES
-- ============================================================

CREATE TABLE merchant_categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(100) NOT NULL UNIQUE,
    risk_level VARCHAR2(10) DEFAULT 'LOW'
        CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
);


-- ============================================================
-- 4. MERCHANTS
-- ============================================================

CREATE TABLE merchants (
    merchant_id NUMBER PRIMARY KEY,
    merchant_name VARCHAR2(100) NOT NULL,
    category_id NUMBER NOT NULL,
    city VARCHAR2(100),
    country VARCHAR2(100),
    merchant_status VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (merchant_status IN ('ACTIVE', 'INACTIVE')),

    CONSTRAINT fk_merchant_category
        FOREIGN KEY (category_id)
        REFERENCES merchant_categories(category_id)
);


-- ============================================================
-- 5. TRANSACTIONS
-- ============================================================

CREATE TABLE card_transactions (
    transaction_id NUMBER PRIMARY KEY,
    card_id NUMBER NOT NULL,
    merchant_id NUMBER NOT NULL,
    transaction_amount NUMBER(12,2) NOT NULL
        CHECK (transaction_amount > 0),
    transaction_type VARCHAR2(20) DEFAULT 'PURCHASE'
        CHECK (transaction_type IN ('PURCHASE', 'REFUND')),
    transaction_status VARCHAR2(20) DEFAULT 'PENDING'
        CHECK (transaction_status IN ('PENDING', 'APPROVED', 'DECLINED', 'FLAGGED')),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_location VARCHAR2(200),
    payment_channel VARCHAR2(20)
        CHECK (payment_channel IN ('ONLINE', 'POS', 'ATM', 'MOBILE')),
    remarks VARCHAR2(500),

    CONSTRAINT fk_transaction_card
        FOREIGN KEY (card_id)
        REFERENCES credit_cards(card_id),

    CONSTRAINT fk_transaction_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchants(merchant_id)
);


-- ============================================================
-- 6. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    card_id NUMBER NOT NULL,
    payment_amount NUMBER(12,2) NOT NULL
        CHECK (payment_amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR2(30)
        CHECK (payment_method IN ('BANK_TRANSFER', 'UPI', 'DEBIT_CARD', 'CASH')),
    payment_status VARCHAR2(20) DEFAULT 'SUCCESS'
        CHECK (payment_status IN ('SUCCESS', 'FAILED', 'PENDING')),

    CONSTRAINT fk_payment_card
        FOREIGN KEY (card_id)
        REFERENCES credit_cards(card_id)
);


-- ============================================================
-- 7. FRAUD ALERTS
-- ============================================================

CREATE TABLE fraud_alerts (
    alert_id NUMBER PRIMARY KEY,
    transaction_id NUMBER NOT NULL,
    risk_score NUMBER(5,2)
        CHECK (risk_score BETWEEN 0 AND 100),
    fraud_reason VARCHAR2(500) NOT NULL,
    alert_status VARCHAR2(20) DEFAULT 'OPEN'
        CHECK (alert_status IN ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'FALSE_POSITIVE')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alert_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES card_transactions(transaction_id)
);


-- ============================================================
-- 8. TRANSACTION AUDIT LOGS
-- ============================================================

CREATE TABLE transaction_audit_logs (
    audit_id NUMBER PRIMARY KEY,
    transaction_id NUMBER,
    action_type VARCHAR2(50) NOT NULL,
    old_status VARCHAR2(20),
    new_status VARCHAR2(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR2(100) DEFAULT USER
);


-- ============================================================
-- END OF TABLE CREATION
