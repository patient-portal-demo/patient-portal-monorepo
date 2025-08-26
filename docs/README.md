# Patient Portal Demo - Documentation

This directory contains comprehensive documentation for the Patient Portal monorepo.

## 📁 Monorepo Structure

```
patient-portal-monorepo/
├── apps/                        # Applications
│   ├── frontend-app/            # React TypeScript frontend
│   └── backend-api/             # Python FastAPI backend
├── packages/                    # Shared packages
│   ├── database-schema/         # PostgreSQL schema and migrations
│   └── infrastructure/          # AWS CDK infrastructure code
├── docs/                        # Documentation (this folder)
├── scripts/                     # Build and deployment scripts
├── .github/workflows/           # CI/CD workflows
└── README.md                    # Main project documentation
```

## 🚀 Quick Start

### Clone and Setup
```bash
git clone https://github.com/patient-portal-demo/patient-portal-monorepo.git
cd patient-portal-monorepo
npm install
```

### Development Commands
```bash
npm run dev:frontend    # Start frontend (port 3000)
npm run dev:backend     # Start backend (port 8000)
npm run build          # Build all applications
npm test               # Run all tests
```

## 📚 Documentation Files

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed system architecture
- **[../README.md](../README.md)** - Main project documentation
- **[../CONTRIBUTING.md](../CONTRIBUTING.md)** - Development guidelines

## 🔗 Repository

**Main Repository**: https://github.com/patient-portal-demo/patient-portal-monorepo

All components are now consolidated in this single monorepo for easier development and deployment.
