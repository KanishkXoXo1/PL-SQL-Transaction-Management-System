Enterprise PL/SQL Transaction Management System

📌 Overview

This project is an enterprise-grade database transaction management system built using Oracle PL/SQL.
It simulates how real-world systems such as banking, ERP, and financial platforms manage transactions with data integrity, performance optimization, and ACID compliance.

The system demonstrates professional-level usage of PL/SQL packages, stored procedures, triggers, sequences, indexing, and transaction control (COMMIT/ROLLBACK).

🎯 Problem Statement

In enterprise applications, handling concurrent financial or operational transactions requires:

Accurate balance updates

Prevention of invalid operations (e.g., negative balances)

High performance for large datasets

Reliable rollback in case of failures

This project addresses these challenges using PL/SQL-based transaction management.

🏗️ System Architecture


Entities
Customers: Stores customer information and account balance

Transactions: Logs all debit and credit operations

Core Components
PL/SQL Package (pkg_transaction)

Stored Procedures

Triggers for data validation

Sequences for unique transaction IDs

Indexes for performance optimization

🛠️ Tech Stack

Database: Oracle SQL

Language: PL/SQL

Tools: Oracle Live SQL, VS Code, Git, GitHub

📂 Project Structure

Enterprise-PLSQL-Transaction-System/
│
├── tables.sql                  # Database tables
├── sequences.sql               # Auto-increment transaction IDs
├── pkg_transaction.sql         # Package specification
├── pkg_transaction_body.sql    # Package implementation
├── triggers.sql                # Data integrity trigger
├── indexes.sql                 # Performance optimization
└── README.md
⚙️ How the Project Works
1️⃣ Table Creation

customers table stores customer details and balance.

transactions table records each debit/credit operation.

Foreign key ensures referential integrity.

2️⃣ Sequence Management

A database sequence generates unique transaction IDs, ensuring scalability and concurrency safety.

3️⃣ PL/SQL Package Logic

The package pkg_transaction exposes a procedure process_transaction that:

Locks the customer row (FOR UPDATE)

Validates sufficient balance for debit transactions

Performs credit or debit operations

Logs each transaction

Commits changes on success

Rolls back changes on failure

4️⃣ Trigger-Based Validation

A trigger prevents negative balances, ensuring business rules are enforced at the database level.

5️⃣ Performance Optimization

Indexes are created on frequently queried columns to reduce execution time and improve scalability.

▶️ How to Execute the Project

Execution Order (Important)
Run SQL files in this order using Oracle Live SQL:

tables.sql

sequences.sql

pkg_transaction.sql

pkg_transaction_body.sql

triggers.sql

indexes.sql

▶️ Sample Execution

Credit Transaction
BEGIN
    pkg_transaction.process_transaction(1, 'CREDIT', 3000);
END;
/
Debit Transaction
BEGIN
    pkg_transaction.process_transaction(1, 'DEBIT', 1500);
END;
/
📤 Expected Output

Customers Table
CUSTOMER_ID	CUSTOMER_NAME	BALANCE
1	Alice	Updated Balance
2	Bob	Updated Balance
Transactions Table
TXN_ID	CUSTOMER_ID	TXN_TYPE	AMOUNT	TXN_DATE
1	1	CREDIT	3000	Timestamp
2	1	DEBIT	1500	Timestamp
Error Scenario (Insufficient Balance)
ORA-20001: Insufficient balance
✔ Transaction is rolled back automatically.

🔐 Key Features

ACID-compliant transaction handling

Centralized business logic using PL/SQL packages

Automatic rollback on failure

Data integrity enforced via triggers

Optimized query performance using indexing

Enterprise-ready modular design

📈 Resume Impact

This project demonstrates:

Real-world PL/SQL development

Enterprise database design

Performance tuning

Exception handling and reliability engineering

🚀 Future Enhancements

Role-based access control

Audit logging

Bulk transaction processing

Migration to Oracle Autonomous Database
