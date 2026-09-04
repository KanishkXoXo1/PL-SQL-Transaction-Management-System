-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 03_pkg_fraud_detection.sql
-- Description: Package specification for fraud detection logic
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_fraud_detection AS

    -- Calculate transaction risk score
    FUNCTION calculate_risk_score (
        p_card_id       IN NUMBER,
        p_merchant_id   IN NUMBER,
        p_amount        IN NUMBER
    ) RETURN NUMBER;


    -- Check whether a transaction should be flagged
    FUNCTION is_suspicious_transaction (
        p_card_id       IN NUMBER,
        p_merchant_id   IN NUMBER,
        p_amount        IN NUMBER
    ) RETURN VARCHAR2;


    -- Create a fraud alert for a transaction
    PROCEDURE create_fraud_alert (
        p_transaction_id IN NUMBER,
        p_risk_score     IN NUMBER,
        p_fraud_reason   IN VARCHAR2
    );


    -- Check and analyze a transaction after creation
    PROCEDURE analyze_transaction (
        p_transaction_id IN NUMBER
    );

END pkg_fraud_detection;
/