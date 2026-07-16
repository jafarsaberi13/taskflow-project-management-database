-- SCHEMA: Project Tasks Workload & Assignment Summary View


CREATE OR REPLACE VIEW v_project_tasks_summary AS
SELECT 
    p.project_id,
    p.project_name,
    p.project_key,
    t.task_id,
    t.title AS task_title,
    t.status AS task_status,
    t.priority AS task_priority,
    u_assignee.full_name AS assignee_name,
    u_reporter.full_name AS reporter_name
FROM projects p
LEFT JOIN tasks t ON p.project_id = t.project_id
LEFT JOIN users u_assignee ON t.assignee_id = u_assignee.user_id
LEFT JOIN users u_reporter ON t.reporter_id = u_reporter.user_id;