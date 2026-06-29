from unittest.mock import MagicMock

import pytest
import app.app as app_module


@pytest.fixture
def mock_db(monkeypatch):
    mock_conn = MagicMock()

    mock_cursor = MagicMock()
    mock_conn.cursor.return_value.__enter__.return_value = mock_cursor

    mock_cursor.fetchall.return_value = []

    monkeypatch.setattr(app_module, "get_db", lambda: mock_conn)

    return mock_conn
