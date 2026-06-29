import os
import requests
import pymysql
import time
from flask import Flask, jsonify, render_template
from datetime import datetime

app = Flask(__name__)

def get_db():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        port=int(os.environ.get("DB_PORT", "3306")),
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=5
    )

def get_db_with_retry(max_retries=5):
    for attempt in range(max_retries):
        try:
            return get_db()
        except pymysql.Error:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
            else:
                raise

def init_db():
    conn = get_db_with_retry(max_retries=10)

    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS weather_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                city VARCHAR(100) NOT NULL,
                country VARCHAR(10),
                temperature FLOAT,
                humidity INT,
                description VARCHAR(200),
                fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_city (city),
                INDEX idx_fetched_at (fetched_at)
            )
        """)

    conn.commit()
    conn.close()

@app.route("/health")
def health():
    try:
        conn = get_db()
        conn.close()
        db_status = "connected"
    except Exception:
        db_status = "unavailable"
    
    status = "healthy" if db_status == "connected" else "degraded"
    code = 200 if db_status == "connected" else 503
    return jsonify({"status": status, "db": db_status}), code

@app.route("/weather/<city>")
def get_weather(city):
    api_key = os.environ.get("WEATHER_API_KEY")
    url = f"https://api.openweathermap.org/data/2.5/weather"
    
    response = requests.get(url, params={
        "q": city,
        "appid": api_key,
        "units": "metric"
    }, timeout=10)
    
    if response.status_code != 200:
        return jsonify({"error": f"City '{city}' not found"}), 404
    
    data = response.json()
    weather = {
        "city": data["name"],
        "country": data["sys"]["country"],
        "temperature": data["main"]["temp"],
        "feels_like": data["main"]["feels_like"],
        "humidity": data["main"]["humidity"],
        "description": data["weather"][0]["description"],
        "fetched_at": datetime.utcnow().isoformat()
    }
    
    # Store in DB
    conn = get_db_with_retry()
    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO weather_log (city, country, temperature, humidity, description)
            VALUES (%s, %s, %s, %s, %s)
        """, (weather["city"], weather["country"],
              weather["temperature"], weather["humidity"],
              weather["description"]))
    conn.commit()
    conn.close()
    
    return jsonify(weather)

@app.route("/api/history")
def history():
    conn = get_db_with_retry()
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT * FROM weather_log
            ORDER BY fetched_at DESC
            LIMIT 20
        """)
        records = cursor.fetchall()
    conn.close()
    
    for r in records:
        if r.get("fetched_at"):
            r["fetched_at"] = str(r["fetched_at"])
    
    return jsonify(records)

@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080, debug=False)
