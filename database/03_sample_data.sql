-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 03_sample_data.sql
-- Description: Sample data for testing and demonstration
-- ============================================================


-- ============================================================
-- 1. MERCHANT CATEGORIES
-- ============================================================

INSERT INTO merchant_categories
VALUES (seq_category_id.NEXTVAL, 'Grocery', 'LOW');

INSERT INTO merchant_categories
VALUES (seq_category_id.NEXTVAL, 'Fuel', 'MEDIUM');

INSERT INTO merchant_categories
VALUES (seq_category_id.NEXTVAL, 'Electronics', 'MEDIUM');

INSERT INTO merchant_categories
VALUES (seq_category_id.NEXTVAL, 'Travel', 'HIGH');

INSERT INTO merchant_categories
VALUES (seq_category_id.NEXTVAL, 'Luxury', 'HIGH');


-- ============================================================
-- 2. CUSTOMERS
-- ============================================================

INSERT INTO customers (
    customer_id, first_name, last_name, email,
    phone, date_of_birth, customer_status
)
VALUES (
    seq_customer_id.NEXTVAL,
    'Rahul',
    'Sharma',
    'rahul.sharma@email.com',
    '9876543210',
    DATE '1995-06-15',
    'ACTIVE'
);

INSERT INTO customers (
    customer_id, first_name, last_name, email,
    phone, date_of_birth, customer_status
)
VALUES (
    seq_customer_id.NEXTVAL,
    'Priya',
    'Verma',
    'priya.verma@email.com',
    '9876543211',
    DATE '1997-09-22',
    'ACTIVE'
);

INSERT INTO customers (
    customer_id, first_name, last_name, email,
    phone, date_of_birth, customer_status
)
VALUES (
    seq_customer_id.NEXTVAL,
    'Amit',
    'Kumar',
    'amit.kumar@email.com',
    '9876543212',
    DATE '1992-03-10',
    'ACTIVE'
);

INSERT INTO customers (
    customer_id, first_name, last_name, email,
    phone, date_of_birth, customer_status
)
VALUES (
    seq_customer_id.NEXTVAL,
    'Neha',
    'Singh',
    'neha.singh@email.com',
    '9876543213',
    DATE '1998-11-05',
    'ACTIVE'
);


-- ============================================================
-- 3. CREDIT CARDS
-- ============================================================

INSERT INTO credit_cards (
    card_id, customer_id, card_number, card_type,
    credit_limit, available_credit, outstanding_balance,
    card_status, issue_date, expiry_date
)
VALUES (
    seq_card_id.NEXTVAL,
    1,
    '378282246310005',
    'AMEX',
    100000,
    85000,
    15000,
    'ACTIVE',
    DATE '2025-01-01',
    DATE '2029-01-01'
);

INSERT INTO credit_cards (
    card_id, customer_id, card_number, card_type,
    credit_limit, available_credit, outstanding_balance,
    card_status, issue_date, expiry_date
)
VALUES (
    seq_card_id.NEXTVAL,
    2,
    '4111111111111111',
    'VISA',
    75000,
    60000,
    15000,
    'ACTIVE',
    DATE '2025-03-01',
    DATE '2029-03-01'
);

INSERT INTO credit_cards (
    card_id, customer_id, card_number, card_type,
    credit_limit, available_credit, outstanding_balance,
    card_status, issue_date, expiry_date
)
VALUES (
    seq_card_id.NEXTVAL,
    3,
    '5555555555554444',
    'MASTERCARD',
    50000,
    45000,
    5000,
    'ACTIVE',
    DATE '2025-05-01',
    DATE '2028-05-01'
);

INSERT INTO credit_cards (
    card_id, customer_id, card_number, card_type,
    credit_limit, available_credit, outstanding_balance,
    card_status, issue_date, expiry_date
)
VALUES (
    seq_card_id.NEXTVAL,
    4,
    '378734493671000',
    'AMEX',
    200000,
    180000,
    20000,
    'BLOCKED',
    DATE '2024-01-01',
    DATE '2028-01-01'
);


-- ============================================================
-- 4. MERCHANTS
-- ============================================================

INSERT INTO merchants (
    merchant_id, merchant_name, category_id,
    city, country, merchant_status
)
VALUES (
    seq_merchant_id.NEXTVAL,
    'Fresh Mart',
    1,
    'Bengaluru',
    'India',
    'ACTIVE'
);

INSERT INTO merchants (
    merchant_id, merchant_name, category_id,
    city, country, merchant_status
)
VALUES (
    seq_merchant_id.NEXTVAL,
    'Indian Oil',
    2,
    'Mysuru',
    'India',
    'ACTIVE'
);

INSERT INTO merchants (
    merchant_id, merchant_name, category_id,
    city, country, merchant_status
)
VALUES (
    seq_merchant_id.NEXTVAL,
    'Tech World',
    3,
    'Mumbai',
    'India',
    'ACTIVE'
);

INSERT INTO merchants (
    merchant_id, merchant_name, category_id,
    city, country, merchant_status
)
VALUES (
    seq_merchant_id.NEXTVAL,
    'Global Travels',
    4,
    'Delhi',
    'India',
    'ACTIVE'
);

INSERT INTO merchants (
    merchant_id, merchant_name, category_id,
    city, country, merchant_status
)
VALUES (
    seq_merchant_id.NEXTVAL,
    'Luxury Hub',
    5,
    'Dubai',
    'UAE',
    'ACTIVE'
);


-- ============================================================
-- 5. INITIAL PAYMENTS
-- ============================================================

INSERT INTO payments (
    payment_id, card_id, payment_amount,
    payment_date, payment_method, payment_status
)
VALUES (
    seq_payment_id.NEXTVAL,
    1,
    5000,
    CURRENT_TIMESTAMP,
    'UPI',
    'SUCCESS'
);

INSERT INTO payments (
    payment_id, card_id, payment_amount,
    payment_date, payment_method, payment_status
)
VALUES (
    seq_payment_id.NEXTVAL,
    2,
    3000,
    CURRENT_TIMESTAMP,
    'BANK_TRANSFER',
    'SUCCESS'
);


-- ============================================================
-- COMMIT SAMPLE DATA
-- ============================================================

COMMIT;


-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

SELECT * FROM customers;
SELECT * FROM credit_cards;
SELECT * FROM merchant_categories;
SELECT * FROM merchants;
SELECT * FROM payments;