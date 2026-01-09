CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    balance NUMBER CHECK (balance >= 0)
);

CREATE TABLE transactions (
    txn_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    txn_type VARCHAR2(10),
    amount NUMBER,
    txn_date DATE,
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
