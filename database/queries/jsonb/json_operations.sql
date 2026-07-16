
--  OPERATIONS: JSONB Filtering & Inline Document Modification
--  METHOD: Containment Operator (@>), Extraction Operator (->>), jsonb_set

--  Complex Filtering: Get Tech workspaces with security MFA enabled
SELECT 
    workspace_id,
    workspace_name,
    metadata->>'category' AS category,
    metadata->'preferences'->'security'->>'mfa_enabled' AS mfa_status,
    metadata->'tags' AS tags
FROM workspaces
WHERE metadata @> '{"category": "Tech"}'
  AND (metadata->'preferences'->'security'->>'mfa_enabled')::boolean = true;

--  Inline update of a nested key using jsonb_set (Upgrade MFA security for Workspace 3)
UPDATE workspaces
SET metadata = jsonb_set(
    metadata, 
    '{preferences, security, mfa_enabled}', 
    'true'::jsonb
)
WHERE workspace_id = 3;