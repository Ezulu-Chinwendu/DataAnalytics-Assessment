-- 1. High-Value Customers with Multiple Products

-- Step 1: Get all users with at least one funded savings account
WITH funded_savings AS (
    SELECT owner_id, COUNT(*) AS savings_count, SUM(amount) AS total_savings
    FROM savings_savingsaccount
    WHERE amount > 0
    GROUP BY owner_id
),
-- Step 2: Get all users with at least one funded plan
funded_plans AS (
    SELECT owner_id, COUNT(*) AS investment_count
    FROM plans_plan
    WHERE amount > 0
    GROUP BY owner_id
)

-- Step 3: Join users with both savings and plan data
SELECT u.id AS owner_id, CONCAT(u.first_name, ' ', u.last_name) AS name, 
fs.savings_count, fp.investment_count, fs.total_savings AS total_deposits
FROM users_customuser u
JOIN funded_savings fs ON u.id = fs.owner_id
JOIN funded_plans fp ON u.id = fp.owner_id
ORDER BY total_deposits DESC;
