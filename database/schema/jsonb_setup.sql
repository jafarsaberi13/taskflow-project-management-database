
-- SCHEMA: JSONB Dynamic Metadata Setup
--  METHOD: Schema Alteration, JSONB CHECK Constraints & Data Seeding
-- PLATFORM: TaskFlow SaaS Enterprise Database


-- 1 Add JSONB metadata column to workspaces table
ALTER TABLE workspaces ADD COLUMN metadata JSONB;

-- 2 Add CHECK constraint to enforce object type and required 'category' key
ALTER TABLE workspaces ADD CONSTRAINT check_workspace_metadata_category CHECK (
    metadata IS NULL OR (
        jsonb_typeof(metadata) = 'object' AND 
        metadata ? 'category'
    )
);

-- 3 Seed 10 workspaces with rich, nested JSONB documents
UPDATE workspaces SET metadata = '{"category": "Tech", "tags": ["SaaS", "Cloud", "Developer-Tools"], "preferences": {"theme": "dark", "notifications": {"email": true, "slack": true}, "security": {"mfa_enabled": true, "ip_whitelist": ["192.168.1.1"]}}}'::jsonb WHERE workspace_id = 1;
UPDATE workspaces SET metadata = '{"category": "Finance", "tags": ["FinTech", "Banking"], "preferences": {"theme": "light", "notifications": {"email": true, "slack": false}, "security": {"mfa_enabled": true, "ip_whitelist": ["10.0.0.5", "10.0.0.6"]}}}'::jsonb WHERE workspace_id = 2;
UPDATE workspaces SET metadata = '{"category": "Tech", "tags": ["Enterprise", "Internal-Tools"], "preferences": {"theme": "dark", "notifications": {"email": false, "slack": true}, "security": {"mfa_enabled": false, "ip_whitelist": []}}}'::jsonb WHERE workspace_id = 3;
UPDATE workspaces SET metadata = '{"category": "Education", "tags": ["LMS", "E-Learning"], "preferences": {"theme": "blue", "notifications": {"email": true, "slack": false}, "security": {"mfa_enabled": true, "ip_whitelist": []}}}'::jsonb WHERE workspace_id = 4;
UPDATE workspaces SET metadata = '{"category": "Tech", "tags": ["AI", "Machine-Learning"], "preferences": {"theme": "dark", "notifications": {"email": true, "slack": true}, "security": {"mfa_enabled": true, "ip_whitelist": ["172.16.0.1"]}}}'::jsonb WHERE workspace_id = 5;
UPDATE workspaces SET metadata = '{"category": "Marketing", "tags": ["AdTech", "Social-Media"], "preferences": {"theme": "light", "notifications": {"email": true, "slack": true}, "security": {"mfa_enabled": false, "ip_whitelist": []}}}'::jsonb WHERE workspace_id = 6;
UPDATE workspaces SET metadata = '{"category": "Tech", "tags": ["SaaS", "Kubernetes"], "preferences": {"theme": "dark", "notifications": {"email": true, "slack": true}, "security": {"mfa_enabled": true, "ip_whitelist": ["192.168.1.100"]}}}'::jsonb WHERE workspace_id = 7;
UPDATE workspaces SET metadata = '{"category": "Healthcare", "tags": ["HIPAA", "Telehealth"], "preferences": {"theme": "white", "notifications": {"email": true, "slack": false}, "security": {"mfa_enabled": true, "ip_whitelist": ["185.22.44.1"]}}}'::jsonb WHERE workspace_id = 8;
UPDATE workspaces SET metadata = '{"category": "Tech", "tags": ["DevOps", "Infrastructure"], "preferences": {"theme": "dark", "notifications": {"email": false, "slack": true}, "security": {"mfa_enabled": false, "ip_whitelist": []}}}'::jsonb WHERE workspace_id = 9;
UPDATE workspaces SET metadata = '{"category": "E-commerce", "tags": ["Retail", "Shopify-Integration"], "preferences": {"theme": "light", "notifications": {"email": true, "slack": true}, "security": {"mfa_enabled": true, "ip_whitelist": []}}}'::jsonb WHERE workspace_id = 10;