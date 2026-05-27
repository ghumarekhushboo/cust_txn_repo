CREATE VIEW REP.AGG_CUSTOMER_TXN_MONTHLY AS (
WITH base AS (
    SELECT
        ft.customer_sk,
        DATE_TRUNC('month', d.full_date) AS year_month,
        SUM(CASE WHEN ft.direction='DR' THEN ft.amount_to_nzd ELSE 0 END) AS total_debit_nzd,
        SUM(CASE WHEN ft.direction='CR' THEN ft.amount_to_nzd ELSE 0 END) AS total_credit_nzd,
        COUNT(*) AS txn_count,
        MODE() WITHIN GROUP (ORDER BY ft.channel) AS top_channel
    FROM CORE.fact_transactions ft
    JOIN CORE.dim_date d ON ft.txn_date_sk = d.date_sk
    GROUP BY 1, 2
)
SELECT
    *,
    CASE WHEN txn_count > 100 THEN 1 ELSE 0 END AS activity_flag
	,current_date
FROM base
);
