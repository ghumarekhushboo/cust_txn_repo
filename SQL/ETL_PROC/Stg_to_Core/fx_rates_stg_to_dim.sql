
--create proc
CREATE OR REPLACE PROCEDURE ETL.fx_rates_stg_to_dim(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
            INSERT INTO core.dim_fx_rates
				(fx_rate_date,currency,rate_to_nzd
					)
        SELECT fx_rate_date,currency, rate_to_nzd
	 FROM stg.fx_rates stg WHERE business_date = p_date
	AND not exists (select 1 from core.dim_fx_rates c where c.fx_rate_date <> stg.fx_rate_date 
	and c.currency <> stg.currency );


        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('core.dim_fx_rates', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('core.dim_fx_rates', 0, 'FAILED', SQLERRM);


END;
$$;