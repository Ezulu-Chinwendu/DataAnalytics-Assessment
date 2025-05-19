-- 3. Account Inactivity Alert

-- Step 1: Join plans with savings transactions and identify last transaction date per plan
WITH plan_last_txn AS (
    SELECT p.id AS plan_id, p.owner_id, p.description,
        MAX(s.transaction_date) AS last_transaction_date, p.created_on
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_deleted = 0
      AND p.is_archived = 0
    GROUP BY p.id, p.owner_id, p.description, p.created_on
),

-- Step 2: Add categorization based on description and compute inactivity
categorized_plans AS (
    SELECT plan_id, owner_id,
        CASE
            WHEN LOWER(description) LIKE '%savings%' THEN 'Savings'
            WHEN LOWER(description) LIKE '%investment%' THEN 'Investment'
            ELSE 'Other'
        END AS type,
        COALESCE(last_transaction_date, created_on) AS last_transaction_date,
        DATEDIFF(CURDATE(), COALESCE(last_transaction_date, created_on)) AS inactivity_days
    FROM plan_last_txn
)

-- Step 3: Filter for inactive accounts (365+ days of inactivity)
SELECT plan_id, owner_id, type, last_transaction_date, inactivity_days
FROM categorized_plans
WHERE inactivity_days > 365
ORDER BY inactivity_days DESC;