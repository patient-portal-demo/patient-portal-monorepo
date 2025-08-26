# Patient Portal Architecture

## System Overview

The Patient Portal is designed as a modern, cloud-native healthcare application following microservices principles and HIPAA compliance requirements.

## Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Patient Web   │    │   Provider Web   │    │  Admin Portal   │
│   Application   │    │   Application    │    │   Application   │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Application Load      │
                    │      Balancer          │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │      API Gateway       │
                    │   (Authentication &    │
                    │    Rate Limiting)      │
                    └────────────┬────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
┌─────────▼───────┐    ┌─────────▼───────┐    ┌─────────▼───────┐
│   Patient API   │    │  Provider API   │    │   Admin API     │
│   (FastAPI)     │    │   (FastAPI)     │    │   (FastAPI)     │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │    Database Layer      │
                    │   (PostgreSQL RDS)     │
                    └─────────────────────────┘
```

## Technology Stack

### Frontend Layer
- **Framework**: React 18 with TypeScript
- **State Management**: Redux Toolkit + RTK Query
- **UI Components**: Material-UI (MUI) v5
- **Routing**: React Router v6
- **Forms**: React Hook Form with Yup validation
- **Charts**: Recharts for lab result visualizations
- **Testing**: Jest + React Testing Library
- **Build Tool**: Vite for fast development

### Backend Layer
- **Framework**: FastAPI (Python 3.11)
- **Database ORM**: SQLAlchemy 2.0 with async support
- **Authentication**: JWT with AWS Cognito integration
- **Validation**: Pydantic v2 for request/response models
- **Database Migrations**: Alembic
- **Testing**: Pytest with async support
- **Documentation**: Automatic OpenAPI/Swagger generation

### Database Layer
- **Primary Database**: Amazon RDS PostgreSQL 15
- **Connection Pooling**: SQLAlchemy async engine
- **Backup Strategy**: Automated daily backups with 30-day retention
- **Encryption**: Encryption at rest and in transit
- **Monitoring**: CloudWatch metrics and Performance Insights

### Infrastructure Layer
- **IaC**: AWS CDK (TypeScript)
- **Container Orchestration**: Amazon ECS Fargate
- **Load Balancing**: Application Load Balancer
- **CDN**: CloudFront for static assets
- **DNS**: Route 53 with health checks
- **Monitoring**: CloudWatch + X-Ray + AWS Config

## Security Architecture

### Authentication & Authorization
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Patient   │    │  Provider   │    │    Admin    │
│    Login    │    │    Login    │    │    Login    │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
              ┌───────────▼───────────┐
              │    AWS Cognito       │
              │   User Pools         │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │   JWT Token          │
              │   Validation         │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │   Role-Based         │
              │   Access Control     │
              └─────────────────────────┘
```

### Data Protection
- **Encryption at Rest**: AES-256 encryption for database and S3
- **Encryption in Transit**: TLS 1.3 for all communications
- **Key Management**: AWS KMS for encryption key management
- **Data Masking**: PII masking in non-production environments
- **Audit Logging**: Comprehensive audit trail for all data access

## Data Models

### Core Entities

#### Patient
```sql
patients (
    id UUID PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address JSONB,
    emergency_contact JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
)
```

#### Appointment
```sql
appointments (
    id UUID PRIMARY KEY,
    patient_id UUID REFERENCES patients(id),
    provider_id UUID REFERENCES providers(id),
    appointment_date TIMESTAMP NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    appointment_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
)
```

#### Lab Result
```sql
lab_results (
    id UUID PRIMARY KEY,
    patient_id UUID REFERENCES patients(id),
    test_name VARCHAR(200) NOT NULL,
    test_code VARCHAR(50),
    result_value DECIMAL(10,3),
    result_unit VARCHAR(20),
    reference_range VARCHAR(100),
    status VARCHAR(20),
    collected_date TIMESTAMP,
    resulted_date TIMESTAMP,
    provider_notes TEXT
)
```

#### Medication
```sql
medications (
    id UUID PRIMARY KEY,
    patient_id UUID REFERENCES patients(id),
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    instructions TEXT,
    prescribed_date DATE,
    start_date DATE,
    end_date DATE,
    prescriber_id UUID REFERENCES providers(id),
    status VARCHAR(20) DEFAULT 'active'
)
```

## API Design

### RESTful Endpoints

#### Patient Endpoints
```
GET    /api/v1/patients/me                    # Get current patient profile
PUT    /api/v1/patients/me                    # Update patient profile
GET    /api/v1/patients/me/appointments       # Get patient appointments
GET    /api/v1/patients/me/lab-results        # Get patient lab results
GET    /api/v1/patients/me/medications        # Get patient medications
GET    /api/v1/patients/me/messages           # Get patient messages
POST   /api/v1/patients/me/messages           # Send message to provider
```

#### Appointment Endpoints
```
GET    /api/v1/appointments                   # List appointments (filtered)
GET    /api/v1/appointments/{id}              # Get appointment details
POST   /api/v1/appointments                   # Schedule new appointment
PUT    /api/v1/appointments/{id}              # Update appointment
DELETE /api/v1/appointments/{id}              # Cancel appointment
```

