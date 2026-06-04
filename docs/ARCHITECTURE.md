# GZU E-Requisition System - Architecture Documentation

## System Overview

The GZU E-Requisition System is a **multi-tier, role-based workflow management platform** built with:
- **Frontend:** React.js (SPA)
- **Backend:** Node.js/Express.js (REST API)
- **Database:** PostgreSQL (Relational)
- **Authentication:** JWT (JSON Web Tokens)
- **Deployment:** Docker & Docker Compose

---

## Architecture Layers

### 1. **Presentation Layer (Frontend)**

```
┌─────────────────────────────────────┐
│        React Single Page App        │
├─────────────────────────────────────┤
│  Components  │  Pages  │  Hooks     │
├─────────────────────────────────────┤
│   React Router │ Axios │ React Query│
├─────────────────────────────────────┤
│     Tailwind CSS  │  React Hook Form│
└─────────────────────────────────────┘
```

**Responsibilities:**
- User interface rendering
- Form validation and submission
- State management via Context API & React Query
- Client-side routing and navigation
- Role-based UI rendering

**Components:**
- Login & Registration pages
- Role-specific dashboards
- Requisition forms
- Approval workflow UI
- Notification center
- User profile management

### 2. **API Layer (Backend)**

```
┌──────────────────────────────────────┐
│      Express.js REST API Server      │
├──────────────────────────────────────┤
│  Routes  │  Controllers  │ Middleware│
├──────────────────────────────────────┤
│  Auth    │  Requisition   │  Workflow│
│  Budget  │  Dashboard     │  Payment │
├──────────────────────────────────────┤
│ Auth & RBAC │ Request Validation    │
└──────────────────────────────────────┘
```

**Key Components:**
- **Routes:** HTTP endpoints for all operations
- **Controllers:** Request handling and response formatting
- **Middleware:** JWT verification, RBAC checks, request validation
- **Services:** Business logic and workflow orchestration

### 3. **Business Logic Layer**

```
┌──────────────────────────────────────┐
│     Business Services & Logic        │
├──────────────────────────────────────┤
│ AuthService   │ RequisitionService   │
│ WorkflowService  │ BudgetService    │
│ NotificationService │ AuditService  │
└──────────────────────────────────────┘
```

**Services:**
- **AuthService:** User registration, login, JWT token generation, password reset
- **RequisitionService:** Create, update, submit requisitions, line items
- **WorkflowService:** Manage workflow stages and transitions
- **BudgetService:** Verify budgets, allocate votes, track allocations
- **NotificationService:** Send alerts and reminders via email
- **AuditService:** Log all system actions and changes

### 4. **Data Access Layer (ORM)**

```
┌──────────────────────────────────────┐
│      Sequelize ORM                   │
├──────────────────────────────────────┤
│ User │ Department │ Budget           │
│ Requisition │ Workflow │ Payment     │
│ Acquittal │ Notification │ AuditLog │
└──────────────────────────────────────┘
```

**Models (18 Total):**
- User, Department, Role, Permission
- Requisition, RequisitionLineItem, SupportingDocument
- Acquittal, AcquittalLineItem, AcquittalDocument
- WorkflowStage, WorkflowComment, AcquittalWorkflowStage
- Budget, Payment, Notification, AuditLog

### 5. **Database Layer**

```
┌──────────────────────────────────────┐
│      PostgreSQL Database             │
├──────────────────────────────────────┤
│   Tables   │   Indexes   │  Triggers │
│   Views    │   Functions │  Sequences│
└──────────────────────────────────────┘
```

---

## Data Flow Diagram

