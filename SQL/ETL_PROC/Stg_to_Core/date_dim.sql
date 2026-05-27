CREATE OR REPLACE VIEW BUSINESS.DIM_DATE AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_sk,
    d AS full_date,
    EXTRACT(DAY FROM d) AS day_number,
    EXTRACT(MONTH FROM d) AS month_number,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d) AS quarter_number,
    EXTRACT(YEAR FROM d) AS year_number,
    TO_CHAR(d, 'Day') AS day_name,
    EXTRACT(WEEK FROM d) AS week_number
FROM generate_series(DATE '2020-01-01', DATE '2030-12-31',INTERVAL '1 day') AS d;