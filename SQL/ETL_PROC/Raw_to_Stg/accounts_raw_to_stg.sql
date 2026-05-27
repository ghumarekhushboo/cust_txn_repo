
--create proc
CREATE OR REPLACE PROCEDURE ETL.accounts_raw_to_stg(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    BEGIN
        INSERT INTO stg.accounts
				(
					account_id
					,customer_id
					,product_type
					,open_date
					,status
					,business_date
					)

        SELECT 	account_id
					,customer_id
					,product_type
					,open_date
					,status
					,business_date FROM raw.accounts WHERE p_date not in (select distinct business_date from stg.accounts );


        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('stg.accounts', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('stg.accounts', 0, 'FAILED', SQLERRM);
    END;

END;
$$;