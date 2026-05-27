
--create proc
CREATE OR REPLACE PROCEDURE ETL.fx_rates_raw_to_stg(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    BEGIN
        INSERT INTO stg.fx_rates
				(fx_rate_date,currency,rate_to_nzd	
					,business_date
					)

        SELECT fx_rate_date,currency,rate_to_nzd
					,business_date FROM raw.fx_rates WHERE p_date not in (select distinct business_date from stg.fx_rates );

        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('stg.fx_rates', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('stg.fx_rates', 0, 'FAILED', SQLERRM);
    END;

END;
$$;