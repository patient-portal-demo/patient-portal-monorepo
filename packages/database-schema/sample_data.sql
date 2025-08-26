-- Sample Data for Patient Portal Demo
-- This file contains realistic sample data for demonstration purposes
-- DO NOT use with real patient data

-- Insert sample providers
INSERT INTO providers (id, first_name, last_name, title, specialty, department, email, phone, office_location, bio) VALUES
(uuid_generate_v4(), 'Sarah', 'Johnson', 'Dr.', 'Internal Medicine', 'Primary Care', 'sarah.johnson@healthcenter.com', '(555) 123-4567', 'Building A, Suite 101', 'Dr. Johnson specializes in preventive care and chronic disease management with over 15 years of experience.'),
(uuid_generate_v4(), 'Michael', 'Chen', 'Dr.', 'Endocrinology', 'Specialty Care', 'michael.chen@healthcenter.com', '(555) 123-4568', 'Building B, Suite 205', 'Dr. Chen is board-certified in endocrinology with expertise in diabetes management and thyroid disorders.'),
(uuid_generate_v4(), 'Emily', 'Rodriguez', 'NP', 'Family Medicine', 'Primary Care', 'emily.rodriguez@healthcenter.com', '(555) 123-4569', 'Building A, Suite 102', 'Emily Rodriguez is a certified nurse practitioner specializing in family medicine and women''s health.'),
(uuid_generate_v4(), 'David', 'Thompson', 'Dr.', 'Cardiology', 'Specialty Care', 'david.thompson@healthcenter.com', '(555) 123-4570', 'Building C, Suite 301', 'Dr. Thompson is a cardiologist with expertise in preventive cardiology and heart disease management.');

-- Insert sample patients
INSERT INTO patients (id, first_name, last_name, date_of_birth, email, phone, medical_record_number, address, emergency_contact, insurance_info) VALUES
(uuid_generate_v4(), 'John', 'Smith', '1985-03-15', 'john.smith@email.com', '(555) 987-6543', 'MRN001234', 
 '{"street": "123 Main St", "city": "Springfield", "state": "IL", "zip": "62701"}',
 '{"name": "Jane Smith", "relationship": "Spouse", "phone": "(555) 987-6544"}',
 '{"provider": "Blue Cross Blue Shield", "policy_number": "BC123456789", "group_number": "GRP001"}'),

(uuid_generate_v4(), 'Sarah', 'Johnson', '1992-07-22', 'sarah.johnson.patient@email.com', '(555) 987-6545', 'MRN001235',
 '{"street": "456 Oak Ave", "city": "Springfield", "state": "IL", "zip": "62702"}',
 '{"name": "Robert Johnson", "relationship": "Father", "phone": "(555) 987-6546"}',
 '{"provider": "Aetna", "policy_number": "AET987654321", "group_number": "GRP002"}'),

(uuid_generate_v4(), 'Michael', 'Brown', '1978-11-08', 'michael.brown@email.com', '(555) 987-6547', 'MRN001236',
 '{"street": "789 Pine St", "city": "Springfield", "state": "IL", "zip": "62703"}',
 '{"name": "Lisa Brown", "relationship": "Wife", "phone": "(555) 987-6548"}',
 '{"provider": "United Healthcare", "policy_number": "UHC456789123", "group_number": "GRP003"}');

-- Get provider and patient IDs for foreign key references
-- Note: In a real scenario, you'd use the actual UUIDs generated above
-- For this demo, we'll use variables to represent the relationships

-- Insert sample appointments
WITH provider_ids AS (
  SELECT id, first_name, last_name FROM providers
), patient_ids AS (
  SELECT id, first_name, last_name FROM patients
)
INSERT INTO appointments (patient_id, provider_id, appointment_date, duration_minutes, appointment_type, status, location, reason, instructions)
SELECT 
  p.id,
  pr.id,
  appointment_date,
  duration_minutes,
  appointment_type,
  status,
  location,
  reason,
  instructions
FROM patient_ids p, provider_ids pr,
(VALUES
  ('2024-12-15 09:00:00-06', 30, 'Annual Physical', 'scheduled', 'Building A, Suite 101', 'Annual wellness exam', 'Please fast for 12 hours before appointment for blood work'),
  ('2024-12-20 14:30:00-06', 45, 'Follow-up', 'scheduled', 'Building B, Suite 205', 'Diabetes management follow-up', 'Bring your glucose log and current medications'),
  ('2024-11-28 10:15:00-06', 30, 'Routine Visit', 'completed', 'Building A, Suite 102', 'Routine check-up', 'Continue current medications as prescribed'),
  ('2025-01-10 11:00:00-06', 60, 'Consultation', 'scheduled', 'Building C, Suite 301', 'Cardiac evaluation', 'Bring previous EKG results if available')
) AS appt_data(appointment_date, duration_minutes, appointment_type, status, location, reason, instructions)
WHERE 
  (p.first_name = 'John' AND pr.first_name = 'Sarah') OR
  (p.first_name = 'Sarah' AND pr.first_name = 'Michael') OR
  (p.first_name = 'Michael' AND pr.first_name = 'Emily') OR
  (p.first_name = 'John' AND pr.first_name = 'David');

