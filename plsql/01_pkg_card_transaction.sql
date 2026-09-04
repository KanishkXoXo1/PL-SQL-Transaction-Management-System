-- ============================================================
-- CREDIT CARD TRANSACTION & FRAUD MANAGEMENT SYSTEM
-- File: 01_pkg_card_transaction.sql
-- Description: Package specification for card transactions
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_card_transaction AS

    -- Process a new card purchase transaction
    PROCEDURE process_transaction (
        p_card_id           IN NUMBER,
        p_merchant_id       IN NUMBER,
        p_amount            IN NUMBER,
        p_location          IN VARCHAR2,
        p_payment_channel   IN VARCHAR2,
        p_transaction_id    OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    );


    -- Process a refund transaction
    PROCEDURE process_refund (
        p_card_id           IN NUMBER,
        p_merchant_id       IN NUMBER,
        p_amount            IN NUMBER,
        p_location          IN VARCHAR2,
        p_transaction_id    OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    );


    -- Process a credit card payment
    PROCEDURE process_payment (
        p_card_id           IN NUMBER,
        p_amount            IN NUMBER,
        p_payment_method    IN VARCHAR2,
        p_payment_id        OUT NUMBER,
        p_status            OUT VARCHAR2,
        p_message           OUT VARCHAR2
    );


    -- Get available credit for a card
    FUNCTION get_available_credit (
        p_card_id IN NUMBER
    ) RETURN NUMBER;


    -- Get outstanding balance for a card
    FUNCTION get_outstanding_balance (
        p_card_id IN NUMBER
    ) RETURN NUMBER;


    -- Get total transactions made today
    FUNCTION get_daily_transaction_total (
        p_card_id IN NUMBER
    ) RETURN NUMBER;

END pkg_card_transaction;
/