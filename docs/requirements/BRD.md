# Business Requirements Document (BRD) — Hamdan Sports Complex Unified Arena & Academy Platform

## 1. Executive Summary & Strategic Business Intent
**Hamdan Sports Complex Unified Arena & Academy Platform** establishes a unified, cloud-native digital venue, high-concurrency event ticketing, member access control, and B2B training academy scheduling platform deployed on **azure**.

Design an enterprise Microsoft Azure cloud-native platform in Azure UAE North (Dubai) for Hamdan Sports Complex supporting three core business streams:
     1. Audience Event Ticketing & Smart Turnstiles: High-concurrency ticket sales for international championships (FINA swimming, badminton, basketball, concerts) up to 15,000 seats, interactive 3D bowl seat-map reservation with 8-minute Azure Cache for Redis Enterprise distributed seat-lock TTL, dynamic tiered pricing (VIP Hospitality, Royal Box, Lower/Upper Bowl), Apple/Google Wallet NFC/QR passes, and sub-150ms smart turnstile validation via Azure Front Door Premium, Azure Application Gateway WAF v2, Azure API Management (APIM), and Azure IoT Hub.
     2. Individual & Family Membership Access: Tiered annual/monthly memberships (Gold Aquatics, Fitness & Gym, Junior Athlete), Microsoft Entra External ID (OIDC + UAE PASS integration), biometric/NFC smart-wristband turnstile access, locker rental, and automated recurring billing.
     3. Sports Academies & Training Institutes Portal: B2B scheduling and bulk lane/court allocation on Azure Kubernetes Service (AKS) & Azure Container Apps for swimming clubs, diving academies, and national federations. Supports movable pool bulkhead/depth configurations (50m Olympic vs 25m short-course split), certified coach accreditation, attendance tracking, and split-invoicing stored in Azure Database for PostgreSQL Flexible Server (Zone-Redundant HA) and Azure Event Hubs.
     Compliance & NFRs: PCI-DSS 4.0 (payment tokenization in Azure Key Vault Premium HSM), ISO 27001, UAE PDPL data residency (Azure UAE North / UAE Central), 99.99% availability during live ticket drops (25,000 peak RPS), and p99 latency < 150ms.

### Strategic Objectives & Target KPIs
| Objective ID | Strategic Objective | Target KPI / SLA |
| :--- | :--- | :--- |
| **OBJ-01** | **High-Concurrency Championship Ticketing** | Support **25,000 RPS Peak • Multi-AZ Auto-Scaling** with zero double-booking via 8-minute distributed Redis seat locks |
| **OBJ-02** | **Sub-150ms Smart Turnstile & Wristband Entry** | Achieve **p99 < 150ms** NFC/QR turnstile validation for 15,000 spectators and daily members |
| **OBJ-03** | **Automated B2B Academy & Pool Bulkhead Scheduling** | Eliminate lane/court scheduling conflicts across 50m Olympic, 25m split-bulkhead, and 10m diving pools |
| **OBJ-04** | **Regulatory & Payment Compliance** | Full adherence to **SOC 2 Type II, ISO 27001** with regional data residency |

---

## 2. Project Scope & System Boundaries

### In-Scope Capabilities
1. **Audience Event Ticketing & 3D Bowl Reservation**:
   - Interactive 3D arena bowl seat selection across VIP Hospitality, Royal Box, Lower Bowl, and Upper Bowl tiers.
   - Distributed 8-minute seat-reservation lock TTL backed by **Azure Cache for Redis Enterprise**.
   - Apple Wallet / Google Wallet NFC & dynamic QR pass issuance with anti-scalping bot protection (**Azure Front Door Premium WAF**).
2. **Individual & Family Membership Access**:
   - Tiered monthly/annual plans (`Gold Aquatics`, `Fitness All-Access`, `Junior Athlete`).
   - **Microsoft Entra External ID (OIDC + UAE PASS)** sign-in, NFC wristband binding, locker allocation, and automated recurring billing.
3. **Sports Academies & Training Institutes B2B Portal**:
   - Bulk lane and court reservation engine with movable pool bulkhead/depth mode awareness (`50m_olympic`, `25m_short_course_split`, `10m_diving_well`).
   - Coach accreditation verification, trainee attendance logs, and B2B credit-limit / split-invoicing.

### Out-of-Scope (Phase 2)
- Third-party merchandise POS inventory hardware replacement.
- Broadcast television satellite transponder hardware control.

---

## 3. Stakeholder Matrix (RACI) & User Personas

