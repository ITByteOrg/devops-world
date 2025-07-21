# tests/test_iss_location.py
import os
import sys

import pytest

from src.app import app

# from unittest.mock import patch

# Ensure the src directory is in the path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


@pytest.fixture
def client():
    with app.test_client() as client:
        yield client


def test_iss_location_success(client, monkeypatch):
    mock_iss_data = {
        "latitude": 10.0,
        "longitude": 20.0,
        "altitude": 420.0,  # km
        "velocity": 27600.0,  # km/h
        "visibility": "daylight",
    }

    # Patch get_iss_location to return mock data
    monkeypatch.setattr("src.app.get_iss_location", lambda: mock_iss_data)

    response = client.get("/iss-location")
    assert response.status_code == 200
    data = response.get_json()

    assert data["latitude"] == 10.0
    assert data["altitude_mi"] == round(420.0 * 0.621371, 2)


def test_iss_location_failure(client, monkeypatch):
    # Simulate a failure in the service
    monkeypatch.setattr("src.app.get_iss_location", lambda: None)

    response = client.get("/iss-location")
    assert response.status_code == 500
    data = response.get_json()

    assert "error" in data


def test_home_route_loads():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert b"<title>Bytes & Pipelines</title>" in response.data
