from pathlib import Path
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)


def test_health_endpoint_and_trace_headers():
    resp = client.get("/health", headers={"X-Correlation-ID": "trc-test-001"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "healthy"
    assert resp.headers.get("X-Correlation-ID") == "trc-test-001"
    assert "X-Response-Time-Ms" in resp.headers


def test_archiforge_contracts_and_sql_migrations_valid():
    assert Path("specs/openapi.yaml").exists()
    sql_path = Path("db/migrations/001_initial_schema.sql")
    assert sql_path.exists()
    sql_text = sql_path.read_text()
    assert "created_at TIMESTAMPTZ" in sql_text
    assert "updated_at TIMESTAMPTZ" in sql_text
    assert Path("AGENTS.md").exists()


def test_atomic_seat_lock_and_409_double_booking_prevention():
    event_id = "11111111-1111-1111-1111-111111111111"
    payload_user_a = {
        "event_id": event_id,
        "customer_email": "fan.a@uae.ae",
        "seat_section": "VIP-POOL-A",
        "seat_row": "R1",
        "seat_number": "S12",
        "price_aed": 450.0,
    }
    r1 = client.post("/api/v1/seat-locks", json=payload_user_a)
    assert r1.status_code == 201
    booking_id = r1.json()["booking_id"]
    assert r1.json()["booking_status"] == "LOCKED"

    # Concurrent attempt by User B for the exact same seat must return 409 Conflict
    payload_user_b = {**payload_user_a, "customer_email": "fan.b@uae.ae"}
    r2 = client.post("/api/v1/seat-locks", json=payload_user_b)
    assert r2.status_code == 409
    assert r2.json()["code"] == "SEAT_ALREADY_LOCKED"

    # Confirm checkout with PCI-DSS HSM tokenization
    r3 = client.post(
        "/api/v1/ticket-bookings/confirm-checkout",
        json={"booking_id": booking_id, "payment_instrument_token": "tok_visa_4242"},
    )
    assert r3.status_code == 200
    assert r3.json()["booking_status"] == "CONFIRMED"
    assert r3.json()["payment_ref"].startswith("pay_tok_azkv_")


def test_sub_150ms_turnstile_scan_and_expired_pass_rejection():
    scan_ok = client.post(
        "/api/v1/turnstiles/validate-scan",
        json={
            "zone_id": "22222222-2222-2222-2222-222222222222",
            "gate_number": "GATE-NORTH-VIP-04",
            "scan_type": "NFC_WRISTBAND",
            "credential_payload": "NFC-UID-04:A2:9C:11",
        },
    )
    assert scan_ok.status_code == 200
    data = scan_ok.json()
    assert data["scan_result"] == "GRANTED_OPEN_GATE"
    assert data["validation_latency_ms"] < 150.0

    scan_expired = client.post(
        "/api/v1/turnstiles/validate-scan",
        json={
            "zone_id": "22222222-2222-2222-2222-222222222222",
            "gate_number": "GATE-NORTH-VIP-04",
            "scan_type": "NFC_WRISTBAND",
            "credential_payload": "NFC-EXPIRED-000",
        },
    )
    assert scan_expired.status_code == 403


def test_jwt_authentication_rejection_on_invalid_token():
    resp = client.get("/api/v1/venues-and-zones", headers={"Authorization": "Bearer invalid"})
    assert resp.status_code == 401
    assert resp.json()["code"] == "TOKEN_INVALID_OR_EXPIRED"
