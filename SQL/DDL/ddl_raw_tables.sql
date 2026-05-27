
--set schema to create below tables;
SET search_path TO RAW;

DROP TABLE IF EXISTS CUSTOMERS;
CREATE TABLE CUSTOMERS
(
customer_id varchar(50),
full_name varchar(50),
date_of_birth date,
segment varchar(50),
risk_rating varchar(20),
residential_country varchar(70),
effective_date date,
business_date date,
audit_load_date timestamp default current_timestamp
);

DROP TABLE IF EXISTS ACCOUNTS;
CREATE TABLE ACCOUNTS
(
account_id varchar(50),
customer_id varchar(50),
product_type varchar(50),
open_date date,
status varchar(20),
business_date date,
audit_load_date timestamp default current_timestamp
);

DROP TABLE IF EXISTS TRANSACTIONS;
CREATE TABLE TRANSACTIONS
(
txn_id varchar(50),
account_id varchar(50),
txn_ts timestamp,
amount decimal,
currency varchar(3),
direction varchar(10),
merchant_category varchar(50),
channel varchar(50),
narrative varchar(50),
business_date date,
audit_load_date timestamp default current_timestamp
);

DROP TABLE IF EXISTS FX_RATES;
CREATE TABLE FX_RATES
(
fx_rate_date date,
currency varchar(3),
rate_to_nzd decimal,
business_date date,
audit_load_date timestamp default current_timestamp
);