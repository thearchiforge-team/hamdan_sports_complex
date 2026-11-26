-- ArchiForge Canonical Database Schema Migration
-- Project: Shared Team Blueprints
-- Generated At: 2026-11-26T14:41:14.449423Z

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS service_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_ref VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL,
    metadata_json JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_service_records_created_at ON service_records (created_at);

CREATE TABLE IF NOT EXISTS audit_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    record_id UUID NOT NULL,
    actor_id VARCHAR(128) NOT NULL,
    action_type VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_audit_events_created_at ON audit_events (created_at);
