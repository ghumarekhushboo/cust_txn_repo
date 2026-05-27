
# cust_txn_repo

# Project Title : Customer Transaction Data Warehouse 
# Description
The Customer Transaction Data Warehouse provides analytics ready view of customer and transaction data across the bank. It integrates customer master data, account information, daily FX rates, and transaction events into a dimensional model that supports reporting.
This document outlines the end to end architecture, including data ingestion, storage layers, transformation logic, dimensional modelling, and aggregation/reporting layer.
# High Level Architecture Flow
The architecture consists of different layers to consume the source and load the data warehouse

Source Files -> Raw Layer -> Stg Layer -> Core Layer -> Rep Layer
Layer details are as below:
-	Source Files:
   For data entities Customers, Accounts, Transactions, Fx_rates are available as csv files at a location
-	Raw Layer:   Exact copy of source files. No Transformations. Truncate and load.
-	Stg Layer: accumulates data loaded from Raw Layer
-	Core Layer: This contains dims & facts. Model is available in the folder.

	dim_customer – SCD2, one row per customer per historical version

	dim_account – account attributes one row per account (can maintain SCD 2 based on status)

	dim_date –calendar dimension

	dim_fx_rate – daily FX rates per currency

	fact_transactions - one row per transaction

-	Rep Layer: This contains aggregated table/views.
	agg_customer_txn_monthly - one row per customer per month.
	
# Key considerations:
-	SCD Type 2 used for dim_customer to track historical changes
-	Surrogate keys used for all dimensions with SK
-	FX conversion performed at load time using dim_fx_rate to load fact transactions
-	Aggregate table created to improve dashboard performance, currently created as view
-	Star schema chosen for simplicity and query efficiency
-	Date dimension used as a view

# Other Considerations:
-	Partitioning fact tables by transaction date
-	Indexing on surrogate keys for stg(hist) and dim tables for performance
-	String data type is currently carried as varchar same across all layers but can be converted/trimmed or fixed based on specifications and for performance.
-	Business date column is introduced for backfill or reruns based on data loaded in stg for a file load date which could be different than the load/run date
-	Indexing to be used on key/id columns of stg(hist) tables for performance on loading dim/fact layer. PI in Teradata can be used on SKs for evenly distribution of data.
-	Compress added on repeating values in ddl
-	Schemas maintained are as below:

RAW -> ingest the files

STG-> maintains data

CORE-> contains dim/facts

REP-> contains aggregated tables

ETL-> Transformation/load Procedures

AUDIT-> logs job runs and Data Quality check results.


# Execution steps:
# DDL
-	Execute DDLs & Schema sql files from the folder “SQL\DDL”. 
-	Schemas are as below: 

RAW -> ingest the files

STG-> maintains data

CORE-> contains dim/facts

REP-> contains aggregated tables

ETL-> Transformation/load Procedures

AUDIT-> logs job runs and Data Quality check results.

-	Create Procedures RAW to STG & STG to CORE load present under SQL\ETL_CORE folder.
-	Execute below layers. Note for Every ETL load there is a row present in ETL_LOAD_LOG table for the job run for all the layers from files -> RAW -> STG -> CORE

# LOAD FILES TO RAW
-	Place the data files in the directory and specify the path in config.py
-	All the load scripts are present under folder “Scripts_job_load” 
-	Provided csv files are available at the file path mentioned in the config file.
-	Make changes in the config.py for db connection details, file path and schema
-	Run below command to execute the file load to raw tables: pass the file date you want to process which also gets loaded into the raw table as business date.
```
python load_accounts_file_to_raw.py 2026-01-01
python load_customers_file_to_raw.py 2026-01-01
python load_transactions_file_to_raw.py 2026-01-01
python load_fx_rates_file_to_raw.py 2026-01-01
```

-	check logs in “select * from audit.ETL_LOAD_LOG order by load_timestamp desc;”
-	Handles rerun
# LOAD RAW TO STG
-	Execute below procedures to load data from raw to stg based on dates.
```
CALL ETL.accounts_raw_to_stg('2026-01-01');
CALL ETL.fx_rates_raw_to_stg ('2026-01-01');
CALL ETL.transactions_raw_to_stg ('2026-01-01');
CALL ETL.customers_raw_to_stg ('2026-01-01');
```

-	check logs in “select * from audit.ETL_LOAD_LOG order by load_timestamp desc;”
-	Even if the CALL statements are executed twice it won’t load the data twice handles rerun.
 
# LOAD STG TO CORE
-	Execute dq_check_run.sql file before loading the CORE layer to check data quality.
-	Execute below procedures to load data from stg to core based on run dates.
```
CALL ETL.customer_stg_to_dim('2026-01-01');
CALL ETL.fx_rates_stg_to_dim('2026-01-01');
CALL ETL.account_stg_to_dim('2026-01-01');
CALL ETL. transactions_fact_load ('2026-01-01');
```
-	check logs in “select * from audit.ETL_LOAD_LOG order by load_timestamp desc;”

