USE SmartHomeManagement;
GO

-- Insert into Person (Remove person_ID from INSERT as it's auto-generated)
INSERT INTO Person (name, email, password, access_Level) VALUES 
('Alice Johnson', 'alice.j@example.com', 'password123', 'User'),
('Bob Smith', 'bob.s@example.com', 'password456', 'Admin'),
('Carol White', 'carol.w@example.com', 'password789', 'User'),
('David Brown', 'david.b@example.com', 'password101', 'User'),
('Eve Green', 'eve.g@example.com', 'password102', 'Admin'),
('Frank Black', 'frank.b@example.com', 'password103', 'User'),
('Grace Grey', 'grace.g@example.com', 'password104', 'User'),
('Hank Blue', 'hank.b@example.com', 'password105', 'Admin'),
('Ivy Gold', 'ivy.g@example.com', 'password106', 'User'),
('Jack Silver', 'jack.s@example.com', 'password107', 'User');

-- Insert into User (Uses person_ID values generated from previous insert)
INSERT INTO [User] (user_ID, access_Level) VALUES
(1, 'Standard'),
(3, 'Premium'),
(4, 'Standard'),
(6, 'Premium'),
(7, 'Standard'),
(9, 'Premium'),
(10, 'Standard');

-- Insert into SystemAdmin (Uses person_ID values generated from previous insert)
INSERT INTO SystemAdmin (admin_ID, maintenance_Logs) VALUES
(2, 'Log entry 1'),
(5, 'Log entry 2'),
(8, 'Log entry 3');

-- Insert into SubscriptionPlan (Remove plan_ID from INSERT)
INSERT INTO SubscriptionPlan (plan_Name, price, start_Date, expiration_Date, payment_Status, user_ID) VALUES
('Basic Plan', 29.99, '2024-01-01', '2024-12-31', 'Completed', 1),
('Premium Plan', 49.99, '2024-02-01', '2024-12-31', 'In Progress', 3),
('Basic Plan', 29.99, '2024-03-01', '2024-12-31', 'Pending', 4),
('Premium Plan', 49.99, '2024-04-01', '2024-12-31', 'Completed', 6),
('Basic Plan', 29.99, '2024-05-01', '2024-12-31', 'Failed', 7),
('Premium Plan', 49.99, '2024-06-01', '2024-12-31', 'Cancelled', 9),
('Basic Plan', 29.99, '2024-07-01', '2024-12-31', 'Completed', 10);

-- Continue with the rest of your INSERT statements, removing the ID columns that are now auto-generated
---------
-- Insert into SubscriptionFeatures
INSERT INTO SubscriptionFeatures (feature_Name, plan_ID) VALUES
('Remote Control', 1),
('Energy Monitoring', 1),
('Smart Scheduling', 2),
('Advanced Security', 2),
('Basic Automation', 3),
('Temperature Control', 3),
('Voice Control', 4),
('Multi-user Access', 4),
('Basic Monitoring', 5),
('Alert System', 6);
SELECT * FROM SubscriptionPlan

-- Insert into CommonFeatures
INSERT INTO CommonFeatures (plan_ID, feature_ID) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6),
(4, 7),
(4, 8),
(5, 9),
(6, 10);

-- Insert into Payment
INSERT INTO Payment (payment_Method, amount_Paid, billing_Period, payment_Status, transaction_Date, plan_ID, user_ID) VALUES
('Credit Card', 29.99, 'Monthly', 'Completed', '2024-01-01 10:00:00', 1, 1),
('PayPal', 49.99, 'Monthly', 'Completed', '2024-02-01 11:00:00', 2, 3),
('Debit Card', 29.99, 'Monthly', 'Pending', '2024-03-01 12:00:00', 3, 4),
('Credit Card', 49.99, 'Monthly', 'Completed', '2024-04-01 13:00:00', 4, 6),
('Bank Transfer', 29.99, 'Monthly', 'Failed', '2024-05-01 14:00:00', 5, 7);
SELECT * FROM Payment

-- Insert into Device
INSERT INTO Device (device_Name, device_Type, device_Status, device_Location, energy_Usage, connectivity_Status, last_Update_Time, fault_Status, user_ID) VALUES
('Smart Thermostat', 'Temperature Control', 'Active', 'Living Room', 5.5, 'Connected', '2024-01-01 09:00:00', 'Normal', 1),
('Security Camera', 'Security', 'Active', 'Kitchen', 3.2, 'Connected', '2024-01-01 09:00:00', 'Normal', 3),
('Smart Light', 'Lighting', 'Active', 'Bedroom', 1.5, 'Connected', '2024-01-01 09:00:00', 'Normal', 4),
('Smart Lock', 'Security', 'Active', 'Living Room', 2.0, 'Connected', '2024-01-01 09:00:00', 'Normal', 6),
('Smart Plug', 'Power', 'Inactive', 'Kitchen', 0.5, 'Disconnected', '2024-01-01 09:00:00', 'Fault', 7);
SELECT * FROM Device

