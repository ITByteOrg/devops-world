import pytest
import requests

import src.iss_service


def test_get_iss_location_success(monkeypatch):
    class FakeResponse:
        def raise_for_status(self):
            pass  # Pretend the status is OK

        def json(self):
            return {"latitude": 10.0, "longitude": 20.0}

        status_code = 200

    monkeypatch.setattr(requests, "get", lambda url, timeout=5: FakeResponse())

    result = src.iss_service.get_iss_location()
    assert result == {"latitude": 10.0, "longitude": 20.0} # noqa: B101


def test_get_iss_location_http_error(monkeypatch):
    class FakeResponse:
        def raise_for_status(self):
            raise requests.exceptions.HTTPError("500 Internal Server Error")

        def json(self):
            return {}

        status_code = 500

    monkeypatch.setattr(requests, "get", lambda url, timeout=5: FakeResponse())

    result = src.iss_service.get_iss_location()
    assert result == {
        "error": "Failed to fetch ISS data",
        "details": "500 Internal Server Error",
    } # noqa: B101


def test_get_iss_location_bad_json(monkeypatch):
    class FakeResponse:
        def raise_for_status(self):
            pass

        def json(self):
            return {"foo": "bar"}  # Missing required keys

        status_code = 200

    monkeypatch.setattr(requests, "get", lambda url, timeout=5: FakeResponse())

    from src.iss_service import get_iss_location

    with pytest.raises(KeyError, match="Missing keys in response JSON"):
        get_iss_location()