### Requisition Creation & Approval Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User (Claimant) accesses Dashboard                       │
│    ↓                                                         │
│ 2. Clicks "New Requisition" button                          │
│    ↓                                                         │
│ 3. Frontend sends POST request to /api/requisitions         │
│    ↓                                                         │
│ 4. Backend validates JWT & RBAC (must be CLAIMANT)          │
│    ↓                                                         │
│ 5. RequisitionService processes request:                    │
│    - Generates requisition number (REQyymmddidd)            │
│    - Creates requisition in DB with DRAFT status            │
│    - Creates 6 workflow stages (one for each stage)         │
│    ↓                                                         │
│ 6. Returns requisition data to frontend                     │
│    ↓                                                         │
│ 7. Claimant fills form and uploads supporting docs          │
│    ↓                                                         │
│ 8. Clicks Submit → RequisitionService:                      │
│    - Validates all required fields                          │
│    - Calculates total amounts (ZiG & USD)                   │
│    - Changes status from DRAFT to SUBMITTED                 │
│    - Creates workflow stage assignments                     │
│    - Logs action in AuditLog                                │
│    - Sends notification to Recommending User                │
│    - Sends email reminder                                   │
│    ↓                                                         │
│ 9. Recommending User receives notification                  │
│    ↓                                                         │
│ 10. Approves/Rejects → Workflow progression or rejection    │
└─────────────────────────────────────────────────────────────┘
```

---

## Role-Based Access Control (RBAC)

### Permission Matrix

| Role | Create Req | Submit | Recommend | Authorise | Verify | Pass Payment | Pay | View All |
|------|:----------:|:------:|:---------:|:---------:|:------:|:------------:|:---:|:--------:|
| Claimant | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | Own Dept |
| Recommending | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | Own Dept |
| Authorising | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | All |
| Planning | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | All |
| Bursary | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | All |
| Creditors | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | All |
| Audit | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | Completed |
| Security | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | Completed |
| Admin | All | All | All | All | All | All | All | All |

---

## Authentication & Authorization Flow

```
┌───────────────────────────────────────────────────────────┐
│ 1. User submits login credentials                         │
│    ↓                                                      │
│ 2. Frontend POST /api/auth/login                          │
│    ↓                                                      │
│ 3. Backend validates credentials:                         │
│    - Query user from DB by email                          │
│    - Hash password and compare with stored hash           │
│    - Check if user is approved and active                 │
│    ↓                                                      │
│ 4. Generate JWT token containing:                         │
│    - user_id, email, role, department_id                  │
│    - exp (24 hours), iat (issued at)                      │
│    ↓                                                      │
│ 5. Return token + user info to frontend                   │
│    ↓                                                      │
│ 6. Frontend stores token in localStorage                  │
│    ↓                                                      │
│ 7. For subsequent requests:                               │
│    - Include Authorization: Bearer <token>               │
│    ↓                                                      │
│ 8. Backend middleware verifies token:                    │
│    - Checks signature with secret key                     │
│    - Verifies expiration                                  │
│    - Extracts user info                                   │
│    - Attaches to request object                           │
│    ↓                                                      │
│ 9. RBAC middleware checks permissions:                   │
│    - Verifies user role matches required role             │
│    - Checks specific permissions if needed                │
│    - For dept-scoped queries: filters by user's dept      │
│    ↓                                                      │
│ 10. Allow/Deny request                                    │
└───────────────────────────────────────────────────────────┘
```

---

## Workflow State Machine

```
┌─────────┐
│  DRAFT  │  (Claimant creates form)
└────┬────┘
     │ submit()
     ▼
┌──────────────┐
│  SUBMITTED   │  (Waiting for Recommending User)
└────┬─────────┘
     │ approve() OR reject()
     ├──────────────┬─────────────────────┐
     │              │                     │
     ▼              ▼                     ▼
┌──────────────┐ ┌──────────┐        ┌──────────┐
│ RECOMMENDED  │ │ REJECTED │        │ REJECTED │
└────┬─────────┘ └──────────┘        └──────────┘
     │
     │ approve() OR reject()
     ├──────────────┬──────────────────────┐
     │              │                      │
     ▼              ▼                      ▼
┌──────────────┐ ┌──────────┐        ┌──────────┐
│ AUTHORISED   │ │ REJECTED │        │ REJECTED │
└────┬─────────┘ └──────────┘        └──────────┘
     │
     │ verify() OR reject()
     ├──────────────┬──────────────────────┐
     │              │                      │
     ▼              ▼                      ▼
┌──────────────┐ ┌──────────┐        ┌──────────┐
│  VERIFIED    │ │ REJECTED │        │ REJECTED │
└────┬─────────┘ └──────────┘        └──────────┘
     │
     │ approve() OR reject()
     ├──────────────┬──────────────────────┐
     │              │                      │
     ▼              ▼                      ▼
┌──────────────────┐ ┌──────────┐        ┌──────────┐
│ PASSED_FOR_PAYMENT│ │ REJECTED │        │ REJECTED │
└────┬─────────────┘ └──────────┘        └──────────┘
     │
     │ pay() OR reject()
     ├──────────────┬──────────────────────┐
     │              │                      │
     ▼              ▼                      ▼
┌─────────┐   ┌──────────┐        ┌──────────┐
│   PAID  │   │ REJECTED │        │ REJECTED │
└─────────┘   └──────────┘        └──────────┘
```

---

## Error Handling Strategy

### HTTP Status Codes

- **200 OK** – Successful request
- **201 Created** – Resource created successfully
- **400 Bad Request** – Invalid input/validation errors
- **401 Unauthorized** – Missing/invalid authentication
- **403 Forbidden** – Insufficient permissions
- **404 Not Found** – Resource not found
- **409 Conflict** – Business logic violation
- **422 Unprocessable Entity** – Validation error
- **500 Internal Server Error** – Unexpected server error

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "INVALID_STATUS_TRANSITION",
    "message": "Cannot transition from DRAFT to PAID",
    "details": {
      "currentStatus": "DRAFT",
      "attemptedStatus": "PAID",
      "allowedTransitions": ["SUBMITTED"]
    }
  }
}
```

