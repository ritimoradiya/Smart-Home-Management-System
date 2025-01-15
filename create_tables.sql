-- Drop database if exists and create new
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SmartHomeManagement')
DROP DATABASE SmartHomeManagement
GO
ALTER DATABASE [SmartHomeManagement] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [SmartHomeManagement];

CREATE DATABASE SmartHomeManagement;
GO

DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS CourseSections;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Professors;

USE SmartHomeManagement;
GO

-- Drop tables if they exist
IF OBJECT_ID('FaultNotification', 'U') IS NOT NULL DROP TABLE FaultNotification;
IF OBJECT_ID('Maintenance', 'U') IS NOT NULL DROP TABLE Maintenance;
IF OBJECT_ID('Notification', 'U') IS NOT NULL DROP TABLE Notification;
IF OBJECT_ID('Sensor', 'U') IS NOT NULL DROP TABLE Sensor;
IF OBJECT_ID('Room', 'U') IS NOT NULL DROP TABLE Room;
IF OBJECT_ID('EnergyUsage', 'U') IS NOT NULL DROP TABLE EnergyUsage;
IF OBJECT_ID('Security', 'U') IS NOT NULL DROP TABLE Security;
IF OBJECT_ID('Schedule', 'U') IS NOT NULL DROP TABLE Schedule;
IF OBJECT_ID('Device', 'U') IS NOT NULL DROP TABLE Device;
IF OBJECT_ID('Payment', 'U') IS NOT NULL DROP TABLE Payment;
IF OBJECT_ID('SubscriptionFeatures', 'U') IS NOT NULL DROP TABLE SubscriptionFeatures;
IF OBJECT_ID('SubscriptionPlan', 'U') IS NOT NULL DROP TABLE SubscriptionPlan;
IF OBJECT_ID('Admin', 'U') IS NOT NULL DROP TABLE Admin;
IF OBJECT_ID('User', 'U') IS NOT NULL DROP TABLE [User];
IF OBJECT_ID('Person', 'U') IS NOT NULL DROP TABLE Person;

-- Create tables with corrected constraints and relationships
CREATE TABLE Person (
    person_ID INT IDENTITY(1,1) NOT NULL,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL,
    password VARCHAR(30) NOT NULL,
    access_Level VARCHAR(10) NOT NULL,        
    CONSTRAINT Person_PK PRIMARY KEY (person_ID),
    CONSTRAINT access_Level_CHK CHECK ([access_Level] in ('User', 'Admin'))
);

CREATE TABLE [User] (
    user_ID INT NOT NULL,
    access_Level VARCHAR(50) NOT NULL,
    CONSTRAINT User_PK PRIMARY KEY (user_ID),
    CONSTRAINT User_FK FOREIGN KEY (user_ID) REFERENCES Person(person_ID)
);

CREATE TABLE [SystemAdmin] (
    admin_ID INT NOT NULL,
    maintenance_Logs VARCHAR(100) NOT NULL,
    CONSTRAINT Admin_PK PRIMARY KEY (admin_ID),
    CONSTRAINT Admin_FK FOREIGN KEY (admin_ID) REFERENCES Person(person_ID)
);

CREATE TABLE SubscriptionPlan (
    plan_ID INT IDENTITY(1,1),
    plan_Name VARCHAR(30),
    price NUMERIC(10, 2),
    start_Date DATE,
    expiration_Date DATE,
    payment_Status VARCHAR(30),
    user_ID INT,
    CONSTRAINT SubscriptionPlan_PK PRIMARY KEY (plan_ID),
    CONSTRAINT SubscriptionPlan_FK1 FOREIGN KEY (user_ID) REFERENCES [User](user_ID),
    CONSTRAINT SubscriptionPlan_payment_Status_CHK CHECK ([payment_Status] in ('Pending', 'Completed', 'Failed', 'Cancelled', 'In Progress'))
);

CREATE TABLE SubscriptionFeatures (
    feature_ID INT IDENTITY(1,1),
    feature_Name VARCHAR(30),
    plan_ID INT,
    CONSTRAINT SubscriptionFeatures_PK PRIMARY KEY (feature_ID),
    CONSTRAINT SubscriptionFeatures_FK1 FOREIGN KEY (plan_ID) REFERENCES SubscriptionPlan(plan_ID)
);

CREATE TABLE CommonFeatures (
    common_feature_ID INT IDENTITY(1,1) NOT NULL,
    plan_ID INT,
    feature_ID INT,
    CONSTRAINT CommonFeatures_PK PRIMARY KEY (common_feature_ID),
    CONSTRAINT CommonFeatures_FK1 FOREIGN KEY (plan_ID) REFERENCES SubscriptionPlan(plan_ID),
    CONSTRAINT CommonFeatures_FK2 FOREIGN KEY (feature_ID) REFERENCES SubscriptionFeatures(feature_ID)
)

