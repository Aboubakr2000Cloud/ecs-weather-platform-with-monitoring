CREATE DATABASE IF NOT EXISTS weatherapp;
USE weatherapp;

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
);
