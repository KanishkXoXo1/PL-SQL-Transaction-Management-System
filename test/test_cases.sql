-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: test_cases.sql
-- Description: Complete test cases
-- ============================================================

SET SERVEROUTPUT ON;


-- ============================================================
-- TEST 1: SUCCESSFUL TRANSACTION
-- ============================================================

DECLARE
    v_transaction_id NUMBER;
    v_status         VARCHAR2(20);
    v_message        VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_transaction(
        p_card_id         => 1,
        p_merchant_id     => 1,
        p_amount          => 2000,
        p_location        => 'Bengaluru, India',
        p_payment_channel => 'POS',
        p_transaction_id  => v_transaction_id,
        p_status          => v_status,
        p_message         => v_message
    );

    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 1: SUCCESSFUL TRANSACTION');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || v_transaction_id);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

END;
/


-- ============================================================
-- TEST 2: INSUFFICIENT CREDIT
-- ============================================================

DECLARE
    v_transaction_id NUMBER;
    v_status         VARCHAR2(20);
    v_message        VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_transaction(
        p_card_id         => 3,
        p_merchant_id     => 3,
        p_amount          => 100000,
        p_location        => 'Mumbai, India',
        p_payment_channel => 'ONLINE',
        p_transaction_id  => v_transaction_id,
        p_status          => v_status,
        p_message         => v_message
    );

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 2: INSUFFICIENT CREDIT');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

END;
/


-- ============================================================
-- TEST 3: BLOCKED CARD
-- ============================================================

DECLARE
    v_transaction_id NUMBER;
    v_status         VARCHAR2(20);
    v_message        VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_transaction(
        p_card_id         => 4,
        p_merchant_id     => 1,
        p_amount          => 1000,
        p_location        => 'Delhi, India',
        p_payment_channel => 'POS',
        p_transaction_id  => v_transaction_id,
        p_status          => v_status,
        p_message         => v_message
    );

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 3: BLOCKED CARD');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

END;
/


-- ============================================================
-- TEST 4: SUCCESSFUL PAYMENT
-- ============================================================

DECLARE
    v_payment_id NUMBER;
    v_status     VARCHAR2(20);
    v_message    VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_payment(
        p_card_id        => 1,
        p_amount         => 3000,
        p_payment_method => 'UPI',
        p_payment_id     => v_payment_id,
        p_status         => v_status,
        p_message        => v_message
    );

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 4: SUCCESSFUL PAYMENT');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Payment ID: ' || v_payment_id);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

END;
/


-- ============================================================
-- TEST 5: SUCCESSFUL REFUND
-- ============================================================

DECLARE
    v_transaction_id NUMBER;
    v_status         VARCHAR2(20);
    v_message        VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_refund(
        p_card_id        => 1,
        p_merchant_id    => 1,
        p_amount         => 1000,
        p_location       => 'Bengaluru, India',
        p_transaction_id => v_transaction_id,
        p_status         => v_status,
        p_message        => v_message
    );

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 5: SUCCESSFUL REFUND');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || v_transaction_id);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

END;
/


-- ============================================================
-- TEST 6: HIGH-RISK / FRAUD TRANSACTION
-- ============================================================

DECLARE
    v_transaction_id NUMBER;
    v_status         VARCHAR2(20);
    v_message        VARCHAR2(500);
BEGIN

    pkg_card_transaction.process_transaction(
        p_card_id         => 1,
        p_merchant_id     => 5,
        p_amount          => 60000,
        p_location        => 'Dubai, UAE',
        p_payment_channel => 'ONLINE',
        p_transaction_id  => v_transaction_id,
        p_status          => v_status,
        p_message         => v_message
    );

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 6: HIGH-RISK TRANSACTION');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || v_transaction_id);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

    IF v_status = 'FLAGGED' THEN
        DBMS_OUTPUT.PUT_LINE(
            'Fraud alert created automatically.'
        );
    END IF;

END;
/


-- ============================================================
-- TEST 7: PACKAGE FUNCTIONS
-- ============================================================

DECLARE
    v_available_credit    NUMBER;
    v_outstanding_balance NUMBER;
    v_daily_total         NUMBER;
BEGIN

    v_available_credit :=
        pkg_card_transaction.get_available_credit(1);

    v_outstanding_balance :=
        pkg_card_transaction.get_outstanding_balance(1);

    v_daily_total :=
        pkg_card_transaction.get_daily_transaction_total(1);

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TEST 7: CARD SUMMARY FUNCTIONS');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE(
        'Available Credit: ' || v_available_credit
    );
    DBMS_OUTPUT.PUT_LINE(
        'Outstanding Balance: ' || v_outstanding_balance
    );
    DBMS_OUTPUT.PUT_LINE(
        'Today''s Transaction Total: ' || v_daily_total
    );

END;
/


-- ============================================================
-- TEST 8: ANALYTICAL FUNCTIONS
-- ============================================================

SELECT
    fn_get_customer_total_spending(1)
        AS total_customer_spending
FROM dual;

SELECT
    fn_get_customer_transaction_count(1)
        AS total_transaction_count
FROM dual;

SELECT
    fn_calculate_credit_utilization(1)
        AS credit_utilization_percentage
FROM dual;

SELECT
    fn_get_fraud_alert_count(1)
        AS active_fraud_alert_count
FROM dual;


-- ============================================================
-- FINAL VERIFICATION QUERIES
-- ============================================================

SELECT * FROM vw_customer_card_summary;

SELECT *
FROM vw_transaction_summary
ORDER BY transaction_date DESC;

SELECT *
FROM vw_fraud_alert_summary
ORDER BY created_at DESC;

SELECT *
FROM vw_daily_transaction_analytics;

SELECT *
FROM vw_merchant_risk_analytics;

SELECT *
FROM transaction_audit_logs
ORDER BY changed_at DESC;