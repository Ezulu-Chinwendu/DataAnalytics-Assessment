-- 4. Customer Lifetime Value (CLV) Estimation

SELECT u.id AS customer_id, CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(CASE 
        WHEN s.confirmed_amount > 0 AND s.transaction_status = 'Success' THEN s.id 
        ELSE NULL END) AS total_transactions,
    ROUND(
        (
            COUNT(CASE 
                WHEN s.confirmed_amount > 0 AND s.transaction_status = 'Success' THEN s.id 
                ELSE NULL END
            ) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)
        ) * 12 * 0.001 * AVG(CASE 
            WHEN s.confirmed_amount > 0 AND s.transaction_status = 'Success' THEN s.confirmed_amount / 100
            ELSE NULL END
        ), 2
    ) AS estimated_clv
FROM
    users_customuser u
LEFT JOIN
    savings_savingsaccount s ON u.id = s.owner_id
GROUP BY
    u.id
ORDER BY
    estimated_clv DESC;
