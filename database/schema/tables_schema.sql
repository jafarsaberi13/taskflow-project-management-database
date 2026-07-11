-- =========================================================================
--  PLATFORM: TaskFlow (Production-Ready 3NF Schema)
-- =========================================================================

CREATE TABLE system_roles (
    role_id SERIAL,
    role_name VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT pk_system_roles PRIMARY KEY (role_id),
    CONSTRAINT uq_role_name UNIQUE (role_name)
);

CREATE TABLE users (
    user_id BIGSERIAL,
    system_role_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT fk_users_system_role_id FOREIGN KEY (system_role_id) REFERENCES system_roles(role_id),
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE billing_plans (
    plan_id SERIAL,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    max_users INT NOT NULL,
    CONSTRAINT pk_billing_plans PRIMARY KEY (plan_id),
    CONSTRAINT uq_plan_name UNIQUE (name),
    CONSTRAINT chk_plan_price CHECK (price >= 0),
    CONSTRAINT chk_max_users CHECK (max_users > 0)
);

CREATE TABLE workspaces (
    workspace_id BIGSERIAL,
    billing_plan_id INT NOT NULL,
    workspace_name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workspaces PRIMARY KEY (workspace_id),
    CONSTRAINT fk_workspaces_billing_plan_id FOREIGN KEY (billing_plan_id) REFERENCES billing_plans(plan_id)
);

CREATE TABLE subscriptions (
    subscription_id BIGSERIAL,
    workspace_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    subscription_start_date TIMESTAMP NOT NULL,
    subscription_end_date TIMESTAMP NOT NULL,
    CONSTRAINT pk_subscriptions PRIMARY KEY (subscription_id),
    CONSTRAINT fk_subscriptions_workspace_id FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id),
    CONSTRAINT chk_sub_status CHECK (status IN ('ACTIVE', 'PAST_DUE', 'CANCELED', 'EXPIRED'))
);

CREATE TABLE subscriptions_and_payments (
    payment_id BIGSERIAL,
    subscription_id BIGINT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    transaction_ref VARCHAR(100) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_subscription_id FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    CONSTRAINT uq_transaction_ref UNIQUE (transaction_ref),
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

CREATE TABLE workspace_members (
    workspace_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    member_role VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_workspace_members PRIMARY KEY (workspace_id, user_id),
    CONSTRAINT fk_workspace_members_workspace_id FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id),
    CONSTRAINT fk_workspace_members_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_member_role CHECK (member_role IN ('OWNER', 'ADMIN', 'MEMBER'))
);

CREATE TABLE projects (
    project_id BIGSERIAL,
    workspace_id BIGINT NOT NULL,
    project_name VARCHAR(100) NOT NULL,
    project_key VARCHAR(10) NOT NULL,
    description TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_projects PRIMARY KEY (project_id),
    CONSTRAINT fk_projects_workspace_id FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id)
);

CREATE TABLE project_members (
    project_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    project_role VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_project_members PRIMARY KEY (project_id, user_id),
    CONSTRAINT fk_project_members_project_id FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT fk_project_members_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_project_role CHECK (project_role IN ('MANAGER', 'DEVELOPER', 'VIEWER'))
);

CREATE TABLE tasks (
    task_id BIGSERIAL,
    project_id BIGINT NOT NULL,
    reporter_id BIGINT NOT NULL,
    assignee_id BIGINT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    priority VARCHAR(50) NOT NULL,
    due_date TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT pk_tasks PRIMARY KEY (task_id),
    CONSTRAINT fk_tasks_project_id FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT fk_tasks_reporter_id FOREIGN KEY (reporter_id) REFERENCES users(user_id),
    CONSTRAINT fk_tasks_assignee_id FOREIGN KEY (assignee_id) REFERENCES users(user_id),
    CONSTRAINT chk_task_status CHECK (status IN ('TODO', 'IN_PROGRESS', 'REVIEW', 'DONE')),
    CONSTRAINT chk_task_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

CREATE TABLE task_comments (
    comment_id BIGSERIAL,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_task_comments PRIMARY KEY (comment_id),
    CONSTRAINT fk_task_comments_task_id FOREIGN KEY (task_id) REFERENCES tasks(task_id),
    CONSTRAINT fk_task_comments_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE task_attachments (
    attachment_id BIGSERIAL,
    task_id BIGINT NOT NULL,
    uploaded_by BIGINT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT NOT NULL,
    file_url VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_task_attachments PRIMARY KEY (attachment_id),
    CONSTRAINT fk_task_attachments_task_id FOREIGN KEY (task_id) REFERENCES tasks(task_id),
    CONSTRAINT fk_task_attachments_user_id FOREIGN KEY (uploaded_by) REFERENCES users(user_id),
    CONSTRAINT chk_file_size CHECK (file_size > 0)
);
