WITH fact_table AS (
    SELECT transaction_id, transaction_time, scenario_id, customer_id
    FROM fact_transaction_2019
    WHERE status_id = 1
    UNION
    SELECT transaction_id, transaction_time, scenario_id, customer_id
    FROM fact_transaction_2020
    WHERE status_id = 1
),
table_billing AS (
    SELECT transaction_id, transaction_time, customer_id, sub_category,
           DATEPART(week, transaction_time) AS week_number
    FROM fact_table
    JOIN dim_scenario AS scena ON fact_table.scenario_id = scena.scenario_id
    WHERE category = 'billing' 
      AND sub_category IN ('water', 'internet', 'electricity')
),
table_week AS (
    SELECT YEAR(transaction_time) AS [year], week_number,
           COUNT(DISTINCT customer_id) AS number_customer
    FROM table_billing
    GROUP BY YEAR(transaction_time), week_number
)
SELECT *,
       AVG(number_customer) OVER (
         ORDER BY [year], week_number 
         ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
       ) AS avg_last_4_weeks
FROM table_week;


-- Monthly count of successful transactions (2019)
SELECT YEAR(transaction_time) AS [year],
       MONTH(transaction_time) AS [month],
       COUNT(transaction_id) AS number_success_trans
FROM fact_transaction_2019
GROUP BY YEAR(transaction_time), MONTH(transaction_time)
HAVING COUNT(transaction_id) > 30000;
