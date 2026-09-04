-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 04_pkg_fraud_detection_body.sql
-- Description: Fraud risk scoring and transaction analysis
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_fraud_detection AS


    -- ========================================================
    -- CALCULATE TRANSACTION RISK SCORE
    -- ========================================================
    FUNCTION calculate_risk_score (
        p_card_id       IN NUMBER,
        p_merchant_id   IN NUMBER,
        p_amount        IN NUMBER
    ) RETURN NUMBER AS

        v_risk_score        NUMBER := 0;
        v_risk_level        VARCHAR2(10);
        v_daily_total       NUMBER := 0;
        v_recent_count      NUMBER := 0;

    BEGIN

        -- ----------------------------------------------------
        -- RULE 1: HIGH TRANSACTION AMOUNT
        -- ----------------------------------------------------
        IF p_amount >= 100000 THEN
            v_risk_score := v_risk_score + 40;
        ELSIF p_amount >= 50000 THEN
            v_risk_score := v_risk_score + 25;
        ELSIF p_amount >= 25000 THEN
            v_risk_score := v_risk_score + 10;
        END IF;


        -- ----------------------------------------------------
        -- RULE 2: HIGH-RISK MERCHANT CATEGORY
        -- ----------------------------------------------------
        SELECT mc.risk_level
        INTO v_risk_level
        FROM merchants m
        JOIN merchant_categories mc
            ON m.category_id = mc.category_id
        WHERE m.merchant_id = p_merchant_id;

        IF v_risk_level = 'HIGH' THEN
            v_risk_score := v_risk_score + 25;
        ELSIF v_risk_level = 'MEDIUM' THEN
            v_risk_score := v_risk_score + 10;
        END IF;


        -- ----------------------------------------------------
        -- RULE 3: HIGH DAILY SPENDING
        -- ----------------------------------------------------
        SELECT NVL(SUM(transaction_amount), 0)
        INTO v_daily_total
        FROM card_transactions
        WHERE card_id = p_card_id
          AND transaction_type = 'PURCHASE'
          AND transaction_status = 'APPROVED'
          AND TRUNC(transaction_date) = TRUNC(SYSDATE);

        IF v_daily_total + p_amount >= 150000 THEN
            v_risk_score := v_risk_score + 20;
        ELSIF v_daily_total + p_amount >= 100000 THEN
            v_risk_score := v_risk_score + 10;
        END IF;


        -- ----------------------------------------------------
        -- RULE 4: MULTIPLE RECENT TRANSACTIONS
        -- Checks transactions during the previous 10 minutes
        -- ----------------------------------------------------
        SELECT COUNT(*)
        INTO v_recent_count
        FROM card_transactions
        WHERE card_id = p_card_id
          AND transaction_type = 'PURCHASE'
          AND transaction_status = 'APPROVED'
          AND transaction_date >= SYSTIMESTAMP - INTERVAL '10' MINUTE;

        IF v_recent_count >= 5 THEN
            v_risk_score := v_risk_score + 20;
        ELSIF v_recent_count >= 3 THEN
            v_risk_score := v_risk_score + 10;
        END IF;


        -- Maximum risk score = 100
        IF v_risk_score > 100 THEN
            v_risk_score := 100;
        END IF;

        RETURN v_risk_score;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;

        WHEN OTHERS THEN
            RETURN 0;
    END calculate_risk_score;


    -- ========================================================
    -- CHECK IF TRANSACTION IS SUSPICIOUS
    -- ========================================================
    FUNCTION is_suspicious_transaction (
        p_card_id       IN NUMBER,
        p_merchant_id   IN NUMBER,
        p_amount        IN NUMBER
    ) RETURN VARCHAR2 AS

        v_risk_score NUMBER;

    BEGIN

        v_risk_score := calculate_risk_score(
            p_card_id,
            p_merchant_id,
            p_amount
        );

        IF v_risk_score >= 50 THEN
            RETURN 'YES';
        ELSE
            RETURN 'NO';
        END IF;

    END is_suspicious_transaction;


    -- ========================================================
    -- CREATE FRAUD ALERT
    -- ========================================================
    PROCEDURE create_fraud_alert (
        p_transaction_id IN NUMBER,
        p_risk_score     IN NUMBER,
        p_fraud_reason   IN VARCHAR2
    ) AS
    BEGIN

        INSERT INTO fraud_alerts (
            alert_id,
            transaction_id,
            risk_score,
            fraud_reason,
            alert_status,
            created_at
        )
        VALUES (
            seq_alert_id.NEXTVAL,
            p_transaction_id,
            p_risk_score,
            p_fraud_reason,
            'OPEN',
            CURRENT_TIMESTAMP
        );

    END create_fraud_alert;


    -- ========================================================
    -- ANALYZE TRANSACTION
    -- ========================================================
    PROCEDURE analyze_transaction (
        p_transaction_id IN NUMBER
    ) AS

        v_card_id           NUMBER;
        v_merchant_id       NUMBER;
        v_amount            NUMBER;
        v_risk_score        NUMBER;
        v_is_suspicious     VARCHAR2(3);
        v_reason            VARCHAR2(500);

    BEGIN

        -- Get transaction details
        SELECT
            card_id,
            merchant_id,
            transaction_amount
        INTO
            v_card_id,
            v_merchant_id,
            v_amount
        FROM card_transactions
        WHERE transaction_id = p_transaction_id;


        -- Calculate risk
        v_risk_score := calculate_risk_score(
            v_card_id,
            v_merchant_id,
            v_amount
        );


        -- Determine whether suspicious
        IF v_risk_score >= 50 THEN

            v_is_suspicious := 'YES';

            v_reason :=
                'Transaction flagged by rule-based fraud detection. '
                || 'Risk score: ' || v_risk_score;

            -- Update transaction status
            UPDATE card_transactions
            SET transaction_status = 'FLAGGED',
                remarks = v_reason
            WHERE transaction_id = p_transaction_id;

            -- Create fraud alert
            create_fraud_alert(
                p_transaction_id,
                v_risk_score,
                v_reason
            );

        ELSE

            v_is_suspicious := 'NO';

        END IF;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Transaction not found for fraud analysis.'
            );

    END analyze_transaction;

END pkg_fraud_detection;
/