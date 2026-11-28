from sqlalchemy import Column, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class VenuesAndZonesModel(Base):
    __tablename__ = "venues_and_zones"
    zone_id = Column(String, primary_key=True)
    zone_name = Column(String)
    facility_type = Column(String)
    max_capacity = Column(String)
    pool_bulkhead_mode = Column(String)
    depth_meters = Column(String)
    is_active = Column(String)

class ArenaEventsModel(Base):
    __tablename__ = "arena_events"
    event_id = Column(String, primary_key=True)
    zone_id = Column(String)
    title = Column(String)
    event_category = Column(String)
    start_time = Column(String)
    end_time = Column(String)
    total_seats = Column(String)
    status = Column(String)

class TicketBookingsModel(Base):
    __tablename__ = "ticket_bookings"
    booking_id = Column(String, primary_key=True)
    event_id = Column(String)
    customer_email = Column(String)
    seat_section = Column(String)
    seat_row = Column(String)
    seat_number = Column(String)
    price_aed = Column(String)
    lock_expires_at = Column(String)
    payment_ref = Column(String)
    qr_pass_hash = Column(String)
    booking_status = Column(String)

class MembershipsModel(Base):
    __tablename__ = "memberships"
    member_id = Column(String, primary_key=True)
    full_name = Column(String)
    emirates_id_hash = Column(String)
    tier = Column(String)
    nfc_wristband_uid = Column(String)
    valid_from = Column(String)
    valid_until = Column(String)
    auto_renew = Column(String)
    status = Column(String)

class TrainingInstitutesModel(Base):
    __tablename__ = "training_institutes"
    institute_id = Column(String, primary_key=True)
    academy_name = Column(String)
    trade_license_no = Column(String)
    federation_affiliation = Column(String)
    primary_contact_email = Column(String)
    credit_limit_aed = Column(String)
    discount_tier = Column(String)

class AcademyLaneAllocationsModel(Base):
    __tablename__ = "academy_lane_allocations"
    allocation_id = Column(String, primary_key=True)
    institute_id = Column(String)
    zone_id = Column(String)
    coach_name = Column(String)
    lane_or_court_numbers = Column(String)
    session_date = Column(String)
    start_slot = Column(String)
    end_slot = Column(String)
    pool_config_mode = Column(String)
    trainees_count = Column(String)
    invoice_status = Column(String)

