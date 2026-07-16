
-- BUSINESS KPI 2: Customer Lifetime Value (CLV) and Customer Rank

SELECT
    w.workspace_id,
    w.workspace_name,
    COUNT(sp.transaction_ref) AS total_successful_payments,
    SUM(sp.amount) AS lifetime_value_clv,
    ROUND(AVG(sp.amount), 2) AS average_order_value_aov,
    DENSE_RANK() OVER (ORDER BY SUM(sp.amount) DESC) AS customer_rank
FROM workspaces w
JOIN subscriptions s ON w.workspace_id = s.workspace_id
JOIN subscriptions_and_payments sp ON s.subscription_id = sp.subscription_id
WHERE sp.payment_status = 'SUCCESS'
GROUP BY w.workspace_id, w.workspace_name
ORDER BY customer_rank;