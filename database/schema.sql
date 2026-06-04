-- ============================================================================
-- GZU E-REQUISITION SYSTEM - DATABASE SCHEMA
-- PostgreSQL
-- ============================================================================

-- ============================================================================
-- ENUMS (Custom Data Types)
-- ============================================================================

CREATE TYPE user_role AS ENUM (
  'CLAIMANT',
  'RECOMMENDING_USER',
  'AUTHORISING_USER',
  'PLANNING_OFFICE',
  'BURSARY',
  'CREDITORS_OFFICE',
  'AUDIT',
  'SECURITY',
  'ADMINISTRATOR'
);

CREATE TYPE requisition_status AS ENUM (
  'DRAFT',
  'SUBMITTED',
  'RECOMMENDED',
  'AUTHORISED',
  'VERIFIED',
  'PASSED_FOR_PAYMENT',
  'PAID',
  'REJECTED'
);

CREATE TYPE transaction_type AS ENUM ('CASH', 'TRANSFER');

-- ============================================================================
-- USERS TABLE
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(100) NOT NULL,
  second_name VARCHAR(100),
  surname VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  mobile_number VARCHAR(20),
  department_id UUID,
  role user_role NOT NULL,
  signature_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  is_approved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_department ON users(department_id);

-- ============================================================================
-- DEPARTMENTS TABLE
-- ============================================================================

CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE,
  code VARCHAR(50) NOT NULL UNIQUE,
  head_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_departments_code ON departments(code);

-- Add foreign key for users.department_id and departments.head_id
ALTER TABLE users
ADD CONSTRAINT fk_users_department
FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL;

