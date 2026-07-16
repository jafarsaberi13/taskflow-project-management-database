
-- BUSINESS KPI 1: Month-over-Month (MoM) Revenue Growth Rate


WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sp.payment_date) AS payment_month,
        SUM(sp.amount) AS total_revenue
    FROM subscriptions_and_payments sp
    JOIN subscriptions s ON sp.subscription_id = s.subscription_id
    WHERE sp.payment_status = 'SUCCESS'
    GROUP BY DATE_TRUNC('month', sp.payment_date)
),
revenue_with_lag AS (
    SELECT
        payment_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY payment_month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    TO_CHAR(payment_month, 'YYYY-MM') AS report_month,
    total_revenue AS current_month_revenue,
    COALESCE(previous_month_revenue, 0) AS previous_month_revenue,
    CASE
        WHEN previous_month_revenue IS NULL OR previous_month_revenue = 0 THEN 0.00
        ELSE ROUND(((total_revenue - previous_month_revenue) / previous_month_revenue) * 100.0, 2)
    END AS mom_growth_percentage
FROM revenue_with_lag
ORDER BY payment_month;