-- Insert sample lab results
WITH patient_ids AS (
  SELECT id, first_name, last_name FROM patients
)
INSERT INTO lab_results (patient_id, test_name, test_code, category, result_value, result_unit, reference_range, status, collected_date, resulted_date, patient_explanation)
SELECT 
  p.id,
  test_name,
  test_code,
  category,
  result_value,
  result_unit,
  reference_range,
  status,
  collected_date,
  resulted_date,
  patient_explanation
FROM patient_ids p,
(VALUES
  ('Complete Blood Count', 'CBC', 'Hematology', 14.2, 'g/dL', '12.0-15.5', 'normal', '2024-11-20 08:00:00-06', '2024-11-20 14:30:00-06', 'Your hemoglobin level is normal, indicating healthy red blood cell count.'),
  ('Hemoglobin A1C', 'HbA1c', 'Chemistry', 7.2, '%', '<7.0', 'abnormal', '2024-11-20 08:00:00-06', '2024-11-20 16:00:00-06', 'Your A1C is slightly elevated. This measures your average blood sugar over the past 2-3 months. We should discuss adjusting your diabetes management plan.'),
  ('Total Cholesterol', 'CHOL', 'Chemistry', 195.0, 'mg/dL', '<200', 'normal', '2024-11-15 07:30:00-06', '2024-11-15 12:00:00-06', 'Your cholesterol level is within the healthy range. Continue your current diet and exercise routine.'),
  ('LDL Cholesterol', 'LDL', 'Chemistry', 125.0, 'mg/dL', '<100', 'abnormal', '2024-11-15 07:30:00-06', '2024-11-15 12:00:00-06', 'Your LDL (bad cholesterol) is slightly elevated. Consider dietary changes and discuss with your provider about medication options.'),
  ('Thyroid Stimulating Hormone', 'TSH', 'Chemistry', 2.1, 'mIU/L', '0.4-4.0', 'normal', '2024-11-10 09:00:00-06', '2024-11-10 15:30:00-06', 'Your thyroid function is normal. Continue your current thyroid medication as prescribed.')
) AS lab_data(test_name, test_code, category, result_value, result_unit, reference_range, status, collected_date, resulted_date, patient_explanation)
WHERE p.first_name IN ('John', 'Sarah', 'Michael');

-- Insert sample medications
WITH patient_ids AS (
  SELECT id, first_name, last_name FROM patients
), provider_ids AS (
  SELECT id, first_name, last_name FROM providers
)
INSERT INTO medications (patient_id, prescriber_id, medication_name, generic_name, dosage, strength, form, frequency, route, instructions, indication, quantity, refills_remaining, prescribed_date, start_date, status)
SELECT 
  p.id,
  pr.id,
  medication_name,
  generic_name,
  dosage,
  strength,
  form,
  frequency,
  route,
  instructions,
  indication,
  quantity,
  refills_remaining,
  prescribed_date,
  start_date,
  status
FROM patient_ids p, provider_ids pr,
(VALUES
  ('Metformin', 'Metformin HCl', '500mg', '500mg', 'tablet', 'twice daily', 'oral', 'Take with meals to reduce stomach upset', 'Type 2 Diabetes', 60, 5, '2024-01-15', '2024-01-15', 'active'),
  ('Lisinopril', 'Lisinopril', '10mg', '10mg', 'tablet', 'once daily', 'oral', 'Take at the same time each day, preferably in the morning', 'High Blood Pressure', 30, 3, '2024-02-01', '2024-02-01', 'active'),
  ('Atorvastatin', 'Atorvastatin Calcium', '20mg', '20mg', 'tablet', 'once daily at bedtime', 'oral', 'Take in the evening with or without food', 'High Cholesterol', 30, 2, '2024-03-10', '2024-03-10', 'active'),
  ('Levothyroxine', 'Levothyroxine Sodium', '75mcg', '75mcg', 'tablet', 'once daily', 'oral', 'Take on empty stomach, 30-60 minutes before breakfast', 'Hypothyroidism', 30, 4, '2024-01-20', '2024-01-20', 'active'),
  ('Omeprazole', 'Omeprazole', '20mg', '20mg', 'capsule', 'once daily', 'oral', 'Take before eating, preferably in the morning', 'GERD', 30, 1, '2024-04-05', '2024-04-05', 'active')
) AS med_data(medication_name, generic_name, dosage, strength, form, frequency, route, instructions, indication, quantity, refills_remaining, prescribed_date, start_date, status)
WHERE 
  (p.first_name = 'John' AND pr.first_name = 'Sarah') OR
  (p.first_name = 'Sarah' AND pr.first_name = 'Michael') OR
  (p.first_name = 'Michael' AND pr.first_name = 'Emily');