ALTER TABLE departments
ADD CONSTRAINT fk_departments_head
FOREIGN KEY (head_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- BUDGET TABLE
-- ============================================================================

CREATE TABLE budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
  fiscal_year INTEGER NOT NULL,
  budgeted_amount_zig DECIMAL(15, 2) NOT NULL DEFAULT 0,
  budgeted_amount_usd DECIMAL(15, 2) NOT NULL DEFAULT 0,
  allocated_amount_zig DECIMAL(15, 2) NOT NULL DEFAULT 0,
  allocated_amount_usd DECIMAL(15, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(department_id, fiscal_year)
);

CREATE INDEX idx_budgets_department ON budgets(department_id);
CREATE INDEX idx_budgets_fiscal_year ON budgets(fiscal_year);

-- ============================================================================
-- REQUISITIONS TABLE
-- ============================================================================

CREATE TABLE requisitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requisition_number VARCHAR(50) NOT NULL UNIQUE,
  claimant_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  status requisition_status DEFAULT 'DRAFT',
  payee_name VARCHAR(255) NOT NULL,
  payee_email VARCHAR(255),
  description TEXT NOT NULL,
  total_amount_zig DECIMAL(15, 2),
  total_amount_usd DECIMAL(15, 2),
  currency_primary VARCHAR(10) NOT NULL DEFAULT 'ZiG',
  allocated_vote VARCHAR(100),
  allocated_amount_zig DECIMAL(15, 2),
  allocated_amount_usd DECIMAL(15, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  submitted_at TIMESTAMP,
  completed_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_requisitions_claimant ON requisitions(claimant_id);
CREATE INDEX idx_requisitions_department ON requisitions(department_id);
CREATE INDEX idx_requisitions_status ON requisitions(status);
CREATE INDEX idx_requisitions_number ON requisitions(requisition_number);
CREATE INDEX idx_requisitions_created ON requisitions(created_at DESC);

-- ============================================================================
-- REQUISITION LINE ITEMS TABLE
-- ============================================================================

CREATE TABLE requisition_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requisition_id UUID NOT NULL REFERENCES requisitions(id) ON DELETE CASCADE,
  description VARCHAR(500) NOT NULL,
  quantity DECIMAL(10, 2) NOT NULL,
  unit_price DECIMAL(15, 2) NOT NULL,
  amount_zig DECIMAL(15, 2),
  amount_usd DECIMAL(15, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_line_items_requisition ON requisition_line_items(requisition_id);

-- ============================================================================
-- SUPPORTING DOCUMENTS TABLE
-- ============================================================================

CREATE TABLE supporting_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requisition_id UUID NOT NULL REFERENCES requisitions(id) ON DELETE CASCADE,
  document_name VARCHAR(255) NOT NULL,
  document_url TEXT NOT NULL,
  document_type VARCHAR(100),
  file_size BIGINT,
  uploaded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documents_requisition ON supporting_documents(requisition_id);
CREATE INDEX idx_documents_uploaded_by ON supporting_documents(uploaded_by);

-- ============================================================================
-- WORKFLOW STAGES TABLE
-- ============================================================================

CREATE TABLE workflow_stages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requisition_id UUID NOT NULL REFERENCES requisitions(id) ON DELETE CASCADE,
  stage_name VARCHAR(50) NOT NULL,
  stage_order INTEGER NOT NULL,
  assigned_to UUID REFERENCES users(id),
  status VARCHAR(50) DEFAULT 'PENDING',
  approved_at TIMESTAMP,
  rejected_at TIMESTAMP,
  signature_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workflow_requisition ON workflow_stages(requisition_id);
CREATE INDEX idx_workflow_assigned_to ON workflow_stages(assigned_to);
CREATE INDEX idx_workflow_status ON workflow_stages(status);

-- ============================================================================
-- WORKFLOW COMMENTS TABLE
-- ============================================================================

CREATE TABLE workflow_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_stage_id UUID NOT NULL REFERENCES workflow_stages(id) ON DELETE CASCADE,
  commented_by UUID NOT NULL REFERENCES users(id),
  comment_text TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comments_workflow ON workflow_comments(workflow_stage_id);
CREATE INDEX idx_comments_commented_by ON workflow_comments(commented_by);

-- ============================================================================
-- ACQUITTALS TABLE
-- ============================================================================

CREATE TABLE acquittals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acquittal_number VARCHAR(50) NOT NULL UNIQUE,
  requisition_id UUID NOT NULL REFERENCES requisitions(id) ON DELETE RESTRICT,
  claimant_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  status requisition_status DEFAULT 'DRAFT',
  description TEXT NOT NULL,
  total_amount_zig DECIMAL(15, 2),
  total_amount_usd DECIMAL(15, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  submitted_at TIMESTAMP,
  completed_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_acquittals_claimant ON acquittals(claimant_id);
CREATE INDEX idx_acquittals_requisition ON acquittals(requisition_id);
CREATE INDEX idx_acquittals_status ON acquittals(status);
CREATE INDEX idx_acquittals_number ON acquittals(acquittal_number);

-- ============================================================================
-- ACQUITTAL LINE ITEMS TABLE
-- ============================================================================

CREATE TABLE acquittal_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acquittal_id UUID NOT NULL REFERENCES acquittals(id) ON DELETE CASCADE,
  description VARCHAR(500) NOT NULL,
  amount_zig DECIMAL(15, 2),
  amount_usd DECIMAL(15, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_acq_line_items_acquittal ON acquittal_line_items(acquittal_id);

-- ============================================================================
-- ACQUITTAL SUPPORTING DOCUMENTS TABLE
-- ============================================================================

CREATE TABLE acquittal_supporting_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acquittal_id UUID NOT NULL REFERENCES acquittals(id) ON DELETE CASCADE,
  document_name VARCHAR(255) NOT NULL,
  document_url TEXT NOT NULL,
  document_type VARCHAR(100),
  file_size BIGINT,
  uploaded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_acq_documents_acquittal ON acquittal_supporting_documents(acquittal_id);

-- ============================================================================
-- ACQUITTAL WORKFLOW STAGES TABLE
-- ============================================================================

CREATE TABLE acquittal_workflow_stages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acquittal_id UUID NOT NULL REFERENCES acquittals(id) ON DELETE CASCADE,
  stage_name VARCHAR(50) NOT NULL,
  stage_order INTEGER NOT NULL,
  assigned_to UUID REFERENCES users(id),
  status VARCHAR(50) DEFAULT 'PENDING',
  approved_at TIMESTAMP,
  rejected_at TIMESTAMP,
  signature_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_acq_workflow_acquittal ON acquittal_workflow_stages(acquittal_id);

-- ============================================================================
-- PAYMENT TABLE
-- ============================================================================

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requisition_id UUID REFERENCES requisitions(id) ON DELETE SET NULL,
  acquittal_id UUID REFERENCES acquittals(id) ON DELETE SET NULL,
  paid_by UUID NOT NULL REFERENCES users(id),
  payment_date TIMESTAMP NOT NULL,
  amount_zig DECIMAL(15, 2),
  amount_usd DECIMAL(15, 2),
  transaction_type transaction_type,
  transaction_reference VARCHAR(255),
  signature_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_requisition ON payments(requisition_id);
CREATE INDEX idx_payments_acquittal ON payments(acquittal_id);
CREATE INDEX idx_payments_paid_by ON payments(paid_by);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  requisition_id UUID REFERENCES requisitions(id) ON DELETE CASCADE,
  acquittal_id UUID REFERENCES acquittals(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  notification_type VARCHAR(50),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================================================
-- AUDIT LOG TABLE
-- ============================================================================

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(255) NOT NULL,
  entity_type VARCHAR(100),
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- ============================================================================
-- PERMISSIONS TABLE
-- ============================================================================

CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role user_role NOT NULL,
  permission_name VARCHAR(255) NOT NULL,
  description TEXT,
  UNIQUE(role, permission_name)
);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON budgets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_requisitions_updated_at BEFORE UPDATE ON requisitions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_acquittals_updated_at BEFORE UPDATE ON acquittals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_stages_updated_at BEFORE UPDATE ON workflow_stages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Dashboard view for claimants
CREATE OR REPLACE VIEW claimant_dashboard AS
SELECT 
  r.id,
  r.requisition_number,
  r.status,
  r.total_amount_zig,
  r.total_amount_usd,
  r.created_at,
  (SELECT COUNT(*) FROM workflow_stages ws WHERE ws.requisition_id = r.id AND ws.status = 'COMPLETED') as completed_stages,
  (SELECT COUNT(*) FROM workflow_stages ws WHERE ws.requisition_id = r.id AND ws.status = 'PENDING') as pending_stages
FROM requisitions r;

-- Pending requisitions for approvers
CREATE OR REPLACE VIEW pending_requisitions AS
SELECT DISTINCT
  r.id,
  r.requisition_number,
  r.status,
  r.payee_name,
  r.total_amount_zig,
  ws.stage_name,
  ws.assigned_to,
  r.created_at
FROM requisitions r
JOIN workflow_stages ws ON r.id = ws.requisition_id
WHERE ws.status = 'PENDING' AND r.status NOT IN ('PAID', 'REJECTED')
ORDER BY r.created_at ASC;

-- Completed requisitions for audit
CREATE OR REPLACE VIEW completed_requisitions AS
SELECT 
  r.id,
  r.requisition_number,
  r.status,
  r.claimant_id,
  r.total_amount_zig,
  r.total_amount_usd,
  r.completed_at,
  COUNT(DISTINCT p.id) as payment_count
FROM requisitions r
LEFT JOIN payments p ON r.id = p.requisition_id
WHERE r.status = 'PAID'
GROUP BY r.id;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
