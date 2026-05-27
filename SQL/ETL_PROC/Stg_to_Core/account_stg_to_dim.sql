
--create proc
CREATE OR REPLACE PROCEDURE ETL.account_stg_to_dim(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
  
			MERGE INTO CORE.DIM_ACCOUNT as dim
USING (SELECT * FROM STG.ACCOUNTS WHERE BUSINESS_DATE = p_date) as stg
ON dim.account_id = stg.account_id
and dim.customer_id = stg.customer_id
WHEN NOT MATCHED THEN
	INSERT	(account_id
					,customer_id
					,product_type
					,open_date
					,status

					)
        		VALUES (
				account_id
					,customer_id
					,product_type
					,open_date
					,status);

        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('core.dim_account', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('core.dim_account', 0, 'FAILED', SQLERRM);


END;
$$;