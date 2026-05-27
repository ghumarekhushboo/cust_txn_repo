CREATE DATABASE CUST_TXN_DB;

--file to db load (trun & load)
DROP SCHEMA IF EXISTS RAW;
CREATE SCHEMA RAW;

--maintains data
DROP SCHEMA IF EXISTS STG;
CREATE SCHEMA STG;

--Dim & facts layer
DROP SCHEMA IF EXISTS CORE;
CREATE SCHEMA CORE;

--Reporting/agg layer
DROP SCHEMA IF EXISTS REP;
CREATE SCHEMA REP;

----Transformation layer for procs
DROP SCHEMA IF EXISTS ETL;
CREATE SCHEMA ETL;

--Logging job runs, data quality and error handling
DROP SCHEMA IF EXISTS AUDIT;
CREATE SCHEMA AUDIT;