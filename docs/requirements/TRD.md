# Technical Requirements Document (TRD) — Hamdan Sports Complex Unified Arena & Academy Platform

## 1. Executive Summary & Architectural Scope
- **Project**: `Hamdan Sports Complex Unified Arena & Academy Platform` (`proj-5148f57a`)
- **Target Cloud & Residency**: `azure` • `UAE / ME-Central (me-central-1)`
- **Approved Technology Stack**: `Next.js 15 (TypeScript), Tailwind CSS, Python 3.12, FastAPI, SQLAlchemy 2.0 + Alembic, OAuth 2.0 PKCE / OIDC (Entra ID / Cognito), GitHub Actions + OpenAPI 3.1 Linter + Terraform`
- **Regulatory & Security Compliance**: `SOC 2 Type II, ISO 27001`
- **Canonical Data Entities (ERD)**: `venues_and_zones`, `arena_events`, `ticket_bookings`, `memberships`, `training_institutes`, `academy_lane_allocations`, `turnstile_access_logs`

---

## 2. Performance, Scalability & Latency Thresholds (NFR-PERF)
| Metric ID | Technical Requirement | Target Threshold | Verification & Load-Testing Procedure |
| :--- | :--- | :--- | :--- |
| **TRD-PERF-01** | **Peak Championship Ticket-Drop Throughput** | **>= 25,000 RPS** sustained at edge (`Azure Front Door + APIM`) | k6 / Locust distributed load test simulating 15,000-seat arena drop with Virtual Waiting Room token queue enabled. |
| **TRD-PERF-02** | **Smart Turnstile & Poolside Kiosk Validation (`POST /api/v1/turnstiles/validate-scan`)** | **p99 <= 150 ms** (p50 <= 25 ms) | Redis Enterprise local cache hit benchmark + sub-150ms assertion in `tests/test_contract_smoke.py`. |
| **TRD-PERF-03** | **Atomic 8-Minute Distributed Seat Lock (`POST /api/v1/seat-locks`)** | **p99 <= 45 ms** • **0% double-booking rate** | Concurrent race-condition test verifying atomic Redis Lua lock + `HTTP 409 Conflict` (`SEAT_ALREADY_LOCKED`) on contending requests. |
| **TRD-PERF-04** | **Core CRUD & Academy Bulkhead Scheduling APIs** | **p95 <= 120 ms**, **p99 <= 250 ms** | Connection-pooled SQLAlchemy 2.0 + PgBouncer query execution against indexed PostgreSQL 16 tables. |

---

## 3. API Security, Identity & RBAC Authorization Matrix (NFR-SEC)
1. **Authentication & Identity Federation**:
   - **B2C Spectators & Members**: **UAE PASS (OIDC / OAuth 2.0 PKCE)** federated with **Microsoft Entra External ID** (`RS256` JWT Bearer tokens, `aud`, `iss`, `exp`, `nbf` validated on every request).
   - **B2B Sports Academies & National Federations**: OAuth 2.0 Client Credentials + delegated JWT scopes (`academy:schedule`, `invoice:read`).
   - **Smart Turnstile IoT Controllers**: X.509 mutual TLS (mTLS) device certificates registered in **Azure IoT Hub** + scoped service principal Bearer tokens (`turnstile:verify`).
2. **Role-Based Access Control (RBAC) Matrix**:
   - `spectator_customer`: `POST /api/v1/seat-locks`, `POST /api/v1/ticket-bookings/confirm-checkout`, `GET /api/v1/arena-events`.
   - `member_athlete`: `GET /api/v1/memberships`, `POST /api/v1/notifications/wallet-pass`.
   - `b2b_academy_coordinator`: `POST /api/v1/academy-lane-allocations`, `GET /api/v1/academy-lane-allocations`.
   - `turnstile_kiosk_controller`: `POST /api/v1/turnstiles/validate-scan`.
   - `arena_ops_admin`: Full CRUD across `venues_and_zones`, `arena_events`, `training_institutes`, and bulkhead mode transitions.
3. **Transport & Edge Protection**:
   - Enforce **TLS 1.3** across all external ingress (`Azure Front Door Premium`) and **mTLS** across internal service-to-service traffic.
   - Rate-limiting enforced at **Azure API Management**: `100 req/min` per IP on mutation routes (`HTTP 429 Too Many Requests` with `Retry-After` header).

---

## 4. Cryptography, PII Hashing & PCI-DSS v4.0 Standards (NFR-CRYPTO)
- **Encryption at Rest**: All PostgreSQL 16 Flexible Server storage volumes, automated backups, Redis Enterprise persistence files, and Blob Storage containers encrypted with **AES-256 Customer-Managed Keys (CMK)** stored in **Azure Key Vault Premium HSM (FIPS 140-2 Level 3)**.
- **PII Data Protection (UAE Federal Law No. 45 & GDPR)**:
  - Raw Emirates ID numbers and biometric templates MUST NEVER be stored in plaintext; transform immediately via salted **SHA-256 (`emirates_id_hash`)** before persistence.
