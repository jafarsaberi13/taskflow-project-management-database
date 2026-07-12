DO $$
DECLARE
    v_admin_role_id INT;
    v_user_role_id INT;
    v_free_plan_id INT;
    v_pro_plan_id INT;
    v_ent_plan_id INT;
    v_plan_ids INT[];
    v_user_id BIGINT; 
    v_workspace_id BIGINT;
    v_project_id BIGINT;
    v_task_id BIGINT;
    v_subscription_id BIGINT;
    v_tag_id INT;
    v_payment_amount NUMERIC(10,2);
    i INT; j INT; k INT;
    base_time TIMESTAMP := TIMESTAMP '2025-01-01 08:00:00';
    user_time TIMESTAMP;
    workspace_time TIMESTAMP;
    project_time TIMESTAMP;
    task_time TIMESTAMP;
    action_time TIMESTAMP;
    first_names VARCHAR[] := ARRAY['Amir', 'Ali', 'Mohammad', 'Reza', 'Saeed', 'Hossein', 'Sara', 'Neda', 'Maryam', 'Yasaman', 'Elham', 'Nima', 'Pouya', 'Roya'];
    last_names VARCHAR[] := ARRAY['Karimi', 'Rahimi', 'Alizadeh', 'Mousavi', 'Rezaei', 'Nouraei', 'Ahmadi', 'Hashemi', 'Tavakoli', 'Salehi', 'Ghasemi'];
    company_names VARCHAR[] := ARRAY['TechFlow Solutions', 'Nexus Core Systems', 'CloudScale Labs', 'DevOps Prime', 'Quantum Code Inc', 'Alpha Development', 'Sharif Accelerator', 'Modern Software', 'Idea Pooya', 'Data Pars'];
    company_slugs VARCHAR[] := ARRAY['techflow', 'nexus-core', 'cloudscale', 'devops-prime', 'quantum-code', 'alpha-dev', 'sharif-accelerator', 'modern-software', 'idea-pooya', 'data-pars'];
    project_names VARCHAR[] := ARRAY['Backend API Refactoring', 'Figma UI/UX Redesign', 'Dockerization & CI/CD Pipeline', 'Stripe Payment Gateway Integration', 'Mobile App Development'];
    project_keys VARCHAR[] := ARRAY['API', 'UIX', 'OPS', 'PAY', 'MOB'];
    task_titles VARCHAR[] := ARRAY[
        'Implement JWT Authentication with Spring Security',
        'Optimize PostgreSQL JSONB query performance',
        'Fix memory leak in Docker container runtime',
        'Design Figma UI for Workspace settings dashboard',
        'Setup CI/CD automation pipeline via GitHub Actions',
        'Integrate Stripe Webhooks for subscription billing',
        'Refactor database migration scripts using Flyway',
        'Fix race condition in task assignment logic',
        'Write Unit Tests for Payment Verification Service',
        'Configure Redis Cache for frequently accessed tasks',
        'Fix CSS alignment bug on Kanban board columns',
        'Implement OAuth2 Google Login provider',
        'Create database indexes for activity_logs table',
        'Upgrade Spring Boot version from 3.1 to 3.3',
        'Conduct security vulnerability audit on dependencies'
    ];
    task_descriptions VARCHAR[] := ARRAY[
        'Critical requirement for upcoming release. Ensure token expiration is handled correctly.',
        'Current query takes more than 2 seconds. Need to investigate GIN indexes.',
        'Production logs show container crashes every 24 hours. Analyze heap dumps.',
        'Review the latest wireframes from the design team and align with Tailwind CSS.',
        'Automate the deployment to AWS EKS cluster on every merge to main branch.',
        'Handle charge.succeeded and invoice.payment_failed events gracefully in backend.',
        'Ensure clean rollback mechanisms for all V2 migration steps.',
        'Two managers assigning the same task concurrently causes database locking issues.',
        'Target code coverage is 85%. Focus on edge cases and transaction fallbacks.',
        'Cache invalidation policy should be set to 15 minutes TTL.'
    ];
    status_arr VARCHAR[] := ARRAY['TODO', 'IN_PROGRESS', 'REVIEW', 'DONE'];
    priority_arr VARCHAR[] := ARRAY['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
    proj_role_arr VARCHAR[] := ARRAY['MANAGER', 'DEVELOPER', 'VIEWER'];
    action_arr VARCHAR[] := ARRAY['CREATE', 'UPDATE', 'DELETE', 'LOGIN'];
    entity_arr VARCHAR[] := ARRAY['TASKS', 'PROJECTS', 'WORKSPACES'];
BEGIN
    SELECT role_id INTO v_admin_role_id FROM system_roles WHERE role_name = 'System Admin';
    IF v_admin_role_id IS NULL THEN
        INSERT INTO system_roles (role_name, description) 
        VALUES ('System Admin', 'Global infrastructure control and server-level administration.') 
        RETURNING role_id INTO v_admin_role_id;
    END IF;

    SELECT role_id INTO v_user_role_id FROM system_roles WHERE role_name = 'Standard User';
    IF v_user_role_id IS NULL THEN
        INSERT INTO system_roles (role_name, description) 
        VALUES ('Standard User', 'Default role for corporate workspace employees and developers.') 
        RETURNING role_id INTO v_user_role_id;
    END IF;

    SELECT plan_id INTO v_free_plan_id FROM billing_plans WHERE name = 'Free Tier';
    IF v_free_plan_id IS NULL THEN
        INSERT INTO billing_plans (name, price, max_users) VALUES ('Free Tier', 0.00, 5) RETURNING plan_id INTO v_free_plan_id;
    END IF;

    SELECT plan_id INTO v_pro_plan_id FROM billing_plans WHERE name = 'Pro Team';
    IF v_pro_plan_id IS NULL THEN
        INSERT INTO billing_plans (name, price, max_users) VALUES ('Pro Team', 29.00, 30) RETURNING plan_id INTO v_pro_plan_id;
    END IF;

    SELECT plan_id INTO v_ent_plan_id FROM billing_plans WHERE name = 'Enterprise';
    IF v_ent_plan_id IS NULL THEN
        INSERT INTO billing_plans (name, price, max_users) VALUES ('Enterprise', 99.00, 1000) RETURNING plan_id INTO v_ent_plan_id;
    END IF;

    v_plan_ids := ARRAY[v_free_plan_id, v_pro_plan_id, v_ent_plan_id];

    FOR i IN 1..40 LOOP
        user_time := base_time + (i * INTERVAL '12 hours');
        INSERT INTO users (system_role_id, email, password_hash, full_name, created_at, updated_at)
        VALUES (
            CASE WHEN i = 1 THEN v_admin_role_id ELSE v_user_role_id END,
            lower(first_names[(i % 14) + 1] || '.' || last_names[(i % 11) + 1] || i || '@taskflow.io'),
            '$2a$12$eImiTxAk4vmv856wlSHfXeMDLTwPZ30D6f6A.uB3A.S7B8XjM33Q.',
            first_names[(i % 14) + 1] || ' ' || last_names[(i % 11) + 1],
            user_time,
            user_time
        );
    END LOOP;

    FOR i IN 1..10 LOOP
        workspace_time := base_time + INTERVAL '30 days' + (i * INTERVAL '2 days');
        INSERT INTO workspaces (billing_plan_id, workspace_name, slug, created_at)
        VALUES (
            v_plan_ids[floor(random() * 3) + 1],
            company_names[i],
            company_slugs[i],
            workspace_time
        ) RETURNING workspace_id INTO v_workspace_id;

        INSERT INTO subscriptions (workspace_id, status, subscription_start_date, subscription_end_date)
        VALUES (
            v_workspace_id, 
            'ACTIVE', 
            workspace_time, 
            workspace_time + INTERVAL '1 year'
        ) RETURNING subscription_id INTO v_subscription_id;

        v_payment_amount := CASE WHEN i % 3 = 1 THEN 0.00 WHEN i % 3 = 2 THEN 29.00 ELSE 99.00 END;
        
        IF v_payment_amount > 0 THEN
            FOR j IN 0..2 LOOP
                INSERT INTO subscriptions_and_payments (subscription_id, amount, transaction_ref, payment_status, payment_date)
                VALUES (
                    v_subscription_id, 
                    v_payment_amount, 
                    'ch_' || floor(random()*100000) || '_w' || v_workspace_id || '_p' || j, 
                    'SUCCESS', 
                    workspace_time + (j * INTERVAL '1 month') + INTERVAL '1 hour'
                );
            END LOOP;
        END IF;

        FOR j IN 1..12 LOOP
            SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i * 3 + j) % 40);
            BEGIN
                INSERT INTO workspace_members (workspace_id, user_id, member_role, joined_at)
                VALUES (v_workspace_id, v_user_id, CASE WHEN j = 1 THEN 'OWNER' WHEN j = 2 THEN 'ADMIN' ELSE 'MEMBER' END, workspace_time + INTERVAL '12 hours');
            EXCEPTION WHEN unique_violation THEN NULL; END;
        END LOOP;

        INSERT INTO tags (workspace_id, name, color_code) VALUES (v_workspace_id, 'Sprint-Hotfix', '#FF5733') RETURNING tag_id INTO v_tag_id;

        FOR j IN 1..3 LOOP
            project_time := workspace_time + INTERVAL '10 days' + (j * INTERVAL '2 days');
            INSERT INTO projects (workspace_id, project_name, project_key, created_at)
            VALUES (v_workspace_id, project_names[((i+j) % 5) + 1] || ' Phase ' || j, project_keys[((i+j) % 5) + 1] || v_workspace_id || j, project_time)
            RETURNING project_id INTO v_project_id;

            FOR k IN 1..6 LOOP
                SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i * 2 + j + k) % 40);
                BEGIN
                    INSERT INTO project_members (project_id, user_id, project_role, joined_at)
                    VALUES (v_project_id, v_user_id, proj_role_arr[floor(random() * 3) + 1], project_time + INTERVAL '5 hours');
                EXCEPTION WHEN unique_violation THEN NULL; END;
            END LOOP;

            FOR k IN 1..19 LOOP
                task_time := project_time + INTERVAL '1 day' + (k * INTERVAL '8 hours');
                
                SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i * 2 + k) % 40);
                DECLARE
                    v_assignee_id BIGINT;
                BEGIN
                    SELECT user_id INTO v_assignee_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i * 3 + k + 2) % 40);
                    
                    INSERT INTO tasks (project_id, reporter_id, assignee_id, title, description, status, priority, due_date, created_at, updated_at, custom_fields)
                    VALUES (
                        v_project_id,
                        v_user_id,
                        v_assignee_id,
                        task_titles[(k % 15) + 1] || ' [Ref: ' || v_project_id || '-' || k || ']',
                        task_descriptions[(k % 10) + 1],
                        status_arr[floor(random() * 4) + 1], 
                        priority_arr[floor(random() * 4) + 1],
                        task_time + INTERVAL '14 days', 
                        task_time,
                        task_time,
                        ('{"story_points": ' || (ARRAY[1,2,3,5,8])[floor(random()*5)+1] || ', "environment": "Production", "service_oriented": true}')::jsonb
                    ) RETURNING task_id INTO v_task_id;
                END;

                IF k % 2 = 0 THEN
                    INSERT INTO task_tags(task_id, tag_id) VALUES (v_task_id, v_tag_id);
                END IF;

                IF k % 2 = 0 THEN
                    SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i+k)%40);
                    INSERT INTO task_comments (task_id, user_id, comment_text, created_at)
                    VALUES (v_task_id, v_user_id, 'Technical implementation aligns with architectural specs. Ready for peer review.', task_time + INTERVAL '6 hours');
                END IF;

                IF k % 3 = 0 THEN
                    SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i+k)%40);
                    INSERT INTO task_attachments (task_id, uploaded_by, file_name, file_size, file_url, created_at)
                    VALUES (v_task_id, v_user_id, 'error_log_id_' || v_task_id || '.log', floor(random()*8000)+200, 'https://s3.amazonaws.com/taskflow/logs/' || v_task_id || '.log', task_time + INTERVAL '12 hours');
                END IF;

                SELECT user_id INTO v_user_id FROM users ORDER BY user_id LIMIT 1 OFFSET ((i*3+k)%40);
                INSERT INTO task_history (task_id, changed_by_user_id, old_status, new_status, changed_at)
                VALUES (v_task_id, v_user_id, 'TODO', 'IN_PROGRESS', task_time + INTERVAL '1 day');
                
                IF k % 2 = 0 THEN
                    INSERT INTO task_history (task_id, changed_by_user_id, old_status, new_status, changed_at)
                    VALUES (v_task_id, v_user_id, 'IN_PROGRESS', 'DONE', task_time + INTERVAL '2 days');
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    FOR i IN 1..250 LOOP
        action_time := base_time + INTERVAL '45 days' + (i * INTERVAL '3 hours');
        SELECT user_id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
        INSERT INTO activity_logs (user_id, action_type, entity_name, entity_id, description, ip_address, created_at)
        VALUES (
            v_user_id,
            action_arr[floor(random() * 4) + 1],
            entity_arr[floor(random() * 3) + 1],
            floor(random() * 200) + 1,
            'Audit sequence verification executed successfully for record identifier ' || i,
            '172.16.45.' || floor(random() * 254) + 1,
            action_time
        );
    END LOOP;
END $$;