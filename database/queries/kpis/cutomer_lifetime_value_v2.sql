
SELECT
    workspace_id,
    workspace_name,
    COUNT(transaction_ref) AS total_successful_payments,
    SUM(amount) AS lifetime_value,
    ROUND(AVG(amount), 2) AS average_order_value,
    DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS customer_rank
FROM v_workspace_payment_details
WHERE payment_status = 'SUCCESS'
GROUP BY workspace_id, workspace_name
ORDER BY customer_rank;