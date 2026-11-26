from pathlib import Path
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)


def test_health_endpoint():
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "healthy"


def test_archiforge_contracts_present():
    assert Path("specs/openapi.yaml").exists()
    assert Path("db/migrations/001_initial_schema.sql").exists()
    assert Path("AGENTS.md").exists()
