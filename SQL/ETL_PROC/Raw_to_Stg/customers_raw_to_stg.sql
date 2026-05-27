
--create proc
CREATE OR REPLACE PROCEDURE ETL.customers_raw_to_stg(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    BEGIN
        INSERT INTO stg.customers
				(
				customer_id,full_name,date_of_birth,segment,risk_rating,residential_country,effective_date	
					,business_date
					)

        SELECT 	customer_id,full_name,date_of_birth,segment,risk_rating,residential_country,effective_date
					,business_date FROM raw.customers WHERE p_date not in (select distinct business_date from stg.customers );


        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('stg.customers', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('stg.customers', 0, 'FAILED', SQLERRM);
    END;

END;
$$;