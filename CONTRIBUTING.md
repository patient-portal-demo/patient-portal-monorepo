# Contributing to Patient Portal Monorepo

Thank you for your interest in contributing to the Patient Portal project! This document provides guidelines for contributing to this monorepo.

## 🏗 Development Setup

### Prerequisites
- Node.js 18+ and npm 9+
- Python 3.11+ (for backend services)
- AWS CLI configured
- Docker (for local development)

### Getting Started
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

```
patient-portal-monorepo/
├── apps/                      # Applications
│   ├── frontend-app/          # React TypeScript frontend
│   └── backend-api/           # Node.js/Python backend API
├── packages/                  # Shared packages
│   ├── database-schema/       # Database schemas and migrations
│   └── infrastructure/        # AWS CDK/CloudFormation IaC
├── docs/                      # Documentation
└── .github/workflows/         # CI/CD workflows
```

## 🔄 Development Workflow

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature development branches
- `hotfix/*` - Critical bug fixes

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   npm run test           # Run all tests
   npm run lint           # Check code style
   npm run build          # Ensure everything builds
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Format
Follow conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## 🧪 Testing Guidelines

### Frontend Testing
```bash
cd apps/frontend-app
npm run test           # Unit tests with Jest
npm run test:e2e       # End-to-end tests
```

### Backend Testing
```bash
cd apps/backend-api
python -m pytest      # Python tests
npm run test           # Node.js tests (if applicable)
```

### Integration Testing
```bash
npm run test:integration  # Cross-service integration tests
```

## 📋 Code Style

### TypeScript/JavaScript
- Use TypeScript for all new frontend code
- Follow ESLint and Prettier configurations
- Use functional components with hooks
- Implement proper error boundaries

### Python
- Follow PEP 8 style guidelines
- Use type hints for function signatures
- Write docstrings for all functions and classes
- Use pytest for testing

### General Guidelines
- Write self-documenting code
- Add comments for complex business logic
- Keep functions small and focused
- Use meaningful variable and function names

## 🔒 Security Guidelines

### HIPAA Compliance
- Never commit real patient data
- Use placeholder data for testing
- Implement proper access controls
- Follow data encryption requirements

### Code Security
- Never commit secrets or API keys
- Use environment variables for configuration
- Validate all inputs
- Implement proper authentication and authorization

## 📚 Documentation

### Code Documentation
- Document all public APIs
- Include usage examples
- Update README files when adding features
- Document configuration options

### Architecture Documentation
- Update architecture diagrams for significant changes
- Document design decisions
- Include deployment instructions
- Maintain troubleshooting guides

## 🚀 Deployment

### Development
```bash
npm run build:dev
npm run deploy:dev
```

### Staging
```bash
npm run build:staging
npm run deploy:staging
```

### Production
Production deployments are automated via GitHub Actions on merge to `main`.

## 🐛 Bug Reports

When reporting bugs, please include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, Node version, etc.)
- Screenshots or logs (if applicable)

## 💡 Feature Requests

For new features:
- Describe the use case
- Explain the expected behavior
- Consider implementation complexity
- Discuss potential alternatives

## 📞 Getting Help

- Create an issue for bugs or feature requests
- Check existing documentation in `docs/`
- Review the project README
- Contact the development team

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to the Patient Portal project! 🏥
