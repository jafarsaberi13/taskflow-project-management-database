# taskflow-project-management-database 

An enterprise-grade, multi-tenant PostgreSQL database architecture engineered for modern B2B SaaS project management platforms. **TaskFlow Enterprise** combines relational database robustness with high-performance analytics, strict security abstraction, ACID transactional integrity, and hybrid semi-structured JSONB storage.

---

## 🌟 Key Features

### 🏢 Multi-Tenant Workspace Isolation
* Logical data separation for organizational workspaces (`workspaces`).
* Scalable hierarchy connecting users, workspace memberships, projects, tasks, and billing.

### 💳 Subscription & Financial Management
* Flexible pricing tier architecture (`billing_plans`).
* Lifecycle tracking for subscriptions and audit-ready payment records (`subscriptions_and_payments`).

### 🔄 ACID Transaction Safeguards
* Scripted multi-step SQL transactions with explicit `COMMIT` and `ROLLBACK` handling.
* Guarantees 100% data consistency during plan upgrades, payment processing, and entity creation.

### 📊 Executive Business KPIs & Analytical Engine
* Real-time analytical insights powered by PostgreSQL Window Functions (`LAG`, `DENSE_RANK`, `SUM OVER`):
  * **Month-over-Month (MoM) Growth:** Tracks monthly revenue velocity and percentages.
  * **Customer Lifetime Value (CLV) & Ranking:** Computes total workspace spending, AOV, and dense ranks.
  * **Paying Customer Churn Rate:** Detects inactive accounts based on 90-day payment thresholds.

### 🛡️ DevSecOps & Security Abstraction (DCL)
* Implementation of the **Principle of Least Privilege (PoLP)**.
* Strict role-based access control (`data_analyst`).
* Security views (`VIEW`s) to hide underlying base table joins and protect raw financial/user data.

### ⚡ Hybrid Semi-Structured Storage (JSONB)
* Schema-less workspace metadata for dynamic user preferences, notification settings, and IP whitelists.
* Custom `CHECK` constraints guaranteeing mandatory root schema keys (`category`).
* High-performance querying using containment operators (`@>`) and non-destructive inline updating via `jsonb_set`.

---

## 🛠️ Project Modules

### 1. Schema & Data Definition Module (DDL)
* **Base Schema (`tables_schema.sql`):** Defines core entities, primary/foreign keys, cascades, and indexes.
* **Seed Engine (`mock_data.sql`):** Populates the database with over 1,000 realistic production-like records.
* **JSONB Extension (`jsonb_setup.sql`):** Extends workspace metadata, enforces validation rules, and seeds multi-layer nested documents.

### 2. Transactional & Operations Module
* **Successful Upgrade Scenario (`successful_upgrade.sql`):** Executes plan upgrade, subscription creation, and payment log within a single safe transaction block (`COMMIT`).
* **Failure & Rollback Simulation (`failed_rollback.sql`):** Demonstrates automatic database state restoration (`ROLLBACK`) upon foreign key violations.

### 3. Business Analytics & KPI Engine
* **Employee Performance Ranking:** Evaluates completed task velocity per user across workspace boundaries.
* **Revenue Percentage Share:** Calculates the proportional contribution of each workspace to plan revenue.
* **Client Segmentation:** Classifies enterprise clients into `VIP Client`, `Active Client`, and `Inactive / Idle` tiers.
* **SaaS Growth KPIs:** Executes MoM growth rate, CLV evaluation, and churn rate calculations.

### 4. Security & Access Control Module (DCL)
* **View Abstraction Layer:** Pre-built views (`v_workspace_payment_details`, `v_project_tasks_summary`) for simplified reporting.
* **Role Configuration (`analyst_role_setup.sql`):** Configures restricted `data_analyst` roles with explicit `REVOKE` on raw tables and `GRANT` on secure views.

### 5. Verification & Testing Suite
* **Security Isolation Test (`security_verification.sql`):** Verifies access rejection on base tables and authorization on security views.
* **JSONB Constraint Test (`jsonb_verification.sql`):** Verifies constraint violations when attempting to insert invalid JSON schemas.

---

## 📂 Repository Directory Structure

```text
.
├── README.md
└── database/
    ├── schema/                         # Data Definition Layer (DDL)
    │   ├── tables_schema.sql           # Primary tables, FKs, constraints
    │   ├── mock_data.sql               # Production-scale mock seed dataset
    │   ├── jsonb_setup.sql             # JSONB column addition, constraints, & seed
    │   ├── views/                      # Security & analytical views
    │   │   ├── workspace_payments_view.sql
    │   │   └── project_tasks_view.sql
    │   └── security/                   # Access control & RBAC configurations
    │       └── analyst_role_setup.sql
    │
    └── queries/                        # Operational Queries Layer (DML)
        ├── transactions/               # ACID compliance test scripts
        │   ├── successful_upgrade.sql
        │   └── failed_rollback.sql
        ├── analytics/                  # Analytical & classification queries
        │   ├── employee_performance_ranking.sql
        │   ├── workspace_revenue_share.sql
        │   └── client_segmentation.sql
        ├── kpis/                       # Executive SaaS KPI calculations
        │   ├── mom_revenue_growth.sql
        │   ├── customer_lifetime_value.sql
        │   ├── customer_lifetime_value_v2.sql
        │   └── customer_churn_rate.sql
        ├── jsonb/                      # JSONB operations & manipulation
        │   └── jsonb_operations.sql
        └── tests/                      # Validation and verification scripts
            ├── security_verification.sql
            └── jsonb_verification.sql
