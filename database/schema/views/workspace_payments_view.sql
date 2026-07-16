-- SCHEMA: Workspace Payment Details View


CREATE OR REPLACE VIEW v_workspace_payment_details AS
SELECT 
    w.workspace_id,
    w.workspace_name,
    bp.name AS billing_plan_name,
    sp.transaction_ref,
    sp.amount,
    sp.payment_date,
    sp.payment_status
FROM workspaces w
JOIN billing_plans bp ON w.billing_plan_id = bp.plan_id
JOIN subscriptions s ON w.workspace_id = s.workspace_id
JOIN subscriptions_and_payments sp ON s.subscription_id = sp.subscription_id;