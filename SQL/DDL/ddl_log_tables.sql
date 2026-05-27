
--set schema to create below tables;
SET search_path TO AUDIT;

--create table to log data quality checks
DROP TABLE IF EXISTS DQ_CHECK_LOG;
CREATE TABLE DQ_CHECK_LOG (
    check_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    check_name TEXT,
    status TEXT, -- 'PASSED' / 'FAILED'
    records_failed INT,
    check_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--create table to log etl load
DROP TABLE IF EXISTS ETL_LOAD_LOG;
CREATE TABLE ETL_LOAD_LOG (
    log_id          BIGINT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name      VARCHAR(100),
    rows_inserted   INTEGER,
    status          VARCHAR(20),
    error_message   TEXT,
    load_timestamp  TIMESTAMP  DEFAULT CURRENT_TIMESTAMP
);