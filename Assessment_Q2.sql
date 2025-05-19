-- 2. Transaction Frequency Analysis

-- Step 1: Calculate total transactions and active months per customer
WITH customer_months AS (
    SELECT s.owner_id, COUNT(*) AS total_transactions, 
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
),

-- Step 2: Compute average monthly transactions per customer
customer_avg_transactions AS (
    SELECT owner_id, total_transactions, active_months,
        ROUND(total_transactions / NULLIF(active_months, 0), 2) AS avg_transactions_per_month
    FROM customer_months
),

-- Step 3: Categorize each customer based on frequency
categorized AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_transactions_per_month
    FROM customer_avg_transactions
)

-- Step 4: Aggregate results by category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');