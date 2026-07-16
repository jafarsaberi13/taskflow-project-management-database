-- TEST scenario 1: Direct Table Access Attempt (EXPECTED: ACCESS DENIED ERROR)
-- Run this query while logged in as 'data_analyst'

SELECT * FROM subscriptions_and_payments;


-- TEST scenario 2: Safe View Access Attempt (EXPECTED: SUCCESSFUL EXECUTION)
-- Run this query while logged in as 'data_analyst'

SELECT * FROM v_workspace_payment_details LIMIT 5;