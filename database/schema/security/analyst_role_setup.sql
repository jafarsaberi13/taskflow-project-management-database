CREATE ROLE data_analyst WITH LOGIN PASSWORD 'AnalystSecurePass2026!';

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM data_analyst;

REVOKE ALL PRIVILEGES ON TABLE 
    workspaces, 
    subscriptions, 
    subscriptions_and_payments, 
    billing_plans, 
    users, 
    tasks, 
    projects, 
    workspace_members, 
    project_members 
FROM data_analyst;

GRANT SELECT ON v_workspace_payment_details TO data_analyst;
GRANT SELECT ON v_project_tasks_summary TO data_analyst;