| Stakeholder / Persona | Role | RACI | Primary Jobs-to-be-Done (JTBD) |
| :--- | :--- | :---: | :--- |
| **Arena Spectator / Ticket Buyer** | External Consumer | **I** | Reserve 3D bowl seats during live ticket drops, pay via tokenized checkout, enter via Apple/Google Wallet QR/NFC |
| **Complex Member (Aquatics / Fitness)** | Recurring Member | **I** | Authenticate via UAE PASS, tap NFC wristband at pool/gym turnstiles, manage family memberships |
| **Training Academy Director / Coach** | B2B Partner | **C** | Book 50m/25m pool lanes & multi-sport courts, register accredited coaches, settle monthly B2B invoices |
| **Venue Operations & Aquatics Director** | Business Owner | **A** | Configure event calendars, pool bulkhead/floor schedules, capacity guardrails, and VIP pricing |
| **Chief Enterprise & Cloud Architect** | Technical Authority | **R** | Govern **azure** topology, **Next.js 15 (TypeScript), Tailwind CSS, Python 3.12, FastAPI, SQLAlchemy 2.0 + Alembic, OAuth 2.0 PKCE / OIDC (Entra ID / Cognito), GitHub Actions + OpenAPI 3.1 Linter + Terraform, PostgreSQL 16 (Multi-AZ), Redis 7 Cluster**, and **SOC 2 Type II, ISO 27001** security controls |

---

## 4. Functional Requirements Specification

| Req ID | Domain Stream | Functional Requirement ("Shall" Statement) | Priority | Acceptance Criteria (Given / When / Then) |
| :--- | :--- | :--- | :---: | :--- |
| **FR-01** | **Event Ticketing** | The platform shall lock selected arena seats for **8 minutes (480s TTL)** during checkout. | **Must Have** | **Given** an available seat, **When** a buyer initiates checkout, **Then** Redis acquires an atomic lock preventing concurrent reservation for 480s. |
| **FR-02** | **Event Ticketing** | The platform shall tokenize all card payments via PCI-DSS 4.0 vaulting and issue signed QR/NFC passes. | **Must Have** | **Given** a locked seat, **When** payment succeeds, **Then** an ACID booking record is committed and an event is published to issue a Wallet PKPASS. |
| **FR-03** | **Smart Turnstiles** | The platform shall validate spectator QR passes and member NFC wristbands at arena gates in **< 150ms p99**. | **Must Have** | **Given** a gate scan via Azure IoT Hub / APIM, **When** the pass hash is verified in Redis cache, **Then** the turnstile unlocks within 150ms and logs to `turnstile_access_logs`. |
| **FR-04** | **Membership Access** | The platform shall support OIDC & UAE PASS federation for member onboarding and recurring subscription renewals. | **Must Have** | **Given** a UAE resident, **When** they sign in with UAE PASS, **Then** their Emirates ID hash is verified and linked to their NFC wristband UID. |
| **FR-05** | **Academy B2B Portal** | The platform shall prevent academy lane allocations from overlapping with active championship `arena_events` in the same `zone_id`. | **Must Have** | **Given** an existing arena event in `olympic_pool_50m`, **When** an academy requests overlapping lanes, **Then** the API returns `409 Conflict`. |
| **FR-06** | **Pool Bulkhead Mode** | The platform shall enforce movable bulkhead capacity rules when switching between `50m_olympic` (10 lanes) and `25m_short_course` (20 lanes). | **Should Have** | **Given** a `25m_short_course` configuration, **When** academies book lanes, **Then** up to 20 concurrent short-course lanes can be allocated. |

---

## 5. Non-Functional Requirements (NFRs), Stack & Compliance Baseline

- **Target Cloud & Residency**: `azure`
- **Approved Technology Stack**: `Next.js 15 (TypeScript), Tailwind CSS, Python 3.12, FastAPI, SQLAlchemy 2.0 + Alembic, OAuth 2.0 PKCE / OIDC (Entra ID / Cognito), GitHub Actions + OpenAPI 3.1 Linter + Terraform, PostgreSQL 16 (Multi-AZ), Redis 7 Cluster`
- **Architecture Pattern**: `microservices`
- **Availability & DR Target**: `High Availability (99.99%) & Zero-Trust Security` (`RTO: 15m`, `RPO: 5m`, Zone-Redundant Multi-AZ)
- **Peak Load & Throughput**: `25,000 RPS Peak • Multi-AZ Auto-Scaling`
- **Regulatory & Security Compliance**: `SOC 2 Type II, ISO 27001`

### Active Architecture Components Grounded from Workspace Canvas
- **Audience Web/Mobile Ticketing App**
- **Member Wellness App & B2B Academy Portal**
- **Azure Front Door Premium (CDN & WAF)**
- **Microsoft Entra External ID (OIDC / UAE PASS)**
- **Smart Turnstiles & Poolside Kiosks (NFC/QR)**
- **Azure Key Vault Premium HSM (PCI-DSS Vault)**
- **Azure Monitor & Application Insights**
- **Azure API Management (APIM Gateway)**
- **Azure Application Gateway (WAF v2)**
- **Azure IoT Hub (Turnstile & Timing Telemetry)**
- **Event & 3D Bowl Seat Inventory Service (AKS)**
- **High-Concurrency Booking & Checkout Engine (AKS)**
- **Membership & Smart-Wristband Access Service (ACA)**
- **Academy & Pool Bulkhead Scheduling Service (AKS)**
- **Notification & Digital Wallet Pass Service (Functions)**
- **Azure Database for PostgreSQL Flexible Server (HA)**
- **Azure Cache for Redis Enterprise (8-Min Seat Lock)**
- **Azure Event Hubs / Service Bus (Domain Events)**
- **Azure Data Lake Storage Gen2 (Venue Analytics)**