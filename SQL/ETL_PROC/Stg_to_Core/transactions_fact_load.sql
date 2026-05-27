--create proc
CREATE OR REPLACE PROCEDURE ETL.transactions_fact_load(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    
INSERT INTO CORE.FACT_TRANSACTIONS
(
txn_id
,account_sk
,customer_sk
,txn_date_sk
,txn_ts
,fx_rate_sk
,amount_original
,amount_to_NZD
,currency
,direction
,merchant_category
,channel
,narrative
)
SELECT 
t.txn_id,
acct.account_sk,
cust.customer_sk,
TO_CHAR(t.txn_ts, 'YYYYMMDD')::INT AS txn_date_sk,
t.txn_ts,
fx.fx_rate_sk,
t.amount as amount_original,
CASE WHEN t.currency='NZD' THEN t.amount
	ELSE (t.amount * fx.rate_to_nzd) END
	AS amount_to_NZD,
t.currency,
t.direction,
t.merchant_category,
t.channel,
t.narrative
FROM STG.TRANSACTIONS t
JOIN CORE.DIM_ACCOUNT acct
ON t.account_id=acct.account_id

JOIN CORE.DIM_CUSTOMER cust
ON acct.customer_id=cust.customer_id
AND CAST(t.txn_ts AS DATE)
        BETWEEN cust.valid_from AND cust.valid_to

JOIN CORE.DIM_FX_RATES fx
    ON CAST(t.txn_ts AS DATE) = fx.fx_rate_date
    AND t.currency = fx.currency
WHERE t.business_date = p_date
AND NOT EXISTS (SELECT 1 FROM AUDIT.ETL_LOAD_LOG where table_name = 'core.fact_transactions' and DATE(load_timestamp) = p_date)
;

   GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('core.fact_transactions', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('core.fact_transactions', 0, 'FAILED', SQLERRM);


END;
$$;