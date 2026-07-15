WITH workspace_billing_summary AS (
    SELECT 
        w.workspace_id,
        w.workspace_name,
        bp.name AS current_plan,
        COUNT(sp.payment_id) AS total_payments_count,
        COALESCE(SUM(sp.amount), 0) AS total_revenue,
        MAX(sp.payment_date) AS last_payment_date
    FROM workspaces w
    JOIN billing_plans bp ON w.billing_plan_id = bp.plan_id
    LEFT JOIN subscriptions s ON w.workspace_id = s.workspace_id
    LEFT JOIN subscriptions_and_payments sp ON s.subscription_id = sp.subscription_id AND sp.payment_status = 'SUCCESS'
    GROUP BY w.workspace_id, w.workspace_name, bp.name
)
SELECT 
    workspace_id,
    workspace_name,
    current_plan,
    total_payments_count,
    total_revenue,
    last_payment_date,
    CASE 
        -- VIP Client: At least 3 successful payments AND last payment is recent (After March 1st, 2025)
        WHEN total_payments_count >= 3 AND last_payment_date >= '2025-03-01' THEN 'VIP Client'
        
        -- Active Client: Has made successful payments but doesn't meet the VIP threshold
        WHEN total_payments_count > 0 THEN 'Active Client'
        
        -- Inactive / Idle: Workspaces on free tiers or with zero successful transactions
        ELSE 'Inactive / Idle'
    END AS client_segment
FROM workspace_billing_summary
ORDER BY total_revenue DESC, total_payments_count DESC;