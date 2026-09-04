# PL/SQL Transaction Management System

A Transaction Management System built using Oracle SQL and PL/SQL.

## Features

- Customer management
- Debit transactions
- Credit transactions
- Automatic balance updates
- Transaction history tracking
- Insufficient balance validation
- Prevention of negative balances
- Database trigger implementation
- PL/SQL package implementation

## Technologies Used

- Oracle Database
- Oracle SQL Developer
- SQL
- PL/SQL

## Database Components

### Tables
- CUSTOMERS
- TRANSACTIONS

### Sequence
- TRANSACTIONS_SEQ

### Index
- IDX_CUSTOMER_ID

### Trigger
- PREVENT_NEGATIVE_BALANCE

### Package
- PKG_TRANSACTION

## Transaction Process

The system processes transactions using the following procedure:

```sql
pkg_transaction.process_transaction