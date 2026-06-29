from unittest.mock import MagicMock

import pytest
from app import app as flask_app


@pytest.fixture
def mock_db(monkeypatch):
    mock_conn = MagicMock()

    mock_cursor = MagicMock()
    mock_conn.cursor.return_value.__enter__.return_value = mock_cursor

    mock_cursor.fetchall.return_value = []

    monkeypatch.setattr(flask_app, "get_db_with_retry", lambda: mock_conn)

    return mock_conn
