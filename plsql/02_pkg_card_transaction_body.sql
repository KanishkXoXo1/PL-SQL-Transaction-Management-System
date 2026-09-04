-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 02_pkg_card_transaction_body.sql
-- Description: Core transaction, refund and payment logic
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_card_transaction AS

    -- ========================================================
    -- PROCESS PURCHASE TRANSACTION
    -- ========================================================
    PROCEDURE process_transaction (
        p_card_id           IN NUMBER,
        p_merchant_id       IN NUMBER,
        p_amount            IN NUMBER,
        p_location          IN VARCHAR2,
        p_payment_channel   IN VARCHAR2,
        p_transaction_id    OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    ) AS
        v_available_credit  NUMBER;
        v_card_status       VARCHAR2(20);
        v_merchant_status   VARCHAR2(20);
        v_card_count        NUMBER;
        v_merchant_count    NUMBER;
        v_risk_score        NUMBER;
        v_fraud_reason      VARCHAR2(500);

    BEGIN
        -- Initialize output values
        p_transaction_id := NULL;
        p_status := 'DECLINED';
        p_message := NULL;

        -- Validate transaction amount
        IF p_amount IS NULL OR p_amount <= 0 THEN
            p_message := 'Transaction amount must be greater than zero.';
            RETURN;
        END IF;

        -- Validate payment channel
        IF p_payment_channel NOT IN ('ONLINE', 'POS', 'ATM', 'MOBILE') THEN
            p_message := 'Invalid payment channel.';
            RETURN;
        END IF;

        -- Check whether card exists
        SELECT COUNT(*)
        INTO v_card_count
        FROM credit_cards
        WHERE card_id = p_card_id;

        IF v_card_count = 0 THEN
            p_message := 'Card not found.';
            RETURN;
        END IF;

        -- Check whether merchant exists
        SELECT COUNT(*)
        INTO v_merchant_count
        FROM merchants
        WHERE merchant_id = p_merchant_id;

        IF v_merchant_count = 0 THEN
            p_message := 'Merchant not found.';
            RETURN;
        END IF;

        -- Lock card row and retrieve current details
        SELECT available_credit, card_status
        INTO v_available_credit, v_card_status
        FROM credit_cards
        WHERE card_id = p_card_id
        FOR UPDATE;

        -- Validate card status
        IF v_card_status <> 'ACTIVE' THEN
            p_message :=
                'Transaction declined. Card status: ' || v_card_status;
            RETURN;
        END IF;

        -- Validate available credit
        IF p_amount > v_available_credit THEN
            p_message :=
                'Transaction declined. Insufficient available credit.';
            RETURN;
        END IF;

        -- Check merchant status
        SELECT merchant_status
        INTO v_merchant_status
        FROM merchants
        WHERE merchant_id = p_merchant_id;

        IF v_merchant_status <> 'ACTIVE' THEN
            p_message :=
                'Transaction declined. Merchant is inactive.';
            RETURN;
        END IF;

        -- Calculate fraud risk before processing
        v_risk_score := pkg_fraud_detection.calculate_risk_score(
            p_card_id,
            p_merchant_id,
            p_amount
        );

        -- Determine transaction status
        IF v_risk_score >= 50 THEN

            p_status := 'FLAGGED';

            v_fraud_reason :=
                'Transaction flagged by rule-based fraud detection. '
                || 'Risk score: ' || v_risk_score;

        ELSE

            p_status := 'APPROVED';

            v_fraud_reason :=
                'Transaction processed successfully. Risk score: '
                || v_risk_score;

        END IF;

        -- Generate transaction ID
        p_transaction_id := seq_transaction_id.NEXTVAL;

        -- Create transaction
        INSERT INTO card_transactions (
            transaction_id,
            card_id,
            merchant_id,
            transaction_amount,
            transaction_type,
            transaction_status,
            transaction_date,
            transaction_location,
            payment_channel,
            remarks
        )
        VALUES (
            p_transaction_id,
            p_card_id,
            p_merchant_id,
            p_amount,
            'PURCHASE',
            p_status,
            CURRENT_TIMESTAMP,
            p_location,
            p_payment_channel,
            v_fraud_reason
        );

        -- Create fraud alert for suspicious transaction
        IF p_status = 'FLAGGED' THEN

            pkg_fraud_detection.create_fraud_alert(
                p_transaction_id,
                v_risk_score,
                v_fraud_reason
            );

        END IF;

        -- Update card balance
        UPDATE credit_cards
        SET available_credit = available_credit - p_amount,
            outstanding_balance = outstanding_balance + p_amount
        WHERE card_id = p_card_id;

        COMMIT;

        -- Final response
        IF p_status = 'FLAGGED' THEN

            p_message :=
                'Transaction processed but flagged for fraud review. '
                || 'Risk score: ' || v_risk_score;

        ELSE

            p_message :=
                'Transaction processed successfully. Risk score: '
                || v_risk_score;

        END IF;

    EXCEPTION
        WHEN OTHERS THEN

            ROLLBACK;

            p_transaction_id := NULL;
            p_status := 'DECLINED';

            p_message :=
                'Transaction failed: ' || SQLERRM;

    END process_transaction;


    -- ========================================================
    -- PROCESS REFUND
    -- ========================================================
    PROCEDURE process_refund (
        p_card_id           IN NUMBER,
        p_merchant_id       IN NUMBER,
        p_amount            IN NUMBER,
        p_location          IN VARCHAR2,
        p_transaction_id    OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    ) AS
        v_card_status           VARCHAR2(20);
        v_outstanding_balance   NUMBER;
        v_card_count            NUMBER;
        v_merchant_count        NUMBER;

    BEGIN
        p_transaction_id := NULL;
        p_status := 'DECLINED';
        p_message := NULL;

        -- Validate refund amount
        IF p_amount IS NULL OR p_amount <= 0 THEN
            p_message :=
                'Refund amount must be greater than zero.';
            RETURN;
        END IF;

        -- Check card
        SELECT COUNT(*)
        INTO v_card_count
        FROM credit_cards
        WHERE card_id = p_card_id;

        IF v_card_count = 0 THEN
            p_message := 'Card not found.';
            RETURN;
        END IF;

        -- Check merchant
        SELECT COUNT(*)
        INTO v_merchant_count
        FROM merchants
        WHERE merchant_id = p_merchant_id;

        IF v_merchant_count = 0 THEN
            p_message := 'Merchant not found.';
            RETURN;
        END IF;

        -- Lock card
        SELECT card_status, outstanding_balance
        INTO v_card_status, v_outstanding_balance
        FROM credit_cards
        WHERE card_id = p_card_id
        FOR UPDATE;

        -- Validate card status
        IF v_card_status <> 'ACTIVE' THEN
            p_message :=
                'Refund cannot be processed. Card status: '
                || v_card_status;
            RETURN;
        END IF;

        -- Validate refund amount
        IF p_amount > v_outstanding_balance THEN
            p_message :=
                'Refund amount exceeds outstanding balance.';
            RETURN;
        END IF;

        -- Generate transaction ID
        p_transaction_id := seq_transaction_id.NEXTVAL;

        -- Create refund transaction
        INSERT INTO card_transactions (
            transaction_id,
            card_id,
            merchant_id,
            transaction_amount,
            transaction_type,
            transaction_status,
            transaction_date,
            transaction_location,
            payment_channel,
            remarks
        )
        VALUES (
            p_transaction_id,
            p_card_id,
            p_merchant_id,
            p_amount,
            'REFUND',
            'APPROVED',
            CURRENT_TIMESTAMP,
            p_location,
            'POS',
            'Refund processed successfully'
        );

        -- Update card balances
        UPDATE credit_cards
        SET available_credit = available_credit + p_amount,
            outstanding_balance = outstanding_balance - p_amount
        WHERE card_id = p_card_id;

        COMMIT;

        p_status := 'APPROVED';
        p_message := 'Refund processed successfully.';

    EXCEPTION
        WHEN OTHERS THEN

            ROLLBACK;

            p_transaction_id := NULL;
            p_status := 'DECLINED';

            p_message :=
                'Refund failed: ' || SQLERRM;

    END process_refund;


    -- ========================================================
    -- PROCESS PAYMENT
    -- ========================================================
    PROCEDURE process_payment (
        p_card_id           IN NUMBER,
        p_amount            IN NUMBER,
        p_payment_method    IN VARCHAR2,
        p_payment_id        OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    ) AS
        v_outstanding_balance NUMBER;
        v_card_status         VARCHAR2(20);
        v_card_count          NUMBER;

    BEGIN
        p_payment_id := NULL;
        p_status := 'FAILED';
        p_message := NULL;

        -- Validate amount
        IF p_amount IS NULL OR p_amount <= 0 THEN
            p_message :=
                'Payment amount must be greater than zero.';
            RETURN;
        END IF;

        -- Validate payment method
        IF p_payment_method NOT IN (
            'BANK_TRANSFER',
            'UPI',
            'DEBIT_CARD',
            'CASH'
        ) THEN
            p_message := 'Invalid payment method.';
            RETURN;
        END IF;

        -- Check card
        SELECT COUNT(*)
        INTO v_card_count
        FROM credit_cards
        WHERE card_id = p_card_id;

        IF v_card_count = 0 THEN
            p_message := 'Card not found.';
            RETURN;
        END IF;

        -- Lock card
        SELECT outstanding_balance, card_status
        INTO v_outstanding_balance, v_card_status
        FROM credit_cards
        WHERE card_id = p_card_id
        FOR UPDATE;

        -- Validate card
        IF v_card_status <> 'ACTIVE' THEN
            p_message :=
                'Payment cannot be processed. Card status: '
                || v_card_status;
            RETURN;
        END IF;

        -- Validate payment amount
        IF p_amount > v_outstanding_balance THEN
            p_message :=
                'Payment amount exceeds outstanding balance.';
            RETURN;
        END IF;

        -- Generate payment ID
        p_payment_id := seq_payment_id.NEXTVAL;

        -- Record payment
        INSERT INTO payments (
            payment_id,
            card_id,
            payment_amount,
            payment_date,
            payment_method,
            payment_status
        )
        VALUES (
            p_payment_id,
            p_card_id,
            p_amount,
            CURRENT_TIMESTAMP,
            p_payment_method,
            'SUCCESS'
        );

        -- Update card balance
        UPDATE credit_cards
        SET outstanding_balance = outstanding_balance - p_amount,
            available_credit = available_credit + p_amount
        WHERE card_id = p_card_id;

        COMMIT;

        p_status := 'SUCCESS';
        p_message := 'Payment processed successfully.';

    EXCEPTION
        WHEN OTHERS THEN

            ROLLBACK;

            p_payment_id := NULL;
            p_status := 'FAILED';

            p_message :=
                'Payment failed: ' || SQLERRM;

    END process_payment;


    -- ========================================================
    -- GET AVAILABLE CREDIT
    -- ========================================================
    FUNCTION get_available_credit (
        p_card_id IN NUMBER
    ) RETURN NUMBER AS
        v_available_credit NUMBER;

    BEGIN
        SELECT available_credit
        INTO v_available_credit
        FROM credit_cards
        WHERE card_id = p_card_id;

        RETURN v_available_credit;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_available_credit;


    -- ========================================================
    -- GET OUTSTANDING BALANCE
    -- ========================================================
    FUNCTION get_outstanding_balance (
        p_card_id IN NUMBER
    ) RETURN NUMBER AS
        v_outstanding_balance NUMBER;

    BEGIN
        SELECT outstanding_balance
        INTO v_outstanding_balance
        FROM credit_cards
        WHERE card_id = p_card_id;

        RETURN v_outstanding_balance;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_outstanding_balance;


    -- ========================================================
    -- GET DAILY TRANSACTION TOTAL
    -- ========================================================
    FUNCTION get_daily_transaction_total (
        p_card_id IN NUMBER
    ) RETURN NUMBER AS
        v_total NUMBER;

    BEGIN
        SELECT NVL(SUM(transaction_amount), 0)
        INTO v_total
        FROM card_transactions
        WHERE card_id = p_card_id
          AND transaction_type = 'PURCHASE'
          AND transaction_status IN ('APPROVED', 'FLAGGED')
          AND TRUNC(transaction_date) = TRUNC(SYSDATE);

        RETURN v_total;

    END get_daily_transaction_total;

END pkg_card_transaction;
/