-- Step 1: Create the IoT_Sensor_Data Table
CREATE TABLE IoT_Sensor_Data (
    SensorID INT,
    SensorType VARCHAR(50),
    Timestamp DATETIME,
    Temperature FLOAT,
    SmokeLevel FLOAT,
    Location VARCHAR(100)
);

-- Step 2: Insert sample data into IoT_Sensor_Data Table
INSERT INTO IoT_Sensor_Data (SensorID, SensorType, Timestamp, Temperature, SmokeLevel, Location)
VALUES 
(1, 'Temperature', '2024-08-01 08:00:00', 36.5, NULL, 'Building A, Floor 1'),
(2, 'Smoke', '2024-08-01 08:05:00', NULL, 0.2, 'Building A, Floor 1'),
(3, 'Temperature', '2024-08-01 08:10:00', 45.3, NULL, 'Building B, Floor 2'),
(4, 'Smoke', '2024-08-01 08:15:00', NULL, 7.8, 'Building B, Floor 2');

-- Step 3: Create the Fire_Incident_Data Table
CREATE TABLE Fire_Incident_Data (
    IncidentID INT PRIMARY KEY,
    Location VARCHAR(100),
    IncidentSeverity INT,
    IncidentTimestamp DATETIME,
    ResponseTime INT
);

-- Step 4: Insert sample data into Fire_Incident_Data Table
INSERT INTO Fire_Incident_Data (IncidentID, Location, IncidentSeverity, IncidentTimestamp, ResponseTime)
VALUES 
(1, 'Building A, Floor 1', 2, '2024-08-01 08:10:00', 15),
(2, 'Building B, Floor 2', 3, '2024-08-01 08:20:00', 10),
(3, 'Building A, Floor 2', 1, '2024-08-01 08:30:00', 20),
(4, 'Building B, Floor 1', 2, '2024-08-01 08:40:00', 25);

-- Step 5: Query to retrieve sensor data and associated fire incident details
SELECT 
    s.SensorID,
    s.SensorType,
    s.Timestamp,
    s.Temperature,
    s.SmokeLevel,
    s.Location,
    i.IncidentSeverity,
    i.ResponseTime
FROM 
    IoT_Sensor_Data s
LEFT JOIN 
    Fire_Incident_Data i ON s.Location = i.Location AND CAST(s.Timestamp AS DATE) = CAST(i.IncidentTimestamp AS DATE)
WHERE 
    s.Timestamp BETWEEN '2024-08-01 00:00:00' AND '2024-08-02 00:00:00';

-- Step 6: Aggregate query to analyze fire incidents by severity and location
SELECT 
    Location,
    COUNT(IncidentID) AS NumberOfIncidents,
    AVG(ResponseTime) AS AvgResponseTime
FROM 
    Fire_Incident_Data
GROUP BY 
    Location
ORDER BY 
    NumberOfIncidents DESC;

-- Step 7: Query to identify high-risk periods based on sensor data and fire incidents
SELECT 
    s.Location,
    DATEPART(HOUR, s.Timestamp) AS HourOfDay,
    AVG(s.Temperature) AS AvgTemperature,
    AVG(s.SmokeLevel) AS AvgSmokeLevel,
    COUNT(i.IncidentID) AS IncidentCount
FROM 
    IoT_Sensor_Data s
LEFT JOIN 
    Fire_Incident_Data i ON s.Location = i.Location AND DATEPART(HOUR, s.Timestamp) = DATEPART(HOUR, i.IncidentTimestamp)
GROUP BY 
    s.Location, DATEPART(HOUR, s.Timestamp)
HAVING 
    AVG(s.Temperature) > 30 OR AVG(s.SmokeLevel) > 5
ORDER BY 
    IncidentCount DESC;