-- Insert sample messages
WITH patient_ids AS (
  SELECT id, first_name, last_name FROM patients
), provider_ids AS (
  SELECT id, first_name, last_name FROM providers
)
INSERT INTO messages (patient_id, provider_id, thread_id, subject, message_body, sender_type, message_type, priority, is_read, created_at)
SELECT 
  p.id,
  pr.id,
  uuid_generate_v4(),
  subject,
  message_body,
  sender_type,
  message_type,
  priority,
  is_read,
  created_at
FROM patient_ids p, provider_ids pr,
(VALUES
  ('Question about medication side effects', 'Hi Dr. Johnson, I''ve been experiencing some mild nausea since starting the new medication. Is this normal? Should I continue taking it?', 'patient', 'prescription', 'normal', false, '2024-11-25 10:30:00-06'),
  ('Lab results follow-up', 'Thank you for your message. Mild nausea is a common side effect that usually improves after a few days. Please continue the medication and let me know if it doesn''t improve by next week.', 'provider', 'prescription', 'normal', true, '2024-11-25 14:15:00-06'),
  ('Appointment scheduling request', 'I would like to schedule my annual physical exam. I''m available most mornings next month. Please let me know what dates work best.', 'patient', 'appointment', 'normal', false, '2024-11-22 16:45:00-06'),
  ('Prescription refill needed', 'Hi, I need a refill for my blood pressure medication. I have about 5 days left. Can you please send it to my usual pharmacy?', 'patient', 'prescription', 'normal', false, '2024-11-28 09:20:00-06'),
  ('Test results available', 'Your recent lab results are now available in your patient portal. Overall, most values look good. I''d like to discuss your cholesterol levels at your next appointment.', 'provider', 'lab_result', 'normal', false, '2024-11-20 17:00:00-06')
) AS msg_data(subject, message_body, sender_type, message_type, priority, is_read, created_at)
WHERE 
  (p.first_name = 'John' AND pr.first_name = 'Sarah') OR
  (p.first_name = 'Sarah' AND pr.first_name = 'Michael') OR
  (p.first_name = 'Michael' AND pr.first_name = 'Emily');

-- Insert sample health alerts
WITH patient_ids AS (
  SELECT id, first_name, last_name FROM patients
)
INSERT INTO health_alerts (patient_id, alert_type, severity, title, message, action_required, action_url, is_read, created_at)
SELECT 
  p.id,
  alert_type,
  severity,
  title,
  message,
  action_required,
  action_url,
  is_read,
  created_at
FROM patient_ids p,
(VALUES
  ('medication', 'warning', 'Prescription Refill Due Soon', 'Your Lisinopril prescription will run out in 3 days. Please request a refill or contact your provider.', true, '/medications', false, '2024-11-27 08:00:00-06'),
  ('appointment', 'info', 'Upcoming Appointment Reminder', 'You have an appointment with Dr. Johnson tomorrow at 9:00 AM. Please arrive 15 minutes early.', false, '/appointments', false, '2024-12-14 18:00:00-06'),
  ('lab_result', 'warning', 'New Lab Results Available', 'Your recent lab results show some values that need attention. Please review and schedule a follow-up if needed.', true, '/lab-results', false, '2024-11-20 17:30:00-06'),
  ('preventive', 'info', 'Annual Physical Due', 'It''s time for your annual physical exam. Please schedule an appointment with your primary care provider.', true, '/appointments', true, '2024-11-01 09:00:00-06'),
  ('medication', 'critical', 'Drug Interaction Alert', 'A potential interaction has been identified between your medications. Please contact your provider immediately.', true, '/messages', false, '2024-11-26 14:30:00-06')
) AS alert_data(alert_type, severity, title, message, action_required, action_url, is_read, created_at)
WHERE p.first_name IN ('John', 'Sarah', 'Michael');

-- Update statistics
ANALYZE patients;
ANALYZE providers;
ANALYZE appointments;
ANALYZE lab_results;
ANALYZE medications;
ANALYZE messages;
ANALYZE health_alerts;
