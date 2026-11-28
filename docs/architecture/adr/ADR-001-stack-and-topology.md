# ADR-001: Canonical Technology Stack & Cloud Topology for Hamdan Sports Complex Unified Arena & Academy Platform

- **Status:** Approved via The ArchiForge
- **Date:** 2026-11-28
- **Archetype:** `microservices`
- **Decision:** Adopt `Next.js 15 (TypeScript), Tailwind CSS, Python 3.12, FastAPI, SQLAlchemy 2.0 + Alembic, OAuth 2.0 PKCE / OIDC (Entra ID / Cognito), GitHub Actions + OpenAPI 3.1 Linter + Terraform` on `azure` with `PostgreSQL 16 (Multi-AZ), Redis 7 Cluster`.
- **Consequences:** Enforces Enterprise Tech Radar compliance (`0` Hold/Banned dependencies) and contract-first OpenAPI 3.1 + ERD migration synchronization.
