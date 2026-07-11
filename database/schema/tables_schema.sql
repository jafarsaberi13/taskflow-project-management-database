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