-- Insert into Schedule
INSERT INTO Schedule (start_Time, end_Time, recurrence_Pattern, status, device_ID) VALUES
('2024-01-01 06:00:00', '2024-01-01 22:00:00', 'Daily', 'Active', 1),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 'Daily', 'Active', 2),
('2024-01-01 18:00:00', '2024-01-01 23:00:00', 'Daily', 'Active', 3),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 'Daily', 'Active', 4),
('2024-01-01 09:00:00', '2024-01-01 17:00:00', 'Weekdays', 'Inactive', 5);
SELECT * FROM Schedule

-- Insert into Security
INSERT INTO Security (security_Access_Level, access_Log, device_ID) VALUES
('High', 'No unauthorized access detected', 1),
('Maximum', 'Door locked successfully', 2),
('Medium', 'Motion detected', 3),
('High', 'Window secured', 4),
('Low', 'Device offline', 5);
SELECT * FROM [Security]

-- Insert into EnergyUsage
INSERT INTO EnergyUsage (start_Time, end_Time, total_Energy_Consumed, energy_Cost, device_ID) VALUES
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 12.5, 1.25, 1),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 8.3, 0.83, 2),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 5.2, 0.52, 3),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 3.7, 0.37, 4),
('2024-01-01 00:00:00', '2024-01-01 23:59:59', 1.5, 0.15, 5);
SELECT * FROM EnergyUsage

-- Insert into Room
INSERT INTO Room (room_Name, room_Temperature, energy_Consumption, room_Lighting, room_Security_Status, device_ID) VALUES
('Living Room', 72.5, 15.2, 'Bright', 'Secured', 1),
('Kitchen', 74.0, 12.8, 'Medium', 'Secured', 2),
('Bedroom', 71.0, 8.5, 'Dim', 'Secured', 3),
('Bathroom', 73.5, 6.2, 'Bright', 'Secured', 4),
('Laundry Room', 75.0, 10.1, 'Medium', 'Secured', 5);
SELECT * FROM Room

-- Insert into Sensor
INSERT INTO Sensor (sensor_Type, sensor_Value, status, last_Calibrated_Time, room_ID) VALUES
('Temperature', '72.5°F', 'Active', '2024-01-01 00:00:00', 1),
('Motion', 'No Motion', 'Active', '2024-01-01 00:00:00', 2),
('Humidity', '45%', 'Active', '2024-01-01 00:00:00', 3),
('Light', '800 lux', 'Active', '2024-01-01 00:00:00', 4),
('Air Quality', 'Good', 'Active', '2024-01-01 00:00:00', 5);
SELECT * FROM Sensor


-- Insert into Notification
INSERT INTO Notification (notification_Type, notification_Content, date_and_Time_Sent, status, trigger_Condition, device_ID, user_ID) VALUES
('Alert', 'Temperature above threshold', '2024-01-01 10:15:00', 'Sent', 'Temperature > 75°F', 1, 1),
('Warning', 'Motion detected', '2024-01-01 11:30:00', 'Sent', 'Motion Sensor Triggered', 2, 3),
('Info', 'Device offline', '2024-01-01 12:45:00', 'Pending', 'Connection Lost', 3, 4),
('Alert', 'Door unlocked', '2024-01-01 13:00:00', 'Sent', 'Lock Status Changed', 4, 6),
('Warning', 'Low battery', '2024-01-01 14:15:00', 'Sent', 'Battery < 20%', 5, 7);
SELECT * FROM Notification


-- Insert into Maintenance
INSERT INTO Maintenance (fault_Type, resolution_Type, detection_Time, resolution_Time, device_ID, admin_ID) VALUES
('Connection Issue', 'Reset Device', '2024-01-01 10:00:00', '2024-01-01 10:30:00', 1, 2),
('Battery Low', 'Replace Battery', '2024-01-01 11:00:00', '2024-01-01 11:45:00', 2, 5),
('Sensor Malfunction', 'Calibration', '2024-01-01 12:00:00', '2024-01-01 12:30:00', 3, 8),
('Software Bug', 'Update Firmware', '2024-01-01 13:00:00', '2024-01-01 14:00:00', 4, 2),
('Hardware Failure', 'Replace Unit', '2024-01-01 14:00:00', '2024-01-01 15:30:00', 5, 5);
SELECT * FROM Maintenance


-- Insert into FaultNotification
INSERT INTO FaultNotification (fault_Detail, admin_ID) VALUES
('Device 1 connection lost - requires immediate attention', 2),
('Battery replacement needed for Device 2', 5),
('Sensor calibration required for Device 3', 8),
('Software update failed for Device 4', 2),
('Hardware replacement needed for Device 5', 5);
SELECT * FROM FaultNotification