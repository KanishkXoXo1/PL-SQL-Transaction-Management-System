CREATE OR REPLACE PACKAGE pkg_transaction AS
    PROCEDURE process_transaction (
        p_customer_id IN NUMBER,
        p_txn_type IN VARCHAR2,
        p_amount IN NUMBER
    );
END pkg_transaction;
/

