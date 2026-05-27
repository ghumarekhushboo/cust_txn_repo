
--set schema
SET search_path to CORE;

DROP TABLE IF EXISTS DIM_CUSTOMER;
CREATE TABLE DIM_CUSTOMER
(
customer_sk bigint generated always as identity primary key,
customer_id varchar(50),
full_name varchar(50),
date_of_birth date,
segment varchar(50),
risk_rating varchar(20),
residential_country varchar(70),
effective_date date,
valid_from date, 
valid_to date, --compress '9999-12-31' in teradata
current_ind char(1),
audit_run_date timestamp default current_timestamp
);
--partition on valid_from with intervals in teradata

CREATE UNIQUE INDEX uidx_dim_cust_sk
on DIM_CUSTOMER (customer_sk); --PI in teradata


CREATE INDEX idx_dim_cust_id
on DIM_CUSTOMER (customer_id); -- SI in teradata

DROP TABLE IF EXISTS DIM_ACCOUNT;
CREATE TABLE DIM_ACCOUNT
(
account_sk bigint generated always as identity primary key,
account_id varchar(50) NOT NULL,
customer_id varchar(50) NOT NULL,
product_type varchar(50),
open_date date,
status varchar(20), --compress in teradata 'open', close'
audit_run_date timestamp default current_timestamp
);

CREATE UNIQUE INDEX uidx_dim_acct
on DIM_ACCOUNT (account_sk); --PI in TD


DROP TABLE IF EXISTS DIM_FX_RATES;
CREATE TABLE DIM_FX_RATES
(
fx_rate_sk bigint generated always as identity primary key,
fx_rate_date date NOT NULL,
currency varchar(3) NOT NULL,
rate_to_nzd decimal, 
audit_run_date timestamp default current_timestamp
);

CREATE UNIQUE INDEX uidx_dim_account
on dim_fx_rates  (fx_rate_sk); --PI on sk in teradata

DROP TABLE IF EXISTS FACT_TRANSACTIONS;
CREATE TABLE FACT_TRANSACTIONS (
txn_id varchar(50) NOT NULL primary key,
account_sk BIGINT NOT NULL REFERENCES dim_account(account_sk),
customer_sk BIGINT NOT NULL REFERENCES dim_customer(customer_sk),
txn_date_sk INTEGER,
txn_ts timestamp NOT NULL,
fx_rate_sk BIGINT NOT NULL REFERENCES DIM_FX_RATES(fx_rate_sk),
amount_original decimal  NOT NULL,
amount_to_nzd decimal  NOT NULL,
currency varchar(3) NOT NULL,
direction varchar(10), --compress in teradata 'DR', 'CR'
merchant_category varchar(50),
channel varchar(50), ----compress in teradata
narrative varchar(50),
audit_load_date timestamp default current_timestamp
);
--partition in TD based on txn_ts with intervals

CREATE UNIQUE INDEX uidx_fact_transactions 
on FACT_TRANSACTIONS (txn_id); ----PI in teradata


CREATE OR REPLACE VIEW DIM_DATE AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_sk,
    d AS full_date,
    EXTRACT(DAY FROM d) AS day_number,
    EXTRACT(MONTH FROM d) AS month_number,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d) AS quarter_number,
    EXTRACT(YEAR FROM d) AS year_number,
    TO_CHAR(d, 'Day') AS day_name,
    EXTRACT(WEEK FROM d) AS week_number
FROM generate_series(DATE '2020-01-01', DATE '2030-12-31',INTERVAL '1 day') AS d;