- **PCI-DSS v4.0 Payment Tokenization**:
  - Raw Primary Account Numbers (PAN) and CVV codes never touch application memory; `POST /api/v1/ticket-bookings/confirm-checkout` accepts a gateway `payment_instrument_token` and exchanges it for an HSM-signed `payment_ref` (`pay_tok_azkv_*`).

---

## 5. Data Validation, Idempotency & Error-Handling Standards (NFR-DATA)
1. **Idempotency Enforcement**:
   - All state-mutating `POST` endpoints (`seat-locks`, `confirm-checkout`, `academy-lane-allocations`, entity creation) accept an `Idempotency-Key` (UUIDv4) header cached for 24 hours to prevent duplicate charges or duplicate bookings on network retries.
2. **Domain Validation & Conflict Rules**:
   - **Seat Double-Booking Prevention**: Concurrent seat-lock or confirmed booking requests for the same `(event_id, seat_section, seat_row, seat_number)` MUST return `HTTP 409 Conflict` (`SEAT_ALREADY_LOCKED` or `SEAT_ALREADY_SOLD`).
   - **Movable Pool Bulkhead & Championship Event Exclusion**: `POST /api/v1/academy-lane-allocations` validates that `(zone_id, session_date, start_slot, end_slot)` neither conflicts with an active `arena_events` window (`ARENA_EVENT_COLLISION`) nor mismatches the active `pool_config_mode` (`50m_10_lanes_championship` vs `25m_20_lanes_short_course` -> `HTTP 409 Conflict`).
   - **Turnstile Anti-Passback**: Duplicate NFC/QR scans within a 5-second anti-passback window or expired credentials return `HTTP 403 Forbidden` (`DENIED_ANTI_PASSBACK` / `DENIED_EXPIRED_CREDENTIAL`).
3. **Standardized Error Envelope (`ProblemDetails`)**:
   - All `400`, `401`, `403`, `404`, `409`, `422`, `429`, and `503` responses return a structured JSON envelope containing `code`, `message`, and `trace_id` (plus `X-Correlation-ID` response header).

---

## 6. Observability, Structured Logging & Alerting Specifications (NFR-OBS)
- **Distributed Tracing**: Every HTTP request extracts or generates an `X-Correlation-ID` (`trc-*`) header, attaches `X-Response-Time-Ms`, and emits a single-line structured JSON log event (`timestamp`, `service`, `trace_id`, `method`, `path`, `status_code`, `latency_ms`) ingested into **Azure Monitor Log Analytics & Application Insights**.
- **Alerting Thresholds**:
  - **P1 Critical Alert**: Turnstile validation p99 > 150 ms for 3 consecutive minutes OR HTTP 5xx error rate > 0.5%.
  - **P2 Warning Alert**: Redis Enterprise memory utilization > 75% OR PostgreSQL replication lag > 10 seconds.

---

## 7. Reliability, Disaster Recovery, Backup & Restore Procedures (NFR-DR)
- **Availability Target**: **99.99% SLA** across multi-zone deployments (`Zones 1, 2, 3` in `uaenorth`).
- **RTO / RPO**: **RTO <= 15m** • **RPO <= 5m** via synchronous zone-redundant HA in `uaenorth` and asynchronous geo-replication to `uaecentral`.
- **Backup & Point-in-Time Restore (PITR)**:
  - Continuous WAL archiving to geo-redundant Azure Blob Storage with **35-day PITR retention**.
  - Automated weekly restore drill into an isolated staging VNet verifying schema integrity (`001_initial_schema.sql`) and checksum parity.

---

## 8. Requirements-to-Implementation Traceability & Verification Matrix
| Requirement ID | Business / Technical Capability | API Endpoint(s) | Database Table(s) | Automated Verification Test |
| :--- | :--- | :--- | :--- | :--- |
| **REQ-TICKET-01** | Atomic 8-Min Redis Seat Lock & Concurrency | `POST /api/v1/seat-locks` | `ticket_bookings`, `arena_events` | `test_atomic_seat_lock_and_409_double_booking_prevention` |
| **REQ-PAY-02** | PCI-DSS 4.0 HSM Tokenized Checkout & QR Pass | `POST /api/v1/ticket-bookings/confirm-checkout` | `ticket_bookings` | `test_atomic_seat_lock_and_409_double_booking_prevention` |
| **REQ-ACCESS-03** | Sub-150ms Smart Turnstile NFC/QR Scan | `POST /api/v1/turnstiles/validate-scan` | `turnstile_access_logs`, `memberships` | `test_sub_150ms_turnstile_scan_and_expired_pass_rejection` |
| **REQ-ACAD-04** | 50m/25m Pool Bulkhead & Event Conflict Solver | `POST /api/v1/academy-lane-allocations` | `academy_lane_allocations`, `venues_and_zones` | `test_academy_bulkhead_conflict_detection` |
| **REQ-SEC-05** | UAE PASS / Entra JWT Auth & Trace Correlation | All `/api/v1/*` routes | All 7 tables (`created_at`, `updated_at`) | `test_jwt_authentication_rejection_on_invalid_token` |
