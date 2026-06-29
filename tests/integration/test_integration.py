import pymysql
import os
from app import app as flask_app


def get_db():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        port=int(os.environ.get("DB_PORT", "3306")),
        cursorclass=pymysql.cursors.DictCursor,
    )


def test_database_connection():
    """Can connect to MySQL and run a query"""
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("SELECT 1 as result")
        result = cursor.fetchone()
    conn.close()
    assert result["result"] == 1


def test_weather_log_table_exists():
    """weather_log table exists with correct schema"""
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("DESCRIBE weather_log")
        columns = {row["Field"] for row in cursor.fetchall()}
    conn.close()
    assert "id" in columns
    assert "city" in columns
    assert "temperature" in columns
    assert "fetched_at" in columns


def test_insert_and_retrieve_weather_log():
    """Can insert a weather record and retrieve it"""
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute(
            "INSERT INTO weather_log (city, country, temperature, humidity, description) "
            "VALUES (%s, %s, %s, %s, %s)",
            ("TestCity", "TC", 20.0, 50, "sunny"),
        )
        conn.commit()
        cursor.execute(
            "SELECT * FROM weather_log WHERE city = 'TestCity' ORDER BY id DESC LIMIT 1"
        )
        record = cursor.fetchone()
    conn.close()
    assert record is not None
    assert record["city"] == "TestCity"
    assert record["temperature"] == 20.0
