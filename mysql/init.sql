CREATE DATABASE IF NOT EXISTS app_db;

USE app_db;

-- Create counter table to store global counter
CREATE TABLE IF NOT EXISTS counter (
    id INT PRIMARY KEY,
    value INT
);

-- Insert initial value for counter
INSERT INTO counter (id, value) VALUES (1, 0) ON DUPLICATE KEY UPDATE value = value;

-- Create access_log table to store access details
CREATE TABLE IF NOT EXISTS access_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    access_time DATETIME,
    client_ip VARCHAR(45),
    internal_ip VARCHAR(45),
    hostname VARCHAR(255)
);

