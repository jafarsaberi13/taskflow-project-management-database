
--  BUSINESS KPI 3: Paying Customer Churn Rate (90-Day Inactivity)


WITH paying_workspaces AS (
    SELECT
        w.workspace_id,
        MAX(sp.payment_date) AS last_payment_date
    FROM workspaces w
    JOIN subscriptions s ON w.workspace_id = s.workspace_id
    JOIN subscriptions_and_payments sp ON s.subscription_id = sp.subscription_id
    WHERE sp.payment_status = 'SUCCESS'
    GROUP BY w.workspace_id
),
churn_classification AS (
    SELECT
        workspace_id,
        last_payment_date,
        CASE
            WHEN last_payment_date < NOW() - INTERVAL '90 days' THEN 1
            ELSE 0
        END AS is_churned
    FROM paying_workspaces
)
SELECT
    COUNT(*) AS total_active_paying_customers,
    SUM(is_churned) AS churned_customers_count,
    ROUND((SUM(is_churned)::NUMERIC / COUNT(*)) * 100.0, 2) AS churn_rate_percentage
FROM churn_classification;