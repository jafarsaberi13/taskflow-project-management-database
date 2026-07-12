BEGIN TRANSACTION;

INSERT INTO projects (workspace_id, project_name, project_key, created_at)
VALUES (
    (SELECT workspace_id FROM workspaces ORDER BY workspace_id LIMIT 1),
    'Security Audit Phase 2',
    'SEC-' || floor(random()*899 + 100),
    NOW()
);

INSERT INTO tasks (project_id, reporter_id, assignee_id, title, description, status, priority, due_date, created_at, updated_at)
VALUES (
    (SELECT project_id FROM projects ORDER BY project_id DESC LIMIT 1),
    (SELECT user_id FROM users ORDER BY user_id LIMIT 1),
    (SELECT user_id FROM users ORDER BY user_id LIMIT 1),
    'Review Firewall logs and open ports',
    'Critical security check for the main network.',
    'TODO',
    'CRITICAL',
    NOW() + INTERVAL '7 days',
    NOW(),
    NOW()
);

INSERT INTO project_members (project_id, user_id, project_role, joined_at)
VALUES (
    (SELECT project_id FROM projects ORDER BY project_id DESC LIMIT 1),
    999999,
    'DEVELOPER',
    NOW()
);

COMMIT;