# customer-transaction-analysis (SQL)
This project showcases SQL-based data analysis performed on customer transaction data from two years: 2019 and 2020. The analysis focuses on customer billing behaviors, weekly trends, and monthly transaction success rates.

# Objectives

- Combine and filter transaction records from multiple years.
- Analyze weekly customer billing activity.
- Calculate moving averages over 4-week windows.
- Identify months with high transaction volumes.

# Data Sources

- fact_transaction_2019
- fact_transaction_2020
- dim_scenario

# SQL Techniques Used

- Common Table Expressions (CTEs)
- Window Functions (AVG OVER)
- Conditional Filters
- Aggregation and Grouping
- JOIN operations

# Sample Queries

'''sql
-- Weekly billing activity with moving average
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
'''
____
# RFM Customer Segmentation (SQL)

This query demonstrates an RFM (Recency, Frequency, Monetary) segmentation model using SQL on telecommunications transaction data.

- *Recency*: How recently a customer made a transaction
- *Frequency*: How often they made transactions
- *Monetary*: How much money they spent

# Key Steps:

- Data preparation and filtering (Telco card transactions only)
- Calculate RFM values per customer
- Use PERCENT_RANK() to assign percentile ranks for scoring
- Use CASE logic to convert percentiles to R/F/M tiers
- Concatenate scores to assign final RFM score
- Segment customers into groups like "Best Customers", "Loyal Customers", "Big Spenders" etc.

This logic helps stakeholders better target customer campaigns.
