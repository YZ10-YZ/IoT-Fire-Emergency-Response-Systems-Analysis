-- Step 1: Database Setup and Configuration

-- Create table for IoT sensor data
CREATE TABLE IoT_Sensor_Data (
    SensorID INT PRIMARY KEY,
    SensorType VARCHAR(50),
    Timestamp DATETIME,
    Temperature FLOAT,
    SmokeLevel FLOAT,
    Location VARCHAR(100)
);

-- Create table for fire incident data
CREATE TABLE Fire_Incident_Data (
    IncidentID INT PRIMARY KEY,
    Location VARCHAR(100),
    IncidentSeverity INT,
    IncidentTimestamp DATETIME,
    ResponseTime INT
);

-- Create table for emergency response actions
CREATE TABLE Emergency_Response_Actions (
    ActionID INT PRIMARY KEY,
    IncidentID INT,
    ActionDescription VARCHAR(255),
    ActionTimestamp DATETIME,
    FOREIGN KEY (IncidentID) REFERENCES Fire_Incident_Data(IncidentID)
);

-- Step 2: Data Retrieval Queries

-- Query 1: Retrieve all sensor data related to smoke and temperature for the last 24 hours
SELECT 
    SensorID, 
    SensorType, 
    Timestamp, 
    Temperature, 
    SmokeLevel, 
    Location 
FROM 
    IoT_Sensor_Data
WHERE 
    Timestamp >= DATEADD(HOUR, -24, GETDATE());

-- Query 2: Retrieve data from specific sensors based on location
SELECT 
    SensorID, 
    SensorType, 
    Timestamp, 
    Temperature, 
    SmokeLevel 
FROM 
    IoT_Sensor_Data
WHERE 
    Location = 'Building A, Floor 2';

-- Query 3: Join tables to analyze response times from previous fire emergencies and correlate with sensor data
SELECT 
    i.Location,
    i.IncidentSeverity,
    i.IncidentTimestamp,
    r.ResponseTime,
    s.AvgTemperature,
    s.AvgSmokeLevel
FROM 
    Fire_Incident_Data i
JOIN 
    (SELECT 
        Location,
        AVG(Temperature) AS AvgTemperature,
        AVG(SmokeLevel) AS AvgSmokeLevel
     FROM 
        IoT_Sensor_Data
     GROUP BY 
        Location) s ON i.Location = s.Location
JOIN 
    Emergency_Response_Actions r ON i.IncidentID = r.IncidentID;

-- Step 3: Data Aggregation and Transformation

-- Query 4: Aggregate sensor data by minute/hour to analyze trends over time
SELECT 
    DATEPART(HOUR, Timestamp) AS HourOfDay,
    AVG(Temperature) AS AvgTemperature,
    AVG(SmokeLevel) AS AvgSmokeLevel
FROM 
    IoT_Sensor_Data
GROUP BY 
    DATEPART(HOUR, Timestamp);

-- Query 5: Calculate the average response time for fire incidents based on location and severity
SELECT 
    Location,
    IncidentSeverity,
    AVG(ResponseTime) AS AvgResponseTime
FROM 
    Fire_Incident_Data
GROUP BY 
    Location, 
    IncidentSeverity;
