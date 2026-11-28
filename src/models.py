import uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, Float, Integer, String
from src.database import Base


class VenuesAndZonesModel(Base):
    __tablename__ = "venues_and_zones"
    zone_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    zone_name = Column(String)
    facility_type = Column(String)
    max_capacity = Column(Integer)
    pool_bulkhead_mode = Column(String)
    depth_meters = Column(Float)
    is_active = Column(Boolean, default=True)
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class ArenaEventsModel(Base):
    __tablename__ = "arena_events"
    event_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    zone_id = Column(String)
    title = Column(String)
    event_category = Column(String)
    start_time = Column(String)
    end_time = Column(String)
    total_seats = Column(Integer)
    status = Column(String, default="ACTIVE")
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class TicketBookingsModel(Base):
    __tablename__ = "ticket_bookings"
    booking_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    event_id = Column(String)
    customer_email = Column(String)
    seat_section = Column(String)
    seat_row = Column(String)
    seat_number = Column(String)
    price_aed = Column(Float)
    lock_expires_at = Column(String)
    payment_ref = Column(String)
    qr_pass_hash = Column(String)
    booking_status = Column(String, default="LOCKED")
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class MembershipsModel(Base):
    __tablename__ = "memberships"
    member_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    full_name = Column(String)
    emirates_id_hash = Column(String)
    tier = Column(String)
    nfc_wristband_uid = Column(String)
    valid_from = Column(String)
    valid_until = Column(String)
    auto_renew = Column(Boolean, default=True)
    status = Column(String, default="ACTIVE")
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class TrainingInstitutesModel(Base):
    __tablename__ = "training_institutes"
    institute_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    academy_name = Column(String)
    trade_license_no = Column(String)
    federation_affiliation = Column(String)
    primary_contact_email = Column(String)
    credit_limit_aed = Column(Float)
    discount_tier = Column(String)
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class AcademyLaneAllocationsModel(Base):
    __tablename__ = "academy_lane_allocations"
    allocation_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    institute_id = Column(String)
    zone_id = Column(String)
    coach_name = Column(String)
    lane_or_court_numbers = Column(String)
    session_date = Column(String)
    start_slot = Column(String)
    end_slot = Column(String)
    pool_config_mode = Column(String)
    trainees_count = Column(Integer)
    invoice_status = Column(String, default="PENDING_MONTHLY_CYCLE")
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class TurnstileAccessLogsModel(Base):
    __tablename__ = "turnstile_access_logs"
    scan_id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    zone_id = Column(String)
    member_id = Column(String)
    booking_id = Column(String)
    gate_number = Column(String)
    scan_result = Column(String)
    scanned_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    created_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    updated_at = Column(String, default=lambda: datetime.now(timezone.utc).isoformat())
    deleted_at = Column(String)

    def to_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

