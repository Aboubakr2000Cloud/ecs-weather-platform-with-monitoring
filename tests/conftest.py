import pytest
from unittest.mock import MagicMock
import app


@pytest.fixture
def mock_db(monkeypatch):
    mock_conn = MagicMock()

    mock_cursor = MagicMock()
    mock_conn.cursor.return_value.__enter__.return_value = mock_cursor

    mock_cursor.fetchall.return_value = []

    monkeypatch.setattr(app, "get_db_with_retry", lambda: mock_conn)

    return mock_conn
