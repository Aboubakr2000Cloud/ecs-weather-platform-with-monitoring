from app.app import app as flask_app
from unittest.mock import patch, MagicMock
import os
import json
import pytest


def test_health_endpoint_structure(client):
    """Health endpoint returns correct JSON structure"""
    response = client.get("/health")
    data = json.loads(response.data)
    assert "status" in data
    assert "db" in data


def test_health_endpoint_returns_200_or_503(client):
    """Health endpoint returns valid status code"""
    response = client.get("/health")
    assert response.status_code in [200, 503]


def test_weather_endpoint_404_for_invalid_city(mock_get, client):
    """Weather endpoint returns 404 when Weather API returns 404"""

    fake_response = MagicMock()
    fake_response.status_code = 404
    fake_response.json.return_value = {
        "cod": "404",
        "message": "city not found",
    }

    mock_get.return_value = fake_response

    response = client.get("/weather/ThisCityDefinitelyDoesNotExist12345")

    assert response.status_code == 404
    mock_get.assert_called_once()


def test_history_endpoint_returns_list(client, mock_db):
    """History endpoint returns a JSON list"""
    response = client.get("/api/history")
    data = json.loads(response.data)
    assert isinstance(data, list)


@pytest.fixture
def client():
    """Flask test client with test config"""

    flask_app.config["TESTING"] = True
    # Set dummy env vars for testing
    os.environ.setdefault("DB_HOST", "localhost")
    os.environ.setdefault("DB_USER", "test")
    os.environ.setdefault("DB_PASSWORD", "test")
    os.environ.setdefault("DB_NAME", "test")
    os.environ.setdefault("WEATHER_API_KEY", "test")
    with flask_app.test_client() as c:
        yield c
