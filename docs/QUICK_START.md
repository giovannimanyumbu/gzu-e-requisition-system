# GZU E-Requisition System - Project Setup Guide

## ✅ Phase 1: Repository Initialization Complete

Your GitHub repository has been successfully initialized with the following core files:

1. ✅ README.md
2. ✅ docker-compose.yml
3. ✅ .gitignore
4. ✅ LICENSE
5. ✅ backend/package.json

---

## 📋 What's Included

### Backend Structure
```
backend/
├── .env.example              # Environment variables template
├── package.json              # Dependencies (Express, PostgreSQL, JWT, etc.)
├── Dockerfile                # Container configuration
└── src/
    ├── app.js                # Express app entry point
    ├── config/               # Database & env config
    ├── controllers/          # Route controllers
    ├── models/               # Sequelize models
    ├── routes/               # API routes
    ├── middleware/           # Auth, RBAC middleware
    ├── services/             # Business logic
    └── utils/                # Helper functions
```

### Frontend Structure
```
frontend/
├── .env.example              # React environment vars
├── package.json              # React dependencies
├── Dockerfile                # React container setup
├── nginx.conf                # Nginx configuration
└── src/
    ├── components/           # Reusable React components
    ├── pages/                # Page components
    ├── services/             # API calls
    ├── hooks/                # Custom React hooks
    ├── context/              # Context API state
    └── styles/               # Tailwind CSS styles
```

### Database
```
database/
├── schema.sql                # PostgreSQL schema
├── migrations/               # Sequelize migrations
└── seeds/                    # Sample data
```

### Documentation
```
docs/
├── API_SPECIFICATION.md      # Complete API endpoints
├── ARCHITECTURE.md           # System design
├── DATABASE_DESIGN.md        # Schema & relationships
├── WORKFLOW_GUIDE.md         # Approval workflow
└── SETUP_GUIDE.md            # Development setup
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js v14+
- PostgreSQL 12+
- Docker & Docker Compose

### Run with Docker

```bash
# Clone your repository
git clone https://github.com/giovannimanyumbu/gzu-e-requisition-system.git
cd gzu-e-requisition-system

# Start all services
docker-compose up --build

# Services running on:
# Frontend:  http://localhost:3000
# Backend:   http://localhost:5000
# Database:  localhost:5432
```

### Manual Setup

1. **Copy environment file**
   ```bash
   cp backend/.env.example backend/.env
   ```

2. **Install dependencies**
   ```bash
   cd backend && npm install
   cd ../frontend && npm install
   ```

3. **Create database**
   ```bash
   createdb gzu_requisition
   psql gzu_requisition < database/schema.sql
   ```

4. **Start services**
   ```bash
   # Terminal 1: Backend
   cd backend
   npm run dev

   # Terminal 2: Frontend
   cd frontend
   npm start
   ```

---

## 📚 Next Steps

1. **Review Architecture** → See `docs/ARCHITECTURE.md`
2. **Check API Docs** → See `docs/API_SPECIFICATION.md`
3. **Database Design** → See `docs/DATABASE_DESIGN.md`
4. **Workflow Guide** → See `docs/WORKFLOW_GUIDE.md`

---

## 🔧 Tech Stack

| Component | Technology |
|-----------|-----------|
| **Frontend** | React 18+, Tailwind CSS, React Query |
| **Backend** | Node.js, Express.js, Sequelize |
| **Database** | PostgreSQL 14 |
| **Auth** | JWT (JSON Web Tokens) |
| **Containerization** | Docker, Docker Compose |
| **API** | REST with Express |

---

## 👥 User Roles (9 Total)

1. **Claimant** - Create requisitions
2. **Recommending User** - Department approval
3. **Authorising User** - University approval
4. **Planning Office** - Budget verification
5. **Bursary** - Payment authorization
6. **Creditors' Office** - Payment processing
7. **Audit** - View completed requests
8. **Security** - View completed requests
9. **Administrator** - System administration

---

## 📊 Workflow Stages (6 Total)

1. **Claiming** - Claimant submits requisition
2. **Recommending** - Recommending User approves/rejects
3. **Authorisation** - Authorising User approves/rejects
4. **Verification** - Planning Office verifies budget
5. **Passing for Payment** - Bursary approves payment
6. **Payment** - Creditors' Office processes payment

---

## 🔗 Important Files

- **docker-compose.yml** - Complete stack orchestration
- **backend/.env.example** - Configuration template
- **database/schema.sql** - Database initialization
- **docs/** - Comprehensive documentation

---

## 📝 Environment Variables

Create `backend/.env` from `backend/.env.example`:

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://gzu_user:gzu_password_secure@localhost:5432/gzu_requisition
JWT_SECRET=your_secret_key_here
JWT_EXPIRE=24h
CORS_ORIGIN=http://localhost:3000
```

---

## 🆘 Support

For questions or issues:
- Review documentation in `docs/` folder
- Check API specification: `docs/API_SPECIFICATION.md`
- Review architecture: `docs/ARCHITECTURE.md`

---

## 📄 License

MIT License - See LICENSE file

---

## 👨‍💻 Developer

**Giovanni S. Manyumbu**

---

**Last Updated:** June 4, 2025
**Repository:** https://github.com/giovannimanyumbu/gzu-e-requisition-system
