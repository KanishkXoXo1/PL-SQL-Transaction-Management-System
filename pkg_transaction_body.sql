CREATE OR REPLACE PACKAGE BODY pkg_transaction AS

    PROCEDURE process_transaction (
        p_customer_id IN NUMBER,
        p_txn_type IN VARCHAR2,
        p_amount IN NUMBER
    ) AS
        v_balance NUMBER;
    BEGIN
        SELECT balance INTO v_balance
        FROM customers
        WHERE customer_id = p_customer_id
        FOR UPDATE;

        IF p_txn_type = 'DEBIT' THEN
            IF v_balance < p_amount THEN
                RAISE_APPLICATION_ERROR(-20001, 'Insufficient balance');
            END IF;

            UPDATE customers
            SET balance = balance - p_amount
            WHERE customer_id = p_customer_id;

        ELSIF p_txn_type = 'CREDIT' THEN
            UPDATE customers
            SET balance = balance + p_amount
            WHERE customer_id = p_customer_id;
        END IF;

        INSERT INTO transactions
        VALUES (
            transactions_seq.NEXTVAL,
            p_customer_id,
            p_txn_type,
            p_amount,
            SYSDATE
        );

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END process_transaction;

END pkg_transaction;
/
