# Patient Portal Demo

A comprehensive healthcare patient portal application built with modern web technologies and AWS cloud services.

## 🏥 Overview

The Patient Portal Demo is a full-stack healthcare application that enables patients to:

- **View Appointments**: See upcoming and past appointments with healthcare providers
- **Access Lab Results**: View test results with detailed explanations and normal ranges
- **Manage Medications**: Track prescriptions, dosages, and medication instructions
- **Communicate with Providers**: Send secure messages to healthcare teams
- **Access Medical Records**: View comprehensive health information and history

## 🏗 Architecture

### Frontend
- **Technology**: React 18 with TypeScript
- **UI Framework**: Material-UI (MUI) for consistent healthcare UX
- **State Management**: Redux Toolkit for complex state management
- **Authentication**: AWS Cognito integration
- **Hosting**: AWS CloudFront + S3

### Backend
- **Technology**: Python 3.11 with FastAPI
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Authentication**: JWT tokens with AWS Cognito
- **API Documentation**: Automatic OpenAPI/Swagger generation
- **Hosting**: AWS ECS Fargate

### Database
- **Primary Database**: Amazon RDS PostgreSQL
- **Schema Management**: Alembic migrations
- **Data Models**: Patients, Appointments, Lab Results, Medications, Messages

### Infrastructure
- **IaC**: AWS CDK (TypeScript)
- **Container Registry**: Amazon ECR
- **Load Balancing**: Application Load Balancer
- **Monitoring**: CloudWatch + X-Ray
- **Security**: VPC, Security Groups, IAM roles

## 📁 Repository Structure

```
patient-portal-demo/
├── patient-portal-org/          # Main documentation and overview
├── frontend-app/                # React TypeScript frontend
├── backend-api/                 # Python FastAPI backend
├── database-schema/             # PostgreSQL schema and migrations
└── infrastructure/              # AWS CDK infrastructure code
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Python 3.11+
- Docker
- AWS CLI configured
- PostgreSQL (for local development)

### Local Development Setup

1. **Clone all repositories**:
```bash
git clone https://github.com/patient-portal-demo/patient-portal-org.git
git clone https://github.com/patient-portal-demo/frontend-app.git
git clone https://github.com/patient-portal-demo/backend-api.git
git clone https://github.com/patient-portal-demo/database-schema.git
git clone https://github.com/patient-portal-demo/infrastructure.git
```

2. **Set up the database**:
```bash
cd database-schema
docker-compose up -d postgres
python -m alembic upgrade head
```

3. **Start the backend**:
```bash
cd backend-api
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

4. **Start the frontend**:
```bash
cd frontend-app
npm install
npm start
```

5. **Access the application**:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

## 🏥 Sample Data

The application includes realistic sample data for demonstration:

### Sample Patients
- **John Smith** (DOB: 1985-03-15) - Diabetes management
- **Sarah Johnson** (DOB: 1992-07-22) - Routine care
- **Michael Brown** (DOB: 1978-11-08) - Hypertension monitoring

### Sample Lab Results
- Complete Blood Count (CBC)
- Comprehensive Metabolic Panel (CMP)
- Lipid Panel
- HbA1c (Diabetes monitoring)
- Thyroid Function Tests

### Sample Medications
- Metformin 500mg (Diabetes)
- Lisinopril 10mg (Blood pressure)
- Atorvastatin 20mg (Cholesterol)
- Levothyroxine 75mcg (Thyroid)

## 🔒 Security Features

- **HIPAA Compliance**: Encrypted data at rest and in transit
- **Authentication**: Multi-factor authentication support
- **Authorization**: Role-based access control
- **Audit Logging**: Comprehensive access and action logging
- **Data Encryption**: AES-256 encryption for sensitive data

## 📊 Key Features

### Patient Dashboard
- Personalized health summary
- Upcoming appointments widget
- Recent lab results overview
- Medication reminders
- Provider messages inbox

### Appointment Management
- View upcoming appointments
- Appointment history
- Provider information
- Visit notes and instructions

### Lab Results
- Interactive results viewer
- Trend analysis over time
- Normal range indicators
- Provider explanations
- Downloadable reports

### Medication Management
- Current prescriptions list
- Dosage instructions
- Refill reminders
- Drug interaction warnings
- Medication history

### Provider Communication
- Secure messaging system
- Message threading
- File attachments
- Read receipts
- Provider response tracking

## 🧪 Testing

### Frontend Testing
```bash
cd frontend-app
npm test                    # Unit tests
npm run test:e2e           # End-to-end tests
npm run test:coverage      # Coverage report
```

### Backend Testing
```bash
cd backend-api
pytest                     # Unit and integration tests
pytest --cov=app          # Coverage report
```

## 🚀 Deployment

### AWS Deployment
```bash
cd infrastructure
npm install
cdk bootstrap
cdk deploy --all
```

### Environment Configuration
- **Development**: Local development with Docker
- **Staging**: AWS ECS with RDS (single AZ)
- **Production**: AWS ECS with RDS Multi-AZ, CloudFront CDN

## 📈 Monitoring & Analytics

- **Application Metrics**: CloudWatch custom metrics
- **Performance Monitoring**: AWS X-Ray distributed tracing
- **Error Tracking**: CloudWatch Logs with structured logging
- **User Analytics**: Privacy-compliant usage analytics

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
- Create an issue in the relevant repository
- Check the [Wiki](https://github.com/patient-portal-demo/patient-portal-org/wiki) for documentation
- Review the API documentation at `/docs` endpoint

## 🔗 Related Links

- [Frontend Repository](https://github.com/patient-portal-demo/frontend-app)
- [Backend Repository](https://github.com/patient-portal-demo/backend-api)
- [Database Schema](https://github.com/patient-portal-demo/database-schema)
- [Infrastructure Code](https://github.com/patient-portal-demo/infrastructure)

---

**Note**: This is a demonstration application for showcasing modern healthcare technology solutions. It includes realistic sample data but should not be used with actual patient information without proper HIPAA compliance measures.
