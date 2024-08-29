# Import necessary libraries
import pyodbc
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix

# Step 1: Data Import and Cleaning

# Establish connection to Azure SQL Database
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};SERVER=your_server_name;DATABASE=your_database_name;UID=your_username;PWD=your_password'
)

# Retrieve data from Azure SQL Database
query = """
SELECT * FROM IoT_Sensor_Data;
"""
sensor_data = pd.read_sql(query, conn)

query_incidents = """
SELECT * FROM Fire_Incident_Data;
"""
incident_data = pd.read_sql(query_incidents, conn)

# Data cleaning
sensor_data.drop_duplicates(inplace=True)
sensor_data.fillna(method='ffill', inplace=True)

# Handle outliers in sensor data
sensor_data = sensor_data[(sensor_data['Temperature'] >= -20) & (sensor_data['Temperature'] <= 100)]
sensor_data = sensor_data[(sensor_data['SmokeLevel'] >= 0) & (sensor_data['SmokeLevel'] <= 10)]

# Step 2: Feature Engineering

# Create new feature: fire risk score based on temperature and smoke level
sensor_data['FireRiskScore'] = (sensor_data['Temperature'] / 100) + (sensor_data['SmokeLevel'] / 10)

# Generate time-based features
sensor_data['HourOfDay'] = pd.to_datetime(sensor_data['Timestamp']).dt.hour
sensor_data['DayOfWeek'] = pd.to_datetime(sensor_data['Timestamp']).dt.dayofweek

# Step 3: Data Analysis and Visualization

# Exploratory Data Analysis (EDA)
plt.figure(figsize=(10, 6))
sns.heatmap(sensor_data.corr(), annot=True, cmap='coolwarm')
plt.title('Correlation Matrix of Sensor Data')
plt.show()

plt.figure(figsize=(10, 6))
sns.lineplot(data=sensor_data, x='Timestamp', y='FireRiskScore', hue='Location')
plt.title('Fire Risk Score Over Time by Location')
plt.xticks(rotation=45)
plt.show()

# Step 4: Predictive Modeling

# Prepare data for modeling
features = ['Temperature', 'SmokeLevel', 'HourOfDay', 'DayOfWeek']
X = sensor_data[features]
y = incident_data['IncidentSeverity']  # Assuming IncidentSeverity is a binary or categorical target variable

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Build a Random Forest model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Model evaluation
y_pred = model.predict(X_test)
print("Classification Report:")
print(classification_report(y_test, y_pred))

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))

# Step 5: Guidance for Emergency Response

# Assuming a simple rule-based model for response guidance
def emergency_guidance(severity):
    if severity >= 3:
        return "Deploy Fire Brigade and Emergency Medical Services"
    elif severity == 2:
        return "Alert Local Fire Wardens and Begin Evacuation"
    else:
        return "Monitor Situation and Standby for Further Instructions"

incident_data['Guidance'] = incident_data['IncidentSeverity'].apply(emergency_guidance)
print(incident_data[['IncidentID', 'IncidentSeverity', 'Guidance']])
