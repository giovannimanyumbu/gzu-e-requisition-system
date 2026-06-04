# GZU E-Requisition System

## Overview

The **Great Zimbabwe University E-Requisition System** is a comprehensive digital workflow platform that replaces traditional paper-based requisition and acquittal processes. It enables employees to request goods or services online through a structured multi-stage approval workflow.

### Key Features

- **Role-Based Access Control (RBAC)** – 9 distinct user roles with specific permissions
- **Multi-Stage Workflow** – 6 approval stages with audit trails
- **Multi-Currency Support** – ZiG and USD transactions
- **Department Budget Management** – Real-time budget vs. actual tracking
- **Digital Signatures** – Automated signature capture during sign-up
- **Notifications & Reminders** – Real-time system alerts and email reminders
- **Audit Logging** – Complete audit trail for compliance

---

## Tech Stack

### Backend
- Node.js with Express.js
- PostgreSQL Database
- JWT Authentication
- Sequelize ORM
- Nodemailer (Email)

### Frontend
- React 18+
- React Router
- Tailwind CSS
- React Hook Form
- Axios
- React Query

### DevOps
- Docker & Docker Compose

---

## Quick Start with Docker

```bash
# Clone repository
git clone https://github.com/giovannimanyumbu/gzu-e-requisition-system.git
cd gzu-e-requisition-system

# Start all services
docker-compose up --build

# Access the application
Frontend: http://localhost:3000
Backend: http://localhost:5000
Database: localhost:5432
```

---

## Documentation

- **[API Specification](docs/API_SPECIFICATION.md)** - Complete API endpoints
- **[Architecture](docs/ARCHITECTURE.md)** - System design and data flow
- **[Database Design](docs/DATABASE_DESIGN.md)** - Schema and relationships
- **[Setup Guide](docs/SETUP_GUIDE.md)** - Development environment setup

---

## User Roles

1. **Claimant** – Raises requisitions and acquittals
2. **Recommending User** – Department-level approval
3. **Authorising User** – University-level approval
4. **Planning Office** – Budget verification
5. **Bursary** – Pass for payment
6. **Creditors' Office** – Process payments
7. **Audit** – View completed requests (read-only)
8. **Security** – View completed requests (read-only)
9. **Administrator** – System administration

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

For questions or contributions, contact Giovanni S. Manyumbu.
