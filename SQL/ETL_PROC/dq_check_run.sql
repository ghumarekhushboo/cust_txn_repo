--before load to CORE Layer

INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Uniqueness of txn_id in transactions',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM (
    SELECT txn_id FROM STG.TRANSACTIONS GROUP BY txn_id HAVING COUNT(*) > 1
) t;

INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Null check in transaction amount or account_id or txn_id',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM STG.TRANSACTIONS 
WHERE amount IS NULL OR account_id IS NULL OR txn_id IS NULL;

INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Check negative transaction amounts',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM STG.TRANSACTIONS 
WHERE amount < 0;

INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Referential integrity check for transactions map to valid accounts',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM STG.TRANSACTIONS t
LEFT JOIN CORE.dim_account a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Referential integrity check for account map to valid customers',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM STG.ACCOUNTS a
LEFT JOIN CORE.dim_customer c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Currency must exist in FX rates for txn date',
    CASE WHEN COUNT(*) > 0 THEN 'FAILED' ELSE 'PASSED' END,
    COUNT(*)
FROM STG.TRANSACTIONS t
left join CORE.dim_fx_rates fx 
ON t.txn_ts::DATE = fx.fx_rate_date AND t.currency = fx.currency
WHERE fx.currency is null
AND t.currency <> 'NZD';

INSERT INTO AUDIT.DQ_CHECK_LOG (check_name, status, records_failed)
SELECT 
    'Reconciliation: Raw staging counts vs Fact records loaded',
    CASE WHEN count_stg <> count_fact THEN 'FAILED' ELSE 'PASSED' END,
    'CRITICAL',
    ABS(count_stg - count_fact)
FROM (
    SELECT 
        (SELECT COUNT(*) FROM stg.transactions WHERE business_date = CURRENT_DATE) as count_stg,
        (SELECT COUNT(*) FROM core.fact_transactions WHERE txn_date_sk = TO_CHAR(CURRENT_DATE, 'YYYYMMDD')::INT) as count_fact
) rec;
