import React from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  Avatar,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Chip,
  Button,
  Alert,
} from '@mui/material';
import {
  CalendarToday,
  Science,
  Medication,
  Message,
  TrendingUp,
  Warning,
  CheckCircle,
} from '@mui/icons-material';
import { useQuery } from 'react-query';
import { format, isToday, isTomorrow } from 'date-fns';

// API functions
import { getDashboardData } from '../../api/dashboard';

// Types
interface DashboardData {
  patient: {
    firstName: string;
    lastName: string;
    dateOfBirth: string;
    avatar?: string;
  };
  upcomingAppointments: Array<{
    id: string;
    date: string;
    time: string;
    provider: string;
    type: string;
    location: string;
  }>;
  recentLabResults: Array<{
    id: string;
    testName: string;
    result: string;
    status: 'normal' | 'abnormal' | 'critical';
    date: string;
  }>;
  currentMedications: Array<{
    id: string;
    name: string;
    dosage: string;
    frequency: string;
    nextDose?: string;
  }>;
  unreadMessages: number;
  healthAlerts: Array<{
    id: string;
    type: 'warning' | 'info' | 'success';
    message: string;
    date: string;
  }>;
}

const Dashboard: React.FC = () => {
  const { data, isLoading, error } = useQuery<DashboardData>('dashboard', getDashboardData);

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <Typography>Loading dashboard...</Typography>
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ m: 2 }}>
        Failed to load dashboard data. Please try again later.
      </Alert>
    );
  }

  if (!data) return null;

  const getAppointmentDateLabel = (dateStr: string) => {
    const date = new Date(dateStr);
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    return format(date, 'MMM dd');
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'normal': return 'success';
      case 'abnormal': return 'warning';
      case 'critical': return 'error';
      default: return 'default';
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      {/* Welcome Header */}
      <Box sx={{ mb: 4, display: 'flex', alignItems: 'center', gap: 2 }}>
        <Avatar
          src={data.patient.avatar}
          sx={{ width: 64, height: 64, bgcolor: 'primary.main' }}
        >
          {data.patient.firstName[0]}{data.patient.lastName[0]}
        </Avatar>
        <Box>
          <Typography variant="h4" gutterBottom>
            Welcome back, {data.patient.firstName}!
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Here's your health overview for today
          </Typography>
        </Box>
      </Box>

      {/* Health Alerts */}
      {data.healthAlerts.length > 0 && (
        <Box sx={{ mb: 3 }}>
          {data.healthAlerts.map((alert) => (
            <Alert
              key={alert.id}
              severity={alert.type}
              sx={{ mb: 1 }}
              action={
                <Button color="inherit" size="small">
                  View Details
                </Button>
              }
            >
              {alert.message}
            </Alert>
          ))}
        </Box>
      )}

      <Grid container spacing={3}>
        {/* Upcoming Appointments */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={2}>
                <CalendarToday color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Upcoming Appointments</Typography>
              </Box>
              {data.upcomingAppointments.length === 0 ? (
                <Typography color="text.secondary">
                  No upcoming appointments scheduled
                </Typography>
              ) : (
                <List dense>
                  {data.upcomingAppointments.slice(0, 3).map((appointment) => (
                    <ListItem key={appointment.id} divider>
                      <ListItemText
                        primary={
                          <Box display="flex" justifyContent="space-between" alignItems="center">
                            <Typography variant="subtitle2">
                              {appointment.provider}
                            </Typography>
                            <Chip
                              label={getAppointmentDateLabel(appointment.date)}
                              size="small"
                              color={isToday(new Date(appointment.date)) ? 'primary' : 'default'}
                            />
                          </Box>
                        }
                        secondary={
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              {appointment.type} • {appointment.time}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              {appointment.location}
                            </Typography>
                          </Box>
                        }
                      />
                    </ListItem>
                  ))}
                </List>
              )}
              <Box mt={2}>
                <Button variant="outlined" fullWidth>
                  View All Appointments
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Recent Lab Results */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={2}>
                <Science color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Recent Lab Results</Typography>
              </Box>
              {data.recentLabResults.length === 0 ? (
                <Typography color="text.secondary">
                  No recent lab results available
                </Typography>
              ) : (
                <List dense>
                  {data.recentLabResults.slice(0, 3).map((result) => (
                    <ListItem key={result.id} divider>
                      <ListItemIcon>
                        {result.status === 'normal' ? (
                          <CheckCircle color="success" />
                        ) : result.status === 'critical' ? (
                          <Warning color="error" />
                        ) : (
                          <TrendingUp color="warning" />
                        )}
                      </ListItemIcon>
                      <ListItemText
                        primary={
                          <Box display="flex" justifyContent="space-between" alignItems="center">
                            <Typography variant="subtitle2">
                              {result.testName}
                            </Typography>
                            <Chip
                              label={result.status}
                              size="small"
                              color={getStatusColor(result.status) as any}
                            />
                          </Box>
                        }
                        secondary={
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              {result.result}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              {format(new Date(result.date), 'MMM dd, yyyy')}
                            </Typography>
                          </Box>
                        }
                      />
                    </ListItem>
                  ))}
                </List>
              )}
              <Box mt={2}>
                <Button variant="outlined" fullWidth>
                  View All Results
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Current Medications */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" mb={2}>
                <Medication color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Current Medications</Typography>
              </Box>
              {data.currentMedications.length === 0 ? (
                <Typography color="text.secondary">
                  No current medications
                </Typography>
              ) : (
                <List dense>
                  {data.currentMedications.slice(0, 3).map((medication) => (
                    <ListItem key={medication.id} divider>
                      <ListItemText
                        primary={
                          <Typography variant="subtitle2">
                            {medication.name}
                          </Typography>
                        }
                        secondary={
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              {medication.dosage} • {medication.frequency}
                            </Typography>
                            {medication.nextDose && (
                              <Typography variant="body2" color="primary">
                                Next dose: {medication.nextDose}
                              </Typography>
                            )}
                          </Box>
                        }
                      />
                    </ListItem>
                  ))}
                </List>
              )}
              <Box mt={2}>
                <Button variant="outlined" fullWidth>
                  View All Medications
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Messages */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" justifyContent="space-between" mb={2}>
                <Box display="flex" alignItems="center">
                  <Message color="primary" sx={{ mr: 1 }} />
                  <Typography variant="h6">Messages</Typography>
                </Box>
                {data.unreadMessages > 0 && (
                  <Chip
                    label={`${data.unreadMessages} unread`}
                    color="primary"
                    size="small"
                  />
                )}
              </Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Stay connected with your healthcare team
              </Typography>
              <Box display="flex" gap={1}>
                <Button variant="contained" fullWidth>
                  View Messages
                </Button>
                <Button variant="outlined" fullWidth>
                  New Message
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
