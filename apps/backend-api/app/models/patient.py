"""
Patient data models for the Patient Portal API.

Defines SQLAlchemy models for patient-related data including:
- Patient profiles
- Appointments
- Lab results
- Medications
- Messages
- Providers
"""

from sqlalchemy import Column, String, DateTime, Date, Text, Integer, Decimal, Boolean, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base


class Patient(Base):
    """Patient profile information"""
    __tablename__ = "patients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20))
    address = Column(JSON)  # Flexible address storage
    emergency_contact = Column(JSON)  # Emergency contact information
    medical_record_number = Column(String(50), unique=True, nullable=False, index=True)
    insurance_info = Column(JSON)  # Insurance information
    preferred_language = Column(String(10), default="en")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    appointments = relationship("Appointment", back_populates="patient")
    lab_results = relationship("LabResult", back_populates="patient")
    medications = relationship("Medication", back_populates="patient")
    messages = relationship("Message", back_populates="patient")

    def __repr__(self):
        return f"<Patient(id={self.id}, name={self.first_name} {self.last_name})>"


class Provider(Base):
    """Healthcare provider information"""
    __tablename__ = "providers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    title = Column(String(50))  # Dr., NP, PA, etc.
    specialty = Column(String(100))
    department = Column(String(100))
    email = Column(String(255), unique=True, nullable=False)
    phone = Column(String(20))
    office_location = Column(String(200))
    bio = Column(Text)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    appointments = relationship("Appointment", back_populates="provider")
    medications = relationship("Medication", back_populates="prescriber")
    messages = relationship("Message", back_populates="provider")

    def __repr__(self):
        return f"<Provider(id={self.id}, name={self.title} {self.first_name} {self.last_name})>"


class Appointment(Base):
    """Patient appointments"""
    __tablename__ = "appointments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=False)
    provider_id = Column(UUID(as_uuid=True), ForeignKey("providers.id"), nullable=False)
    appointment_date = Column(DateTime(timezone=True), nullable=False)
    duration_minutes = Column(Integer, default=30)
    appointment_type = Column(String(50))  # routine, follow-up, urgent, etc.
    status = Column(String(20), default="scheduled")  # scheduled, confirmed, completed, cancelled, no-show
    location = Column(String(200))
    reason = Column(Text)
    notes = Column(Text)
    instructions = Column(Text)  # Pre/post appointment instructions
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    patient = relationship("Patient", back_populates="appointments")
    provider = relationship("Provider", back_populates="appointments")

    def __repr__(self):
        return f"<Appointment(id={self.id}, date={self.appointment_date}, status={self.status})>"


class LabResult(Base):
    """Laboratory test results"""
    __tablename__ = "lab_results"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=False)
    test_name = Column(String(200), nullable=False)
    test_code = Column(String(50))  # LOINC or other standard codes
    category = Column(String(100))  # Chemistry, Hematology, Microbiology, etc.
    result_value = Column(Decimal(10, 3))
    result_text = Column(Text)  # For non-numeric results
    result_unit = Column(String(20))
    reference_range = Column(String(100))
    status = Column(String(20))  # normal, abnormal, critical, pending
    flags = Column(String(10))  # H (High), L (Low), etc.
    collected_date = Column(DateTime(timezone=True))
    resulted_date = Column(DateTime(timezone=True))
    provider_notes = Column(Text)
    patient_explanation = Column(Text)  # Simplified explanation for patients
    is_critical = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    patient = relationship("Patient", back_populates="lab_results")

    def __repr__(self):
        return f"<LabResult(id={self.id}, test={self.test_name}, status={self.status})>"


class Medication(Base):
    """Patient medications and prescriptions"""
    __tablename__ = "medications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=False)
    prescriber_id = Column(UUID(as_uuid=True), ForeignKey("providers.id"), nullable=False)
    medication_name = Column(String(200), nullable=False)
    generic_name = Column(String(200))
    dosage = Column(String(100))  # e.g., "500mg", "10mg/ml"
    strength = Column(String(50))
    form = Column(String(50))  # tablet, capsule, liquid, etc.
    frequency = Column(String(100))  # e.g., "twice daily", "as needed"
    route = Column(String(50))  # oral, topical, injection, etc.
    instructions = Column(Text)
    indication = Column(String(200))  # What it's prescribed for
    quantity = Column(Integer)  # Number of pills/doses prescribed
    refills_remaining = Column(Integer, default=0)
    prescribed_date = Column(Date, nullable=False)
    start_date = Column(Date)
    end_date = Column(Date)
    status = Column(String(20), default="active")  # active, discontinued, completed
    side_effects = Column(JSON)  # Common side effects
    interactions = Column(JSON)  # Drug interactions
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    patient = relationship("Patient", back_populates="medications")
    prescriber = relationship("Provider", back_populates="medications")

    def __repr__(self):
        return f"<Medication(id={self.id}, name={self.medication_name}, status={self.status})>"


class Message(Base):
    """Secure messages between patients and providers"""
    __tablename__ = "messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=False)
    provider_id = Column(UUID(as_uuid=True), ForeignKey("providers.id"), nullable=False)
    thread_id = Column(UUID(as_uuid=True))  # For message threading
    subject = Column(String(200), nullable=False)
    message_body = Column(Text, nullable=False)
    sender_type = Column(String(20), nullable=False)  # patient or provider
    message_type = Column(String(50), default="general")  # general, appointment, prescription, etc.
    priority = Column(String(20), default="normal")  # low, normal, high, urgent
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime(timezone=True))
    attachments = Column(JSON)  # File attachment metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    patient = relationship("Patient", back_populates="messages")
    provider = relationship("Provider", back_populates="messages")

    def __repr__(self):
        return f"<Message(id={self.id}, subject={self.subject}, sender={self.sender_type})>"


class HealthAlert(Base):
    """Health alerts and notifications for patients"""
    __tablename__ = "health_alerts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), nullable=False)
    alert_type = Column(String(50), nullable=False)  # medication, appointment, lab_result, etc.
    severity = Column(String(20), default="info")  # info, warning, critical
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    action_required = Column(Boolean, default=False)
    action_url = Column(String(500))  # URL for action if required
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime(timezone=True))
    expires_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def __repr__(self):
        return f"<HealthAlert(id={self.id}, type={self.alert_type}, severity={self.severity})>"
