# Patient Portal Monorepo

A comprehensive healthcare patient portal system built with modern web technologies and AWS cloud services.

## 🏗 Architecture Overview

This monorepo contains all components of the Patient Portal system:

```
patient-portal-monorepo/
├── apps/                      # Applications
│   ├── frontend-app/          # React TypeScript frontend
│   └── backend-api/           # Node.js/Python backend API
├── packages/                  # Shared packages
│   ├── database-schema/       # Database schemas and migrations
│   └── infrastructure/        # AWS CDK/CloudFormation IaC
├── docs/                      # Documentation and organization
├── scripts/                   # Build and deployment scripts
└── .github/workflows/         # CI/CD workflows
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- npm 9+
- AWS CLI configured
- Docker (for local development)

### Installation
```bash
# Clone the repository
git clone https://github.com/patient-portal-demo/patient-portal-monorepo.git
cd patient-portal-monorepo

# Install all dependencies
npm install

# Start development servers
npm run dev:frontend    # Frontend on http://localhost:3000
npm run dev:backend     # Backend API on http://localhost:8000
```

## 📁 Project Structure

### Apps
- **`apps/frontend-app/`** - React TypeScript frontend application
- **`apps/backend-api/`** - Backend API services

### Packages
- **`packages/database-schema/`** - Database schemas, migrations, and models
- **`packages/infrastructure/`** - AWS infrastructure as code (CDK/CloudFormation)

### Documentation
- **`docs/`** - Project documentation, architecture diagrams, and organization materials

## 🛠 Development

### Available Scripts

```bash
# Development
npm run dev:frontend          # Start frontend dev server
npm run dev:backend           # Start backend dev server

# Building
npm run build                 # Build all workspaces
npm run build:frontend        # Build frontend only
npm run build:backend         # Build backend only

# Testing
npm run test                  # Run tests in all workspaces
npm run lint                  # Lint all workspaces

# Infrastructure
npm run deploy:infrastructure # Deploy AWS infrastructure
npm run db:migrate           # Run database migrations
```

## 🏥 Features

### Patient Dashboard
- Personalized health overview
- Upcoming appointments summary
- Recent lab results with status indicators
- Current medications list
- Health alerts and notifications

### Appointment Management
- View upcoming and past appointments
- Appointment details with provider information
- Appointment status tracking
- Rescheduling capabilities

### Lab Results
- Interactive results viewer with trend analysis
- Normal range indicators and explanations
- Historical data visualization
- Downloadable reports

### Medication Management
- Current prescriptions with dosage information
- Medication instructions and side effects
- Refill reminders and status
- Drug interaction warnings

### Provider Communication
- Secure messaging system with healthcare providers
- Message threading and organization
- File attachment support

## 🔧 Technology Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **State Management**: Redux Toolkit + RTK Query
- **UI Library**: Material-UI (MUI) v5
- **Build Tool**: Vite

### Backend
- **Runtime**: Node.js/Python
- **Database**: PostgreSQL/DynamoDB
- **API**: REST/GraphQL
- **Authentication**: AWS Cognito

### Infrastructure
- **Cloud**: AWS
- **IaC**: AWS CDK
- **CI/CD**: GitHub Actions
- **Monitoring**: CloudWatch

## 🚀 Deployment

### Development
```bash
npm run build
npm run deploy:infrastructure
```

### Production
Deployments are automated via GitHub Actions on push to `main` branch.

## 📊 Monitoring

- **Application Monitoring**: AWS CloudWatch
- **Error Tracking**: AWS X-Ray
- **Performance**: CloudWatch Insights
- **Security**: AWS Security Hub

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Check the documentation in the `docs/` folder
- Contact the development team

---

**Note**: This is a healthcare application. Ensure HIPAA compliance and proper security measures are in place before handling real patient data.
