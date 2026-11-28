-- ArchiForge Canonical Database Schema Migration (PostgreSQL 16)
-- Project: Hamdan Sports Complex Unified Arena & Academy Platform
-- Generated At: 2026-11-28T09:29:51.637811Z
-- Security Baseline: AES-256 KMS at Rest, SHA-256 PII Hashing (pgcrypto), Audit & Soft-Delete Columns

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS venues_and_zones (
    zone_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_name VARCHAR(255) UNIQUE NOT NULL,
    facility_type VARCHAR(255) NOT NULL,
    max_capacity INTEGER NOT NULL CHECK (max_capacity > 0),
    pool_bulkhead_mode VARCHAR(255) NOT NULL,
    depth_meters NUMERIC(12,2) NOT NULL CHECK (depth_meters >= 0),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_venues_and_zones_created_at ON venues_and_zones (created_at);

CREATE TABLE IF NOT EXISTS arena_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID NOT NULL REFERENCES venues_and_zones(zone_id) ON DELETE RESTRICT,
    title VARCHAR(255) NOT NULL,
    event_category VARCHAR(255) NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    total_seats INTEGER NOT NULL CHECK (total_seats > 0),
    status VARCHAR(255) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_event_window CHECK (end_time > start_time)
);
CREATE INDEX IF NOT EXISTS idx_arena_events_created_at ON arena_events (created_at);
CREATE INDEX IF NOT EXISTS idx_arena_events_zone_id ON arena_events (zone_id);

CREATE TABLE IF NOT EXISTS ticket_bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES arena_events(event_id) ON DELETE RESTRICT,
    customer_email VARCHAR(255) NOT NULL,
    seat_section VARCHAR(255) NOT NULL,
    seat_row VARCHAR(255) NOT NULL,
    seat_number VARCHAR(255) NOT NULL,
    price_aed NUMERIC(12,2) NOT NULL CHECK (price_aed >= 0),
    lock_expires_at TIMESTAMPTZ NOT NULL,
    payment_ref VARCHAR(255) UNIQUE,
    qr_pass_hash VARCHAR(255) UNIQUE NOT NULL,
    booking_status VARCHAR(255) DEFAULT 'LOCKED' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_event_seat UNIQUE (event_id, seat_section, seat_row, seat_number)
);
CREATE INDEX IF NOT EXISTS idx_ticket_bookings_created_at ON ticket_bookings (created_at);
CREATE INDEX IF NOT EXISTS idx_ticket_bookings_event_id ON ticket_bookings (event_id);

CREATE TABLE IF NOT EXISTS memberships (
    member_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    emirates_id_hash VARCHAR(255) UNIQUE NOT NULL,
    tier VARCHAR(255) NOT NULL,
    nfc_wristband_uid VARCHAR(255) UNIQUE NOT NULL,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    auto_renew BOOLEAN DEFAULT TRUE NOT NULL,
    status VARCHAR(255) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_memberships_created_at ON memberships (created_at);

CREATE TABLE IF NOT EXISTS training_institutes (
    institute_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academy_name VARCHAR(255) UNIQUE NOT NULL,
    trade_license_no VARCHAR(255) UNIQUE NOT NULL,
    federation_affiliation VARCHAR(255),
    primary_contact_email VARCHAR(255) NOT NULL,
    credit_limit_aed NUMERIC(12,2) NOT NULL CHECK (credit_limit_aed >= 0),
    discount_tier VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_training_institutes_created_at ON training_institutes (created_at);

CREATE TABLE IF NOT EXISTS academy_lane_allocations (
    allocation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institute_id UUID NOT NULL REFERENCES training_institutes(institute_id) ON DELETE RESTRICT,
    zone_id UUID NOT NULL REFERENCES venues_and_zones(zone_id) ON DELETE RESTRICT,
    coach_name VARCHAR(255) NOT NULL,
    lane_or_court_numbers VARCHAR(255) NOT NULL,
    session_date DATE NOT NULL,
    start_slot TIME NOT NULL,
    end_slot TIME NOT NULL,
    pool_config_mode VARCHAR(255) NOT NULL,
    trainees_count INTEGER NOT NULL CHECK (trainees_count > 0),
    invoice_status VARCHAR(255) DEFAULT 'PENDING_MONTHLY_CYCLE' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_slot_window CHECK (end_slot > start_slot)
);
CREATE INDEX IF NOT EXISTS idx_academy_lane_allocations_created_at ON academy_lane_allocations (created_at);
CREATE INDEX IF NOT EXISTS idx_academy_lane_allocations_institute_id ON academy_lane_allocations (institute_id);
CREATE INDEX IF NOT EXISTS idx_academy_lane_allocations_zone_id ON academy_lane_allocations (zone_id);

CREATE TABLE IF NOT EXISTS turnstile_access_logs (
    scan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID NOT NULL REFERENCES venues_and_zones(zone_id) ON DELETE RESTRICT,
    member_id UUID REFERENCES memberships(member_id) ON DELETE SET NULL,
    booking_id UUID REFERENCES ticket_bookings(booking_id) ON DELETE SET NULL,
    gate_number VARCHAR(255) NOT NULL,
    scan_result VARCHAR(255) NOT NULL,
    scanned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_turnstile_access_logs_created_at ON turnstile_access_logs (created_at);
CREATE INDEX IF NOT EXISTS idx_turnstile_access_logs_zone_id ON turnstile_access_logs (zone_id);
CREATE INDEX IF NOT EXISTS idx_turnstile_access_logs_member_id ON turnstile_access_logs (member_id);
CREATE INDEX IF NOT EXISTS idx_turnstile_access_logs_booking_id ON turnstile_access_logs (booking_id);