---

## Deployment Architecture

```
┌──────────────────────────────────────────────────────────┐
│           Docker Container Orchestration                 │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────────┐  ┌──────────────────┐              │
│  │  React Frontend │  │  Express Backend │              │
│  │  (Port 3000)    │  │  (Port 5000)     │              │
│  └────────┬────────┘  └────────┬─────────┘              │
│           │                    │                        │
│           └────────┬───────────┘                        │
│                    │                                    │
│           ┌────────▼──────────┐                        │
│           │  PostgreSQL DB    │                        │
│           │  (Port 5432)      │                        │
│           └───────────────────┘                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Container Communication

- **Frontend → Backend:** HTTP/REST via Axios
- **Backend → Database:** psycopg2/pg driver
- **Inter-container:** Docker network `gzu_network`

---

## Security Considerations

### 1. **Authentication**
- JWT tokens with 24-hour expiration
- Password hashing with bcrypt (12 rounds)
- Secure password reset via email verification
- Session timeout on inactivity

### 2. **Authorization**
- RBAC enforcement on every protected endpoint
- Department-scoped queries (only see own dept unless authorized)
- Signature validation for workflow stages
- Row-level security where applicable

### 3. **Data Protection**
- SQL injection prevention via parameterized queries (Sequelize)
- XSS prevention with React's built-in escaping
- CORS configured for frontend-backend communication
- HTTPS recommended in production
- Input validation on all endpoints

### 4. **Audit Trail**
- All state changes logged in audit_logs table
- User IP addresses captured for security
- Immutable record of all approvals/rejections
- Compliance with institutional policies

### 5. **File Upload Security**
- File type validation
- File size limits (5MB default)
- Virus scanning recommended for production
- Stored outside web root

---

## Performance Optimization

### 1. **Database Indexing**
- Indexes on frequently queried columns
- Composite indexes for common queries
- Partial indexes for status filtering

### 2. **Caching Strategy**
- User permissions cached in JWT
- Department budgets cached in React Query
- Session caching for frequently accessed data

### 3. **Query Optimization**
- Eager loading with Sequelize (includes/associations)
- Pagination for large datasets
- Select only required columns

### 4. **Frontend Performance**
- Code splitting with React Router
- Image optimization and lazy loading
- Memoization of expensive components
- Minification and gzip compression

---

## Scaling Considerations

### Horizontal Scaling
- Stateless backend instances behind load balancer
- Shared PostgreSQL database with read replicas
- CDN for static frontend assets

### Vertical Scaling
- Upgrade server CPU/RAM
- Connection pooling (PgBouncer)
- Query caching (Redis)

### Monitoring & Logging
- Application performance monitoring (APM)
- Centralized log aggregation (ELK, Datadog)
- Database query performance analysis
- Error tracking (Sentry)

---

## Technology Decisions

### Why Express.js + Node.js?
- Fast, lightweight, perfect for API servers
- Large ecosystem of packages
- Excellent ORM support (Sequelize)
- Easy to scale horizontally

### Why PostgreSQL?
- ACID compliance for financial data
- Advanced features (JSONB, full-text search)
- Strong security and audit capabilities
- Mature, stable, widely used

### Why React?
- Component-based architecture
- Large community and ecosystem
- Excellent state management options
- Server-side rendering possible

### Why Docker?
- Consistent environment across all machines
- Easy deployment and scaling
- Service isolation and security
- Simplified dependencies management

---

## Future Enhancements

1. **Real-time Updates** - WebSocket support for live notifications
2. **Advanced Reporting** - Business intelligence dashboards
3. **Mobile App** - React Native for iOS/Android
4. **API Rate Limiting** - Per-user rate limits
5. **Two-Factor Authentication** - Enhanced security
6. **Advanced Search** - Full-text search with Elasticsearch
7. **Integration APIs** - Connect with university accounting system
8. **Workflow Customization** - Per-department workflow rules
9. **Multi-language Support** - Internationalization (i18n)
10. **Offline Mode** - PWA capabilities for offline requisition entry

---

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database backups automated
- [ ] HTTPS certificates installed
- [ ] Monitoring and alerts set up
- [ ] Log aggregation configured
- [ ] Email service configured
- [ ] CDN for static assets
- [ ] Load balancer configured
- [ ] Database replicas set up
- [ ] Disaster recovery plan documented

---

**Last Updated:** June 4, 2025
