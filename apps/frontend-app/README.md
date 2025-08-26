# Patient Portal Frontend

A modern React TypeScript frontend application for the Patient Portal healthcare system.

## 🏥 Features

### Patient Dashboard
- Personalized health overview
- Upcoming appointments summary
- Recent lab results with status indicators
- Current medications list
- Unread messages count
- Health alerts and notifications

### Appointment Management
- View upcoming and past appointments
- Appointment details with provider information
- Appointment status tracking
- Rescheduling capabilities (future enhancement)

### Lab Results
- Interactive results viewer with trend analysis
- Normal range indicators and explanations
- Historical data visualization
- Downloadable reports
- Provider explanations for abnormal results

### Medication Management
- Current prescriptions with dosage information
- Medication instructions and side effects
- Refill reminders and status
- Drug interaction warnings
- Medication history tracking

### Provider Communication
- Secure messaging system with healthcare providers
- Message threading and organization
- File attachment support
- Read receipts and response tracking
- Message categorization (appointment, prescription, general)

## 🛠 Technology Stack

- **Framework**: React 18 with TypeScript
- **State Management**: Redux Toolkit + RTK Query
- **UI Library**: Material-UI (MUI) v5
- **Routing**: React Router v6
- **Forms**: React Hook Form with Yup validation
- **Charts**: Recharts for data visualization
- **HTTP Client**: Axios with interceptors
- **Testing**: Jest + React Testing Library
- **Build Tool**: Vite for fast development

## 📁 Project Structure

```
src/
├── components/           # Reusable UI components
│   ├── Layout/          # Application layout components
│   ├── Forms/           # Form components
│   ├── Charts/          # Data visualization components
│   └── Common/          # Common UI components
├── pages/               # Page components
│   ├── Dashboard/       # Patient dashboard
│   ├── Appointments/    # Appointment management
│   ├── LabResults/      # Lab results viewer
│   ├── Medications/     # Medication management
│   ├── Messages/        # Provider messaging
│   ├── Profile/         # Patient profile
│   └── Auth/           # Authentication pages
├── hooks/               # Custom React hooks
├── store/               # Redux store configuration
├── api/                 # API client and endpoints
├── types/               # TypeScript type definitions
├── utils/               # Utility functions
└── styles/              # Global styles and themes
```

## 🚀 Getting Started

### Prerequisites
- Node.js 18 or higher
- npm or yarn package manager

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/patient-portal-demo/frontend-app.git
cd frontend-app
```

2. **Install dependencies**:
```bash
npm install
```

3. **Set up environment variables**:
```bash
cp .env.example .env.local
```

Edit `.env.local` with your configuration:
```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_APP_TITLE=Patient Portal
VITE_ENVIRONMENT=development
```

4. **Start the development server**:
```bash
npm run dev
```

The application will be available at `http://localhost:3000`.

## 🧪 Testing

### Unit Tests
```bash
npm test                 # Run tests once
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Generate coverage report
```

### End-to-End Tests
```bash
npm run test:e2e         # Run E2E tests
```

## 🏗 Building for Production

```bash
npm run build            # Build for production
npm run preview          # Preview production build locally
```

## 🔧 Development Guidelines

### Code Style
- Use TypeScript for all new code
- Follow React functional component patterns
- Use custom hooks for reusable logic
- Implement proper error boundaries
- Write comprehensive tests for components

### Component Structure
```typescript
// Component template
import React from 'react';
import { Box, Typography } from '@mui/material';

interface ComponentProps {
  title: string;
  children?: React.ReactNode;
}

const Component: React.FC<ComponentProps> = ({ title, children }) => {
  return (
    <Box>
      <Typography variant="h6">{title}</Typography>
      {children}
    </Box>
  );
};

export default Component;
```

### State Management
- Use Redux Toolkit for global state
- Use RTK Query for API calls
- Keep component state local when possible
- Use custom hooks for complex state logic

### API Integration
```typescript
// API service example
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const patientApi = createApi({
  reducerPath: 'patientApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1/',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ['Patient', 'Appointment', 'LabResult'],
  endpoints: (builder) => ({
    getPatientProfile: builder.query<Patient, void>({
      query: () => 'patients/me',
      providesTags: ['Patient'],
    }),
  }),
});
```

## 🎨 UI/UX Guidelines

### Design System
- Follow Material Design principles
- Use consistent spacing (8px grid system)
- Maintain color contrast ratios for accessibility
- Implement responsive design for all screen sizes

### Accessibility
- Use semantic HTML elements
- Provide alt text for images
- Ensure keyboard navigation support
- Maintain proper heading hierarchy
- Test with screen readers

### Performance
- Implement code splitting for routes
- Use React.memo for expensive components
- Optimize images and assets
- Minimize bundle size
- Implement proper loading states

## 🔒 Security Considerations

### Authentication
- JWT token storage in httpOnly cookies
- Automatic token refresh
- Secure logout functionality
- Session timeout handling

### Data Protection
- Input validation and sanitization
- XSS prevention
- CSRF protection
- Secure API communication (HTTPS only)

## 📱 Mobile Responsiveness

The application is fully responsive and optimized for:
- Desktop (1200px+)
- Tablet (768px - 1199px)
- Mobile (320px - 767px)

Key mobile features:
- Touch-friendly interface
- Optimized navigation
- Readable typography
- Accessible form controls

## 🚀 Deployment

### Development
```bash
npm run build:dev
```

### Staging
```bash
npm run build:staging
```

### Production
```bash
npm run build:prod
```

The build artifacts will be generated in the `dist/` directory and can be deployed to any static hosting service.

## 📊 Monitoring and Analytics

### Error Tracking
- Sentry integration for error monitoring
- User feedback collection
- Performance monitoring

### Analytics
- Privacy-compliant usage analytics
- User journey tracking
- Feature usage metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Pull Request Guidelines
- Include comprehensive tests
- Update documentation as needed
- Follow the existing code style
- Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Check the [Wiki](https://github.com/patient-portal-demo/frontend-app/wiki) for documentation
- Contact the development team

---

**Note**: This is a demonstration application for showcasing modern healthcare technology solutions. It should not be used with actual patient information without proper HIPAA compliance measures.
