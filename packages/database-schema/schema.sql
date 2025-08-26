-- Patient Portal Database Schema
-- PostgreSQL 15+ compatible
-- Includes all tables for patient data, appointments, lab results, medications, and messaging

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE appointment_status AS ENUM ('scheduled', 'confirmed', 'completed', 'cancelled', 'no-show');
CREATE TYPE medication_status AS ENUM ('active', 'discontinued', 'completed', 'on-hold');
CREATE TYPE lab_result_status AS ENUM ('normal', 'abnormal', 'critical', 'pending');
CREATE TYPE message_sender_type AS ENUM ('patient', 'provider');
CREATE TYPE alert_severity AS ENUM ('info', 'warning', 'critical');

-- Patients table
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address JSONB,
    emergency_contact JSONB,
    medical_record_number VARCHAR(50) UNIQUE NOT NULL,
    insurance_info JSONB,
    preferred_language VARCHAR(10) DEFAULT 'en',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for patients
CREATE INDEX idx_patients_email ON patients(email);
CREATE INDEX idx_patients_mrn ON patients(medical_record_number);
CREATE INDEX idx_patients_name ON patients(last_name, first_name);

-- Providers table
CREATE TABLE providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    title VARCHAR(50),
    specialty VARCHAR(100),
    department VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    office_location VARCHAR(200),
    bio TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for providers
CREATE INDEX idx_providers_email ON providers(email);
CREATE INDEX idx_providers_specialty ON providers(specialty);
CREATE INDEX idx_providers_department ON providers(department);

-- Appointments table
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE RESTRICT,
    appointment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    appointment_type VARCHAR(50),
    status appointment_status DEFAULT 'scheduled',
    location VARCHAR(200),
    reason TEXT,
    notes TEXT,
    instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for appointments
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_provider ON appointments(provider_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);

-- Lab results table
CREATE TABLE lab_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    test_name VARCHAR(200) NOT NULL,
    test_code VARCHAR(50),
    category VARCHAR(100),
    result_value DECIMAL(10,3),
    result_text TEXT,
    result_unit VARCHAR(20),
    reference_range VARCHAR(100),
    status lab_result_status,
    flags VARCHAR(10),
    collected_date TIMESTAMP WITH TIME ZONE,
    resulted_date TIMESTAMP WITH TIME ZONE,
    provider_notes TEXT,
    patient_explanation TEXT,
    is_critical BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for lab results
CREATE INDEX idx_lab_results_patient ON lab_results(patient_id);
CREATE INDEX idx_lab_results_test_name ON lab_results(test_name);
CREATE INDEX idx_lab_results_category ON lab_results(category);
CREATE INDEX idx_lab_results_date ON lab_results(resulted_date);
CREATE INDEX idx_lab_results_status ON lab_results(status);

-- Medications table
CREATE TABLE medications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    prescriber_id UUID NOT NULL REFERENCES providers(id) ON DELETE RESTRICT,
    medication_name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    dosage VARCHAR(100),
    strength VARCHAR(50),
    form VARCHAR(50),
    frequency VARCHAR(100),
    route VARCHAR(50),
    instructions TEXT,
    indication VARCHAR(200),
    quantity INTEGER,
    refills_remaining INTEGER DEFAULT 0,
    prescribed_date DATE NOT NULL,
    start_date DATE,
    end_date DATE,
    status medication_status DEFAULT 'active',
    side_effects JSONB,
    interactions JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for medications
CREATE INDEX idx_medications_patient ON medications(patient_id);
CREATE INDEX idx_medications_prescriber ON medications(prescriber_id);
CREATE INDEX idx_medications_name ON medications(medication_name);
CREATE INDEX idx_medications_status ON medications(status);
CREATE INDEX idx_medications_prescribed_date ON medications(prescribed_date);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE RESTRICT,
    thread_id UUID,
    subject VARCHAR(200) NOT NULL,
    message_body TEXT NOT NULL,
    sender_type message_sender_type NOT NULL,
    message_type VARCHAR(50) DEFAULT 'general',
    priority VARCHAR(20) DEFAULT 'normal',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    attachments JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for messages
CREATE INDEX idx_messages_patient ON messages(patient_id);
CREATE INDEX idx_messages_provider ON messages(provider_id);
CREATE INDEX idx_messages_thread ON messages(thread_id);
CREATE INDEX idx_messages_created ON messages(created_at);
CREATE INDEX idx_messages_unread ON messages(is_read) WHERE is_read = false;

-- Health alerts table
CREATE TABLE health_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL,
    severity alert_severity DEFAULT 'info',
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_required BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for health alerts
CREATE INDEX idx_health_alerts_patient ON health_alerts(patient_id);
CREATE INDEX idx_health_alerts_type ON health_alerts(alert_type);
CREATE INDEX idx_health_alerts_severity ON health_alerts(severity);
CREATE INDEX idx_health_alerts_unread ON health_alerts(is_read) WHERE is_read = false;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON providers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lab_results_updated_at BEFORE UPDATE ON lab_results
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medications_updated_at BEFORE UPDATE ON medications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create views for common queries

-- Patient dashboard view
CREATE VIEW patient_dashboard AS
SELECT 
    p.id,
    p.first_name,
    p.last_name,
    p.email,
    COUNT(DISTINCT a.id) FILTER (WHERE a.appointment_date > NOW() AND a.status = 'scheduled') as upcoming_appointments,
    COUNT(DISTINCT lr.id) FILTER (WHERE lr.resulted_date > NOW() - INTERVAL '30 days') as recent_lab_results,
    COUNT(DISTINCT m.id) FILTER (WHERE m.status = 'active') as active_medications,
    COUNT(DISTINCT msg.id) FILTER (WHERE msg.is_read = false AND msg.sender_type = 'provider') as unread_messages
FROM patients p
LEFT JOIN appointments a ON p.id = a.patient_id
LEFT JOIN lab_results lr ON p.id = lr.patient_id
LEFT JOIN medications m ON p.id = m.patient_id
LEFT JOIN messages msg ON p.id = msg.patient_id
WHERE p.is_active = true
GROUP BY p.id, p.first_name, p.last_name, p.email;

-- Recent lab results view
CREATE VIEW recent_lab_results AS
SELECT 
    lr.*,
    p.first_name,
    p.last_name
FROM lab_results lr
JOIN patients p ON lr.patient_id = p.id
WHERE lr.resulted_date > NOW() - INTERVAL '90 days'
ORDER BY lr.resulted_date DESC;

-- Active medications view
CREATE VIEW active_medications AS
SELECT 
    m.*,
    p.first_name,
    p.last_name,
    pr.first_name as prescriber_first_name,
    pr.last_name as prescriber_last_name,
    pr.title as prescriber_title
FROM medications m
JOIN patients p ON m.patient_id = p.id
JOIN providers pr ON m.prescriber_id = pr.id
WHERE m.status = 'active'
ORDER BY m.prescribed_date DESC;

-- Upcoming appointments view
CREATE VIEW upcoming_appointments AS
SELECT 
    a.*,
    p.first_name as patient_first_name,
    p.last_name as patient_last_name,
    pr.first_name as provider_first_name,
    pr.last_name as provider_last_name,
    pr.title as provider_title,
    pr.specialty as provider_specialty
FROM appointments a
JOIN patients p ON a.patient_id = p.id
JOIN providers pr ON a.provider_id = pr.id
WHERE a.appointment_date > NOW() 
AND a.status IN ('scheduled', 'confirmed')
ORDER BY a.appointment_date ASC;

-- Grant permissions (adjust as needed for your environment)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO patient_portal_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO patient_portal_app;
