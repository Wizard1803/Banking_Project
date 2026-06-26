-- =====================================================================
-- ORACLE SQL BANKING SYSTEM PROJECT
-- Based on: Oracle Database 19c SQL Workshop - SLS Project Requirements
-- Tool used: Oracle Database 21c XE + SQL Developer
-- =====================================================================

-- =====================================================================
-- PHASE 1: TABLE CREATION ORDER
-- Tables must be created in dependency order (parent before child)
-- due to FOREIGN KEY constraints:
--   BANK -> CUSTOMER -> ACCOUNTS -> TRANSACTION -> PASSWORDS
-- =====================================================================

-- ---------------------------------------------------------------------
-- PHASE 2: DDL - CREATE TABLES WITH CONSTRAINTS
-- ---------------------------------------------------------------------

CREATE TABLE BANK (
    BANK_ID             VARCHAR2(20) NOT NULL,
    BANK_NAME           VARCHAR2(20) NOT NULL,
    IFSC                VARCHAR2(10) NOT NULL,
    BRANCH              VARCHAR2(20) NOT NULL,
    NUMBER_OF_CUSTOMER  NUMBER NOT NULL,
    CONSTRAINT BANK_PK PRIMARY KEY (BANK_ID)
);

CREATE TABLE CUSTOMER (
    CUSTOMER_ID     VARCHAR2(10) NOT NULL,
    CUSTOMER_NAME   VARCHAR2(30) NOT NULL,
    CUSTOMER_AGE    NUMBER NOT NULL,
    LOGIN_PASSWORD  VARCHAR2(20) NOT NULL,
    BANK_ID         VARCHAR2(20) NOT NULL,
    CONSTRAINT CUSTOMER_PK PRIMARY KEY (CUSTOMER_ID),
    CONSTRAINT CUSTOMER_BANK_FK FOREIGN KEY (BANK_ID) REFERENCES BANK(BANK_ID)
);

CREATE TABLE ACCOUNTS (
    ACCOUNT_NUMBER          VARCHAR2(20) NOT NULL,
    CUSTOMER_ID             VARCHAR2(20) NOT NULL,
    ACCOUNT_TYPE            VARCHAR2(20) NOT NULL,
    IFSC                    VARCHAR2(20) NOT NULL,
    TRANSACTION_PASSWORD    VARCHAR2(20) NOT NULL,
    ACCOUNT_CREATION_DATE   DATE NOT NULL,
    TRANSFER_LIMIT          NUMBER NOT NULL,
    MIN_BALANCE             NUMBER NOT NULL,
    CONSTRAINT ACCOUNTS_PK PRIMARY KEY (ACCOUNT_NUMBER),
    CONSTRAINT ACCOUNTS_CUSTOMER_FK FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(CUSTOMER_ID)
);

CREATE TABLE TRANSACTION (
    TRANSACTION_ID          VARCHAR2(20) NOT NULL,
    REFERENCE_NUMBER        VARCHAR2(20) NOT NULL,
    ACCOUNT_NUMBER          VARCHAR2(20) NOT NULL,
    TRANSACTION_TYPE        VARCHAR2(20) NOT NULL,
    TRANSACTION_DATE_TIME   TIMESTAMP NOT NULL,
    BANK_ID                 VARCHAR2(20) NOT NULL,
    IFSC                    VARCHAR2(20) NOT NULL,
    CONSTRAINT TRANSACTION_PK PRIMARY KEY (TRANSACTION_ID),
    CONSTRAINT TRANSACTION_ACCOUNTS_FK FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES ACCOUNTS(ACCOUNT_NUMBER),
    CONSTRAINT TRANSACTION_BANK_FK FOREIGN KEY (BANK_ID) REFERENCES BANK(BANK_ID)
);

CREATE TABLE PASSWORDS (
    PASSWORD_ID                VARCHAR2(20) NOT NULL,
    CUSTOMER_ID                 VARCHAR2(20) NOT NULL,
    ACCOUNT_NUMBER              VARCHAR2(20) NOT NULL,
    OLD_LOGIN_PASSWORD          VARCHAR2(20) NOT NULL,
    NEW_LOGIN_PASSWORD          VARCHAR2(20) NOT NULL,
    CREATION_DATE_TIME          TIMESTAMP NOT NULL,
    NEW_TRANSACTION_PASSWORD    VARCHAR2(20) NOT NULL,
    OLD_TRANSACTION_PASSWORD    VARCHAR2(20) NOT NULL,
    TRANSACTION_DATE_TIME       TIMESTAMP NOT NULL,
    CONSTRAINT PASSWORD_PK PRIMARY KEY (PASSWORD_ID),
    CONSTRAINT PASSWORDS_ACCOUNTS_FK FOREIGN KEY (ACCOUNT_NUMBER) REFERENCES ACCOUNTS(ACCOUNT_NUMBER),
    CONSTRAINT PASSWORDS_CUSTOMER_FK FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(CUSTOMER_ID)
);