#### Lab Results Endpoints
```
GET    /api/v1/lab-results                    # List lab results (filtered)
GET    /api/v1/lab-results/{id}               # Get detailed lab result
GET    /api/v1/lab-results/{id}/trends        # Get result trends over time
POST   /api/v1/lab-results/{id}/explanation   # Get AI explanation of results
```

### Response Format
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_123456789",
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

## Deployment Architecture

### Development Environment
```
┌─────────────────┐    ┌─────────────────┐
│   Local React   │    │  Local FastAPI  │
│   Dev Server    │    │   Dev Server    │
│   (Port 3000)   │    │   (Port 8000)   │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
        ┌────────────▼────────────┐
        │   Local PostgreSQL     │
        │   (Docker Container)   │
        └─────────────────────────┘
```

### Production Environment
```
┌─────────────────┐
│   CloudFront    │
│      CDN        │
└─────────┬───────┘
          │
┌─────────▼───────┐
│   S3 Bucket     │
│  Static Assets  │
└─────────────────┘

┌─────────────────┐    ┌─────────────────┐
│      ALB        │    │   ECS Fargate   │
│  Load Balancer  │────│   Cluster       │
└─────────────────┘    └─────────┬───────┘
                                 │
                    ┌────────────▼────────────┐
                    │     RDS PostgreSQL     │
                    │    Multi-AZ Setup      │
                    └─────────────────────────┘
```

## Performance Considerations

### Frontend Optimization
- **Code Splitting**: Route-based and component-based splitting
- **Lazy Loading**: Images and non-critical components
- **Caching**: Service worker for offline functionality
- **Bundle Size**: Tree shaking and dynamic imports
- **CDN**: Static assets served from CloudFront

### Backend Optimization
- **Database Indexing**: Optimized indexes for common queries
- **Connection Pooling**: Async connection pool management
- **Caching**: Redis for session and frequently accessed data
- **Query Optimization**: N+1 query prevention with eager loading
- **Rate Limiting**: API rate limiting to prevent abuse

### Database Optimization
- **Partitioning**: Table partitioning for large datasets
- **Read Replicas**: Read replicas for reporting queries
- **Connection Pooling**: PgBouncer for connection management
- **Monitoring**: Performance Insights for query optimization

## Monitoring & Observability

### Application Metrics
- **Custom Metrics**: Business-specific metrics in CloudWatch
- **Performance Metrics**: Response times, throughput, error rates
- **User Metrics**: Active users, feature usage, conversion rates

### Logging Strategy
- **Structured Logging**: JSON format with correlation IDs
- **Log Levels**: DEBUG, INFO, WARN, ERROR with appropriate filtering
- **Centralized Logging**: CloudWatch Logs with log groups per service
- **Log Retention**: 30 days for application logs, 1 year for audit logs

### Alerting
- **Error Rate Alerts**: >5% error rate triggers immediate alert
- **Performance Alerts**: >2s response time triggers warning
- **Infrastructure Alerts**: CPU, memory, disk usage thresholds
- **Business Alerts**: Failed appointments, medication alerts

## Compliance & Governance

### HIPAA Compliance
- **Data Encryption**: All PHI encrypted at rest and in transit
- **Access Controls**: Role-based access with audit logging
- **Data Retention**: Automated data lifecycle management
- **Breach Detection**: Automated monitoring for unauthorized access

### Disaster Recovery
- **RTO**: Recovery Time Objective of 4 hours
- **RPO**: Recovery Point Objective of 1 hour
- **Backup Strategy**: Daily automated backups with cross-region replication
- **Failover**: Automated failover to secondary region

### Change Management
- **CI/CD Pipeline**: Automated testing and deployment
- **Environment Promotion**: Dev → Staging → Production
- **Rollback Strategy**: Blue-green deployments with instant rollback
- **Change Approval**: Required approvals for production changes

## 🚀 Monorepo Development Setup

### Prerequisites
- Node.js 18+
- Python 3.11+
- Docker
- AWS CLI configured
- PostgreSQL (for local development)

### Quick Start
```bash
# Clone the monorepo
git clone https://github.com/patient-portal-demo/patient-portal-monorepo.git
cd patient-portal-monorepo

# Install all dependencies using npm workspaces
npm install

# Set up database
cd packages/database-schema
docker-compose up -d postgres
python -m alembic upgrade head

# Start development servers
npm run dev:backend     # Backend API on port 8000
npm run dev:frontend    # Frontend on port 3000
```

### Workspace Commands
```bash
# Build all applications
npm run build

# Test all applications  
npm test

# Lint all code
npm run lint

# Deploy infrastructure
npm run deploy:infrastructure

# Run database migrations
npm run db:migrate
```

## 📂 Monorepo Benefits

### Unified Development
- **Single Repository**: All components in one place
- **Shared Dependencies**: Common packages managed centrally
- **Consistent Tooling**: Unified linting, testing, and build processes
- **Atomic Changes**: Cross-component changes in single commits

### Simplified CI/CD
- **Single Pipeline**: One GitHub Actions workflow for all components
- **Coordinated Deployments**: Deploy frontend, backend, and infrastructure together
- **Dependency Management**: Automatic dependency updates across all packages
- **Security Scanning**: Centralized security scanning for all components

### Better Documentation
- **Centralized Docs**: All documentation in one place
- **Consistent Structure**: Standardized documentation format
- **Cross-References**: Easy linking between component documentation
- **Version Alignment**: Documentation always matches code version

