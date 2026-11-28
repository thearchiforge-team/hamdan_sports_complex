-- ArchiForge Canonical Database Schema Migration
-- Project: Shared Team Blueprints
-- Generated At: 2026-11-28T08:44:21.964181Z

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS venues_and_zones (
    zone_id VARCHAR(255) PRIMARY KEY,
    zone_name VARCHAR(255),
    facility_type VARCHAR(255),
    max_capacity VARCHAR(255),
    pool_bulkhead_mode VARCHAR(255),
    depth_meters VARCHAR(255),
    is_active VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_venues_and_zones_created_at ON venues_and_zones (created_at);

CREATE TABLE IF NOT EXISTS arena_events (
    event_id VARCHAR(255) PRIMARY KEY,
    zone_id VARCHAR(255),
    title VARCHAR(255),
    event_category VARCHAR(255),
    start_time VARCHAR(255),
    end_time VARCHAR(255),
    total_seats VARCHAR(255),
    status VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_arena_events_created_at ON arena_events (created_at);

CREATE TABLE IF NOT EXISTS ticket_bookings (
    booking_id VARCHAR(255) PRIMARY KEY,
    event_id VARCHAR(255),
    customer_email VARCHAR(255),
    seat_section VARCHAR(255),
    seat_row VARCHAR(255),
    seat_number VARCHAR(255),
    price_aed VARCHAR(255),
    lock_expires_at VARCHAR(255),
    payment_ref VARCHAR(255),
    qr_pass_hash VARCHAR(255),
    booking_status VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_ticket_bookings_created_at ON ticket_bookings (created_at);

CREATE TABLE IF NOT EXISTS memberships (
    member_id VARCHAR(255) PRIMARY KEY,
    full_name VARCHAR(255),
    emirates_id_hash VARCHAR(255),
    tier VARCHAR(255),
    nfc_wristband_uid VARCHAR(255),
    valid_from VARCHAR(255),
    valid_until VARCHAR(255),
    auto_renew VARCHAR(255),
    status VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_memberships_created_at ON memberships (created_at);

CREATE TABLE IF NOT EXISTS training_institutes (
    institute_id VARCHAR(255) PRIMARY KEY,
    academy_name VARCHAR(255),
    trade_license_no VARCHAR(255),
    federation_affiliation VARCHAR(255),
    primary_contact_email VARCHAR(255),
    credit_limit_aed VARCHAR(255),
    discount_tier VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_training_institutes_created_at ON training_institutes (created_at);

CREATE TABLE IF NOT EXISTS academy_lane_allocations (
    allocation_id VARCHAR(255) PRIMARY KEY,
    institute_id VARCHAR(255),
    zone_id VARCHAR(255),
    coach_name VARCHAR(255),
    lane_or_court_numbers VARCHAR(255),
    session_date VARCHAR(255),
    start_slot VARCHAR(255),
    end_slot VARCHAR(255),
    pool_config_mode VARCHAR(255),
    trainees_count VARCHAR(255),
    invoice_status VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_academy_lane_allocations_created_at ON academy_lane_allocations (created_at);

CREATE TABLE IF NOT EXISTS turnstile_access_logs (
    scan_id VARCHAR(255) PRIMARY KEY,
    zone_id VARCHAR(255),
    member_id VARCHAR(255),
    booking_id VARCHAR(255),
    gate_number VARCHAR(255),
    scan_result VARCHAR(255),
    scanned_at VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_turnstile_access_logs_created_at ON turnstile_access_logs (created_at);