-- ---------------------------------------------------------------------
-- PHASE 3: SEQUENCES (auto-generate Primary Key values)
-- ---------------------------------------------------------------------

CREATE SEQUENCE seq_bank_id     START WITH 1001  INCREMENT BY 1;
CREATE SEQUENCE seq_customer    START WITH 10001 INCREMENT BY 1;
CREATE SEQUENCE seq_account     START WITH 101   INCREMENT BY 1;
CREATE SEQUENCE seq_transaction START WITH 1     INCREMENT BY 1;
CREATE SEQUENCE seq_password    START WITH 5001  INCREMENT BY 1;

-- ---------------------------------------------------------------------
-- PHASE 4: DML - INSERT DATA
-- ---------------------------------------------------------------------

-- BANK (1 row - master entity)
INSERT INTO BANK (BANK_ID, IFSC, BRANCH, NUMBER_OF_CUSTOMER, BANK_NAME)
VALUES (seq_bank_id.NEXTVAL, '1001123456', 'Bangalore', 0, 'CITYBANK');

-- CUSTOMER (5 rows, all linked to BANK_ID = 1001)
INSERT INTO CUSTOMER VALUES (seq_customer.NEXTVAL, 'Kng',    22, 'abc1234',  '1001');
INSERT INTO CUSTOMER VALUES (seq_customer.NEXTVAL, 'Riya',   25, 'pass5678', '1001');
INSERT INTO CUSTOMER VALUES (seq_customer.NEXTVAL, 'Aman',   30, 'secure99', '1001');
INSERT INTO CUSTOMER VALUES (seq_customer.NEXTVAL, 'Sara',   28, 'mypwd456', '1001');
INSERT INTO CUSTOMER VALUES (seq_customer.NEXTVAL, 'Vikram', 35, 'login321', '1001');

-- ACCOUNTS (5 rows, one per customer 10001-10005)
INSERT INTO ACCOUNTS VALUES (seq_account.NEXTVAL, '10001', 'SAVINGS', '1001123456', 'trancs1234', SYSDATE, 50000,  1000);
INSERT INTO ACCOUNTS VALUES (seq_account.NEXTVAL, '10002', 'CURRENT', '1001123456', 'trancs5678', SYSDATE, 100000, 5000);
INSERT INTO ACCOUNTS VALUES (seq_account.NEXTVAL, '10003', 'SALARY',  '1001123456', 'trancs9999', SYSDATE, 75000,  0);
INSERT INTO ACCOUNTS VALUES (seq_account.NEXTVAL, '10004', 'SAVINGS', '1001123456', 'trancs4567', SYSDATE, 40000,  500);
INSERT INTO ACCOUNTS VALUES (seq_account.NEXTVAL, '10005', 'CURRENT', '1001123456', 'trancs7890', SYSDATE, 60000,  2000);

-- TRANSACTION (5 rows, one per account 101-105)
INSERT INTO TRANSACTION VALUES (seq_transaction.NEXTVAL, 'REF10001', '101', 'DEBIT',  SYSTIMESTAMP, '1001', '1001123456');
INSERT INTO TRANSACTION VALUES (seq_transaction.NEXTVAL, 'REF10002', '102', 'CREDIT', SYSTIMESTAMP, '1001', '1001123456');
INSERT INTO TRANSACTION VALUES (seq_transaction.NEXTVAL, 'REF10003', '103', 'DEBIT',  SYSTIMESTAMP, '1001', '1001123456');
INSERT INTO TRANSACTION VALUES (seq_transaction.NEXTVAL, 'REF10004', '104', 'CREDIT', SYSTIMESTAMP, '1001', '1001123456');
INSERT INTO TRANSACTION VALUES (seq_transaction.NEXTVAL, 'REF10005', '105', 'DEBIT',  SYSTIMESTAMP, '1001', '1001123456');

