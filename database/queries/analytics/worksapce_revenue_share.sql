SELECT 
    bp.name AS billing_plan_name,
    w.workspace_name AS company_name,
    sp.transaction_ref,
    sp.amount AS payment_amount,
    SUM(sp.amount) OVER (PARTITION BY bp.plan_id) AS total_plan_revenue,
    ROUND(
        (sp.amount * 100.0) / SUM(sp.amount) OVER (PARTITION BY bp.plan_id), 
        2
    ) AS revenue_percentage_share
FROM billing_plans bp
JOIN workspaces w ON bp.plan_id = w.billing_plan_id
JOIN subscriptions s ON w.workspace_id = s.workspace_id
JOIN subscriptions_and_payments sp ON s.subscription_id = sp.subscription_id
WHERE sp.payment_status = 'SUCCESS'
ORDER BY billing_plan_name, revenue_percentage_share DESC;