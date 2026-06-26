# Oracle SQL Banking System

A relational database project simulating the backend of an online net banking system, built on **Oracle Database 21c XE**. Based on the Oracle University "SQL Workshop Using Oracle Autonomous Database" project brief.

## Business Scenario

A bank wants to move customer records from manual flat files to a relational database supporting online net banking — customers viewing account activity and performing transactions without visiting a branch.

## Tech Stack

- **Database:** Oracle Database 21c Express Edition (XE)
- **Client:** Oracle SQL Developer
- **Language:** SQL / PL-SQL (DDL, DML, Sequences, Views)

## Schema

5 entities, fully normalized with enforced referential integrity:

```
BANK (1) ──< CUSTOMER (M) ──< ACCOUNTS (M) ──< TRANSACTION (M)
                                    └────────< PASSWORDS (M)
```

| Table | Purpose | Primary Key |
|---|---|---|
| `BANK` | Bank branch details | `BANK_ID` |
| `CUSTOMER` | Customer profile, linked to a bank | `CUSTOMER_ID` |
| `ACCOUNTS` | Account details per customer | `ACCOUNT_NUMBER` |
| `TRANSACTION` | Debit/credit transaction log | `TRANSACTION_ID` |
| `PASSWORDS` | Password history (later dropped — see below) | `PASSWORD_ID` |

Table creation order follows foreign key dependency: a parent table must exist before any child table referencing it.

## What's implemented

- [x] 5 normalized tables with `PRIMARY KEY` / `FOREIGN KEY` / `NOT NULL` constraints
- [x] 5 `SEQUENCE` objects auto-generating primary keys (custom start values & increments)
- [x] Bulk data insertion across all tables using sequence-generated keys
- [x] `UPDATE` + `COMMIT` to correct a data-entry mistake
- [x] `DROP TABLE` / `DROP SEQUENCE` reflecting a business requirement change
- [x] Verified referential integrity — attempting to delete a parent `BANK` row with dependent children correctly raises `ORA-02292`
- [x] Two role-based `VIEW`s for access control:
  - `cce_vu` — read-only view for customer care executives, built with a `JOIN ... USING` clause
  - `ccman_vu` — view for customer care managers, built with a `JOIN ... ON` clause across 3 tables
- [x] `CREATE TABLE AS SELECT` (CTAS) combined with `NATURAL JOIN`

## Key concepts demonstrated

- **Referential integrity** — Oracle physically blocks deletes/updates that would orphan child records.
- **`USING` vs `ON` vs `NATURAL JOIN`** — three join syntaxes, each with different rules on column prefixing and use cases.
- **Sequences vs auto-increment** — Oracle's explicit, callable object (`seq.NEXTVAL`) for primary key generation, as opposed to MySQL's implicit `AUTO_INCREMENT`.
- **View-based access control** — restricting which columns different user roles (executive vs manager) can see, with `WITH READ ONLY` enforcing read-only access at the database level.

## How to run

1. Install [Oracle Database 21c XE](https://www.oracle.com/database/technologies/xe-downloads.html) and [SQL Developer](https://www.oracle.com/tools/downloads/sqldev-downloads.html).
2. Connect to your local XE instance.
3. Run `banking_system.sql` top to bottom.
4. The `DELETE FROM BANK;` statement under Phase 7 is intentionally commented out — uncomment it to reproduce the `ORA-02292` referential integrity error firsthand.

## Author

Built and documented by [Wizard1803](https://github.com/Wizard1803) as a hands-on exercise in relational database design and Oracle SQL.
