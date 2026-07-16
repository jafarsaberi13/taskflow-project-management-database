SELECT 
    w.workspace_name AS company_name,
    u.full_name AS employee_name,
    COUNT(t.task_id) AS completed_tasks_count,
    DENSE_RANK() OVER (
        PARTITION BY w.workspace_id 
        ORDER BY COUNT(t.task_id) DESC
    ) AS performance_rank
FROM workspaces w
JOIN workspace_members wm ON w.workspace_id = wm.workspace_id
JOIN users u ON wm.user_id = u.user_id
JOIN tasks t ON t.assignee_id = u.user_id
JOIN projects p ON t.project_id = p.project_id AND p.workspace_id = w.workspace_id
WHERE t.status = 'DONE'
GROUP BY w.workspace_id, w.workspace_name, u.user_id, u.full_name
ORDER BY company_name, performance_rank;