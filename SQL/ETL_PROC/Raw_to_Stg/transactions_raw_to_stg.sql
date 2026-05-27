
--create proc
CREATE OR REPLACE PROCEDURE ETL.transactions_raw_to_stg(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    BEGIN
        INSERT INTO stg.transactions
				(txn_id
        ,account_id
        ,txn_ts
        ,amount
        ,currency
        ,direction
        ,merchant_category
        ,channel
        ,narrative
,business_date

					)

        SELECT 	txn_id
        ,account_id
        ,txn_ts
        ,amount
        ,currency
        ,direction
        ,merchant_category
        ,channel
        ,narrative
,business_date FROM raw.transactions WHERE p_date not in (select distinct business_date from stg.transactions );



        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('raw.transactions', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('raw.transactions', 0, 'FAILED', SQLERRM);
    END;

END;
$$;