-- PASSWORDS (5 rows, mapped customer-to-account)
INSERT INTO PASSWORDS VALUES (seq_password.NEXTVAL, '10001', '101', 'Abcd', 'Asdf', SYSTIMESTAMP, 'QWER', 'ZXCV', SYSTIMESTAMP);
INSERT INTO PASSWORDS VALUES (seq_password.NEXTVAL, '10002', '102', 'Efgh', 'Jklm', SYSTIMESTAMP, 'RTYU', 'BNVC', SYSTIMESTAMP);
INSERT INTO PASSWORDS VALUES (seq_password.NEXTVAL, '10003', '103', 'Ijkl', 'Nopq', SYSTIMESTAMP, 'FGHJ', 'XSWQ', SYSTIMESTAMP);
INSERT INTO PASSWORDS VALUES (seq_password.NEXTVAL, '10004', '104', 'Mnop', 'Stuv', SYSTIMESTAMP, 'KLPO', 'CVBN', SYSTIMESTAMP);
INSERT INTO PASSWORDS VALUES (seq_password.NEXTVAL, '10005', '105', 'Qrst', 'Wxyz', SYSTIMESTAMP, 'ASDF', 'MNBV', SYSTIMESTAMP);

-- ---------------------------------------------------------------------
-- PHASE 5: DML - UPDATE + COMMIT
-- Fix a data-entry mistake: customer 10001's name and transfer limit
-- ---------------------------------------------------------------------

UPDATE CUSTOMER
SET CUSTOMER_NAME = 'King'
WHERE CUSTOMER_ID = '10001';

UPDATE ACCOUNTS
SET TRANSFER_LIMIT = 75000
WHERE CUSTOMER_ID = '10001';

COMMIT;

-- ---------------------------------------------------------------------
-- PHASE 6: DDL - DROP OBJECTS
-- Business decision: third-party auth replaces in-house password storage
-- ---------------------------------------------------------------------

DROP TABLE PASSWORDS;
DROP SEQUENCE seq_password;

-- ---------------------------------------------------------------------
-- PHASE 7: REFERENTIAL INTEGRITY TEST
-- Demonstrates that Oracle blocks deletion of a parent row that still
-- has dependent (child) rows in CUSTOMER / TRANSACTION.
--
-- Running this line throws:
--   ORA-02292: integrity constraint (SYSTEM.TRANSACTION_BANK_FK)
--   violated - child record found
--
-- Kept commented so the script can run end-to-end without halting.
-- ---------------------------------------------------------------------

-- DELETE FROM BANK;

-- ---------------------------------------------------------------------
-- PHASE 8: VIEWS (role-based restricted access)
-- ---------------------------------------------------------------------

-- View for Customer Care Executives (READ ONLY, uses USING clause)
CREATE OR REPLACE VIEW cce_vu AS
SELECT CUSTOMER_ID, CUSTOMER_NAME, ACCOUNT_NUMBER, ACCOUNT_TYPE
FROM CUSTOMER
JOIN ACCOUNTS USING (CUSTOMER_ID)
WITH READ ONLY;

-- View for Customer Care Managers (uses ON clause, chained join across 3 tables)
CREATE OR REPLACE VIEW ccman_vu AS
SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER_NAME, ACCOUNTS.ACCOUNT_NUMBER, ACCOUNT_TYPE,
       TRANSACTION_ID, TRANSACTION_TYPE, TRANSACTION_DATE_TIME
FROM CUSTOMER
JOIN ACCOUNTS ON CUSTOMER.CUSTOMER_ID = ACCOUNTS.CUSTOMER_ID
JOIN TRANSACTION ON ACCOUNTS.ACCOUNT_NUMBER = TRANSACTION.ACCOUNT_NUMBER;

-- ---------------------------------------------------------------------
-- PHASE 9: CREATE TABLE AS SELECT (CTAS) with NATURAL JOIN
-- ---------------------------------------------------------------------

CREATE TABLE bank_cust_copy AS
SELECT BANK_ID, BANK_NAME, CUSTOMER_ID, CUSTOMER_NAME
FROM BANK
NATURAL JOIN CUSTOMER;

-- =====================================================================
-- VERIFICATION QUERIES (optional, run individually to sanity check)
-- =====================================================================

-- SELECT * FROM bank_cust_copy;
-- SELECT * FROM cce_vu;
-- SELECT * FROM ccman_vu;
-- INSERT INTO cce_vu (CUSTOMER_ID, CUSTOMER_NAME, ACCOUNT_NUMBER, ACCOUNT_TYPE)
--   VALUES ('99999','Test','999','TEST'); -- expected to fail (READ ONLY view)