CREATE TABLE Payment (
    payment_ID INT IDENTITY(1,1),
    payment_Method VARCHAR(50),
    amount_Paid NUMERIC(10, 2),
    billing_Period VARCHAR(50),
    payment_Status VARCHAR(50),
    transaction_Date DATETIME,
    plan_ID INT,
    user_ID INT,
    CONSTRAINT Payment_PK PRIMARY KEY (payment_ID),
    CONSTRAINT Payment_FK1 FOREIGN KEY (plan_ID) REFERENCES SubscriptionPlan(plan_ID),
    CONSTRAINT Payment_FK2 FOREIGN KEY (user_ID) REFERENCES [User](user_ID),
    CONSTRAINT Payment_payment_Status_CHK CHECK ([payment_Status] in ('Pending', 'Completed', 'Failed', 'Cancelled', 'In Progress'))
);

CREATE TABLE Device (
    device_ID INT IDENTITY(1,1),
    device_Name VARCHAR(30),
    device_Type VARCHAR(30),
    device_Status VARCHAR(30),
    device_Location VARCHAR(30),
    energy_Usage NUMERIC(10, 2),
    connectivity_Status VARCHAR(50),
    last_Update_Time DATETIME,
    fault_Status VARCHAR(50),
    user_ID INT,
    CONSTRAINT Device_PK PRIMARY KEY (device_ID),
    CONSTRAINT Device_FK1 FOREIGN KEY (user_ID) REFERENCES [User](user_ID),
    CONSTRAINT Device_device_Location_CHK CHECK (device_Location IN ('Bedroom', 'Kitchen', 'Bathroom', 'Living Room', 'Laundry Room', 'Cleaning'))
);

CREATE TABLE Schedule (
    schedule_ID INT IDENTITY(1,1),
    start_Time DATETIME,
    end_Time DATETIME,
    recurrence_Pattern VARCHAR(30),
    status VARCHAR(30),
    device_ID INT,
    CONSTRAINT Schedule_PK PRIMARY KEY (schedule_ID),
    CONSTRAINT Schedule_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID),
    CONSTRAINT Schedule_status_CHK CHECK ([status] in ('Active', 'Inactive'))
);

CREATE TABLE Security (
    security_Control_ID INT IDENTITY(1,1),
    security_Access_Level VARCHAR(50),
    access_Log VARCHAR(100),
    device_ID INT,
    CONSTRAINT Security_PK PRIMARY KEY (security_Control_ID),
    CONSTRAINT Security_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID)
);

CREATE TABLE EnergyUsage (
    energy_ID INT IDENTITY(1,1),
    start_Time DATETIME,
    end_Time DATETIME,
    total_Energy_Consumed NUMERIC(10, 2),
    energy_Cost NUMERIC(10, 2),
    device_ID INT,
    CONSTRAINT EnergyUsage_PK PRIMARY KEY (energy_ID),
    CONSTRAINT EnergyUsage_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID)
);

CREATE TABLE Room (
    room_ID INT IDENTITY(1,1),
    room_Name VARCHAR(30),
    room_Temperature NUMERIC(5, 2),
    energy_Consumption NUMERIC(10, 2),
    room_Lighting VARCHAR(50),
    room_Security_Status VARCHAR(50),
    device_ID INT,
    CONSTRAINT Room_PK PRIMARY KEY (room_ID),
    CONSTRAINT Room_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID)
);

CREATE TABLE Sensor (
    sensor_ID INT IDENTITY(201,1),
    sensor_Type VARCHAR(30),
    sensor_Value VARCHAR(30),
    status VARCHAR(50),
    last_Calibrated_Time DATETIME,
    room_ID INT,
    CONSTRAINT Sensor_PK PRIMARY KEY (sensor_ID),
    CONSTRAINT Sensor_FK1 FOREIGN KEY (room_ID) REFERENCES Room(room_ID),
    CONSTRAINT Sensor_status_CHK CHECK ([status] in ('Active', 'Inactive'))
);

CREATE TABLE Notification (
    notification_ID INT IDENTITY(301,1),
    notification_Type VARCHAR(50),
    notification_Content VARCHAR(100),
    date_and_Time_Sent DATETIME,
    status VARCHAR(50),
    trigger_Condition VARCHAR(100),
    device_ID INT,
    user_ID INT,
    CONSTRAINT Notification_PK PRIMARY KEY (notification_ID),
    CONSTRAINT Notification_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID),
    CONSTRAINT Notification_FK2 FOREIGN KEY (user_ID) REFERENCES [User](user_ID)
);

CREATE TABLE Maintenance (
    task_ID INT IDENTITY(401,1),
    fault_Type VARCHAR(100),
    resolution_Type VARCHAR(100),
    detection_Time DATETIME,
    resolution_Time DATETIME,
    device_ID INT,
    admin_ID INT,
    CONSTRAINT Maintenance_PK PRIMARY KEY (task_ID),
    CONSTRAINT Maintenance_FK1 FOREIGN KEY (device_ID) REFERENCES Device(device_ID),
    CONSTRAINT Maintenance_FK2 FOREIGN KEY (admin_ID) REFERENCES SystemAdmin(admin_ID)
);

CREATE TABLE FaultNotification (
    fault_ID INT IDENTITY(501,1),
    fault_Detail NVARCHAR(MAX),
    admin_ID INT,
    CONSTRAINT FaultNotification_PK PRIMARY KEY (fault_ID),
    CONSTRAINT FaultNotification_FK1 FOREIGN KEY (admin_ID) REFERENCES SystemAdmin(admin_ID)
);