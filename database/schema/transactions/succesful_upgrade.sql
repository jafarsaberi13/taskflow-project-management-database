BEGIN TRANSACTION;

UPDATE workspaces 
SET billing_plan_id = (SELECT plan_id FROM billing_plans WHERE name = 'Enterprise' LIMIT 1)
WHERE workspace_id = (SELECT workspace_id FROM workspaces ORDER BY workspace_id LIMIT 1);

INSERT INTO subscriptions (workspace_id, status, subscription_start_date, subscription_end_date)
VALUES ((SELECT workspace_id FROM workspaces ORDER BY workspace_id LIMIT 1), 'ACTIVE', NOW(), NOW() + INTERVAL '1 year');

INSERT INTO subscriptions_and_payments (subscription_id, amount, transaction_ref, payment_status, payment_date)
VALUES (
    (SELECT subscription_id FROM subscriptions WHERE workspace_id = (SELECT workspace_id FROM workspaces ORDER BY workspace_id LIMIT 1) ORDER BY subscription_id DESC LIMIT 1),
    99.00,
    'tx_live_succ_' || floor(random()*100000),
    'SUCCESS',
    NOW()
);

COMMIT;