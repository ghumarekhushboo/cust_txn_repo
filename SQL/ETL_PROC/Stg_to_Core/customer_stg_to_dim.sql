
--create proc
CREATE OR REPLACE PROCEDURE ETL.customer_stg_to_dim(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    
       
					MERGE INTO CORE.DIM_CUSTOMER as dim
						USING (select * from stg.CUSTOMERS where business_date = p_date) as stg
						ON dim.customer_id = stg.customer_id
						and dim.current_ind ='Y'
						WHEN MATCHED AND (
						dim.segment <> stg.segment
						or dim.risk_rating <> stg.risk_rating
						or dim.residential_country <> stg.residential_country
						) 
						THEN UPDATE 
						SET 
						current_ind ='N', 
						valid_to = current_date-1
						WHEN NOT MATCHED THEN
						INSERT
						(
						customer_id
						,full_name
						,date_of_birth
						,segment
						,risk_rating
						,residential_country
						,effective_date
						,valid_from 
						,valid_to
						,current_ind
						)
						VALUES ( 
						customer_id
						,full_name
						,date_of_birth
						,segment
						,risk_rating
						,residential_country
						,effective_date
						,current_date
						,'9999-12-31'
						,'Y'
						)
						;


        GET DIAGNOSTICS v_count = ROW_COUNT;

        INSERT INTO audit.etl_load_log(table_name, rows_inserted, status)
        VALUES ('core.dim_customer', v_count, 'SUCCESS');

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO audit.etl_load_log(table_name,rows_inserted, status, error_message)
        VALUES ('core.dim_customer', 0, 'FAILED', SQLERRM);
    END;


$$;