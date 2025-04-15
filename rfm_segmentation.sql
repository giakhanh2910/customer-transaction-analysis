WITH join_table AS (
    SELECT customer_id, transaction_time, charged_amount
    FROM fact_transaction_2019 AS fact_19
    JOIN dim_scenario AS scen ON fact_19.scenario_id = scen.scenario_id
    WHERE status_id = '1' AND sub_category = 'Telco card'
    UNION
    SELECT customer_id, transaction_time, charged_amount
    FROM fact_transaction_2020 AS fact_20
    JOIN dim_scenario AS scen ON fact_20.scenario_id = scen.scenario_id
    WHERE status_id = '1' AND sub_category = 'Telco card'
),
t_rfm AS (
    SELECT customer_id,
           DATEDIFF(day, MAX(transaction_time), '2020-12-31') AS recency, -- Days since last transaction
           COUNT(DISTINCT CONVERT(varchar, transaction_time, 112)) AS frequency, -- Days transacted
           SUM(charged_amount * 1.0) AS monetary
    FROM join_table
    GROUP BY customer_id
),
t_rank AS (
    SELECT *,
           PERCENT_RANK() OVER (ORDER BY recency ASC) AS r_rank,
           PERCENT_RANK() OVER (ORDER BY frequency DESC) AS f_rank,
           PERCENT_RANK() OVER (ORDER BY monetary DESC) AS m_rank
    FROM t_rfm
),
t_tier AS (
    SELECT *,
           CASE WHEN r_rank > 0.75 THEN 4
                WHEN r_rank > 0.5 THEN 3
                WHEN r_rank > 0.25 THEN 2
                ELSE 1 END AS r_tier,
           CASE WHEN f_rank > 0.75 THEN 4
                WHEN f_rank > 0.5 THEN 3
                WHEN f_rank > 0.25 THEN 2
                ELSE 1 END AS f_tier,
           CASE WHEN m_rank > 0.75 THEN 4
                WHEN m_rank > 0.5 THEN 3
                WHEN m_rank > 0.25 THEN 2
                ELSE 1 END AS m_tier
    FROM t_rank
),
t_score AS (
    SELECT *,
           CONCAT(r_tier, f_tier, m_tier) AS rfm_score
    FROM t_tier
)
SELECT *,
       CASE
           WHEN rfm_score = '111' THEN 'Best Customers'
           WHEN rfm_score LIKE '[3-4][3-4][1-4]' THEN 'Lost Bad Customer'
           WHEN rfm_score LIKE '[3-4]2[1-4]' THEN 'Lost Customers'
           WHEN rfm_score LIKE '21[1-4]' THEN 'Almost Lost'
           WHEN rfm_score LIKE '11[2-4]' THEN 'Loyal Customers'
           WHEN rfm_score LIKE '[1-2][1-3]1' THEN 'Big Spenders'
           WHEN rfm_score LIKE '[1-2]4[1-4]' THEN 'New Customers'
           WHEN rfm_score LIKE '[3-4]1[1-4]' THEN 'Hibernating'
           WHEN rfm_score LIKE '[1-2][2-3][2-4]' THEN 'Potential Loyalists'
           ELSE 'Unknown'
       END AS segment_label
FROM t_score;
