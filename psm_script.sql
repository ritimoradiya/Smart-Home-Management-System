USE SmartHomeManagement
GO
-- Stored procedures

/*(1)-- To get a user's subscription plan details: */
CREATE PROCEDURE GetSubscriptionDetails
    @UserID INT,
    @PlanName VARCHAR(30) OUTPUT,
    @Price NUMERIC(10, 2) OUTPUT
AS
BEGIN
    SELECT 
        @PlanName = plan_Name,
        @Price = price
    FROM SubscriptionPlan
    WHERE user_ID = @UserID;
END;
GO

--- show output
DECLARE @PlanName VARCHAR(30);
DECLARE @Price NUMERIC(10, 2);

-- Execute the stored procedure for UserID = 1
EXEC GetSubscriptionDetails
    @UserID = 3,
    @PlanName = @PlanName OUTPUT,
    @Price = @Price OUTPUT;

--- Display the output values
SELECT @PlanName AS PlanName, @Price AS Price;

-- 
/*(2)--Fetches the status of all devices in a specific room.*/
GO
CREATE PROCEDURE GetDeviceStatusByRoom
    @RoomName VARCHAR(50)
AS
BEGIN
    SELECT device_ID, device_Name, device_Status, connectivity_Status, last_Update_Time
    FROM Device
    WHERE device_Location = @RoomName;
END;

EXEC GetDeviceStatusByRoom @RoomName = 'Kitchen';

-- 
/*(3)--Adds a new subscription plan to the database and outputs the new plan_ID.*/
GO
CREATE PROCEDURE AddSubscriptionPlan
    @PlanName VARCHAR(30),
    @Price NUMERIC(10,2),
    @StartDate DATE,
    @ExpirationDate DATE,
    @PaymentStatus VARCHAR(30), -- The plaintext status
    @UserID INT,
    @NewPlanID INT OUTPUT
AS
BEGIN
    -- Encrypt the PaymentStatus value
    DECLARE @EncryptedPaymentStatus VARBINARY(MAX);
    SET @EncryptedPaymentStatus = ENCRYPTBYKEY(KEY_GUID('DataSymmetricKey'), @PaymentStatus);

    -- Insert into SubscriptionPlan
    INSERT INTO SubscriptionPlan (plan_Name, price, start_Date, expiration_Date, payment_Status, user_ID)
    VALUES (@PlanName, @Price, @StartDate, @ExpirationDate, @EncryptedPaymentStatus, @UserID);

    -- Output the new plan ID
    SET @NewPlanID = SCOPE_IDENTITY();
END;
GO

DECLARE @NewPlanID INT;

EXEC AddSubscriptionPlan
    @PlanName = 'Discounted Plan',
    @Price = 5.99,
    @StartDate = '2024-11-16',
    @ExpirationDate = '2024-12-16',
    @PaymentStatus = 'Completed',
    @UserID = 10,
    @NewPlanID = @NewPlanID OUTPUT;

-- Check the newly added plan ID
SELECT @NewPlanID AS NewPlanID;

-- 
/*(4)--This stored procedure retrieves energy usage details for a device.*/
GO
CREATE PROCEDURE GetDeviceEnergyUsage
    @DeviceID INT
AS
BEGIN
    SELECT 
        E.start_Time,
        E.end_Time,
        E.total_Energy_Consumed,
        E.energy_Cost
    FROM 
        EnergyUsage E
    WHERE 
        E.device_ID = @DeviceID;

    PRINT 'Energy usage details fetched successfully!';
END;
GO

EXEC GetDeviceEnergyUsage @DeviceID = 1;


-- Views
/*(1)--View to show all active smart devices.*/
GO
CREATE VIEW ActiveSmartDevices AS
SELECT sd.device_ID, sd.device_name, sd.device_type, sd.device_Status, u.user_ID, pe.name AS user_name
FROM Device sd
JOIN [User] u ON sd.user_ID = u.user_ID
JOIN Person pe ON u.user_ID = pe.person_ID
WHERE sd.device_Status = 'Active';

GO
SELECT * FROM ActiveSmartDevices;

/*(2)---- This view provides a summary of faults, including fault details, assigned administrators, and device details.*/
GO
CREATE VIEW FaultNotificationSummary AS
SELECT 
    FN.fault_ID AS FaultID,
    FN.fault_Detail AS FaultDetail,
    D.device_Name AS DeviceName,
    D.device_Type AS DeviceType,
    D.device_Location AS DeviceLocation,
    P.name AS AdminName,
    P.email AS AdminEmail
FROM 
    FaultNotification FN
LEFT JOIN 
    SystemAdmin SA ON FN.admin_ID = SA.admin_ID
LEFT JOIN 
    Person P ON SA.admin_ID = P.person_ID
LEFT JOIN 
    Device D ON D.device_ID IN (
        SELECT device_ID FROM Maintenance WHERE admin_ID = SA.admin_ID
    );
GO
SELECT * FROM FaultNotificationSummary;


/*(3)--Monitor sensor performance and calibration history.*/
GO
CREATE VIEW SensorActivityReport AS
SELECT 
    S.sensor_ID AS SensorID,
    S.sensor_Type AS SensorType,
    S.sensor_Value AS SensorValue,
    S.status AS SensorStatus,
    S.last_Calibrated_Time AS LastCalibrated,
    R.room_Name AS RoomName
FROM 
    Sensor S
LEFT JOIN 
    Room R ON S.room_ID = R.room_ID
WHERE 
    S.status IN ('Active', 'Inactive');

GO
SELECT * FROM SensorActivityReport
ORDER BY LastCalibrated DESC;

/*(4)-- This view provides the user’s devices, their status history, and the last update time.*/
GO
CREATE VIEW UserDeviceHistory AS
SELECT 
    u.user_ID,
    pe.name AS UserName,
    sd.device_Name,
    sd.device_Type,
    sd.device_Status,
    sd.last_Update_Time
FROM 
    [User] u
JOIN 
    Device sd ON u.user_ID = sd.user_ID
JOIN 
    Person pe ON u.user_ID = pe.person_ID

GO
SELECT * FROM UserDeviceHistory;


-- UDF
/*(1)--This function Calculates the Total Energy Consumed by a Device */
GO
CREATE FUNCTION dbo.CalculateTotalEnergyConsumed
(
    @DeviceID INT
)
RETURNS NUMERIC(10, 2)
AS
BEGIN
    DECLARE @TotalEnergy NUMERIC(10, 2);

    -- Sum the total energy consumed for a specific device
    SELECT @TotalEnergy = SUM(E.total_Energy_Consumed)
    FROM EnergyUsage E
    WHERE E.device_ID = @DeviceID;

    -- Return the total energy consumed, or 0 if no energy usage data is found
    RETURN ISNULL(@TotalEnergy, 0);
END;
GO

SELECT dbo.CalculateTotalEnergyConsumed(1) AS TotalEnergyConsumed;


/*(2)--This function returns the number of active devices in a given room.*/
GO
CREATE FUNCTION dbo.GetActiveDevicesCountInRoom
(
    @RoomName VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @ActiveCount INT;

    -- Count the number of active devices in the specified room
    SELECT @ActiveCount = COUNT(*)
    FROM Device D
    WHERE D.device_Location = @RoomName
      AND D.device_Status = 'Active';

    -- Return the active device count
    RETURN ISNULL(@ActiveCount, 0);
END;
GO

SELECT dbo.GetActiveDevicesCountInRoom('Living Room') AS ActiveDevicesCount;

/*(3)--This function calculates the total number of faults reported for a specific device.*/
GO
CREATE FUNCTION dbo.GetTotalFaultsForDevice
(
    @DeviceID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @FaultCount INT;

    -- Count the number of faults related to the device through the Maintenance table
    SELECT @FaultCount = COUNT(*)
    FROM FaultNotification FN
    JOIN Maintenance M ON M.admin_ID = FN.admin_ID
    WHERE M.device_ID = @DeviceID;

    -- Return the total number of faults
    RETURN ISNULL(@FaultCount, 0);
END;
GO

SELECT dbo.GetTotalFaultsForDevice(1) AS TotalFaults;

/*(4)--This function calculates the total duration of a user's subscription in days.*/
GO
CREATE FUNCTION dbo.GetSubscriptionDuration
(
    @UserID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SubscriptionDuration INT;

    -- Calculate the total duration in days from subscription start to end
    SELECT @SubscriptionDuration = DATEDIFF(DAY, start_date, expiration_Date)
    FROM SubscriptionPlan
    WHERE user_ID = @UserID;

    RETURN ISNULL(@SubscriptionDuration, 0);
END;
GO

SELECT dbo.GetSubscriptionDuration(4) AS SubscriptionDuration;


-- trigger
/*(1)--This trigger will insert a new record into the Notification table every time a new device is added to the Device table.*/
GO
CREATE TRIGGER trg_NewDeviceNotification
ON Device
FOR INSERT
AS
BEGIN
    DECLARE @DeviceID INT;
    DECLARE @DeviceName VARCHAR(30);
    DECLARE @UserID INT;

    -- Get the newly inserted device information from the INSERTED virtual table
    SELECT @DeviceID = device_ID, @DeviceName = device_Name, @UserID = user_ID 
    FROM INSERTED;

    -- Insert a new notification for the user
    INSERT INTO Notification (notification_Type, notification_Content, date_and_Time_Sent, status, trigger_Condition, device_ID, user_ID)
    VALUES ('Device Registration', 
            'A new device ' + @DeviceName + ' has been added to your account.',
            GETDATE(),
            'Pending',
            'Device Added',
            @DeviceID,
            @UserID);
END;
GO

INSERT INTO Device (device_Name, device_Type, device_Status, device_Location, energy_Usage, connectivity_Status, last_Update_Time, fault_Status, user_ID)
VALUES ('Smart Light', 'Lighting', 'Active', 'Living Room', 15.5, 'Online', GETDATE(), 'Normal', 6);

SELECT * FROM Notification

/*(2)---- Trigger to update device status and insert notification when fault status changes*/
GO
CREATE TRIGGER trg_UpdateDeviceStatusOnFaultChange
ON Device
FOR UPDATE
AS
BEGIN
    DECLARE @DeviceID INT;
    DECLARE @DeviceName VARCHAR(50);
    DECLARE @UserID INT;
    DECLARE @NewFaultStatus VARCHAR(30);
    DECLARE @OldFaultStatus VARCHAR(30);
    DECLARE @NewDeviceStatus VARCHAR(30);

    -- Get the information for the updated row
    SELECT @DeviceID = device_ID, 
           @DeviceName = device_Name, 
           @UserID = user_ID, 
           @NewFaultStatus = fault_Status
    FROM INSERTED;

    -- Get the old fault status before the update
    SELECT @OldFaultStatus = fault_Status
    FROM DELETED;

    -- Check if the fault status has changed
    IF @NewFaultStatus <> @OldFaultStatus
    BEGIN
        -- If the fault status is 'Critical', update the device status to 'Inactive'
        IF @NewFaultStatus = 'Critical'
        BEGIN
            SET @NewDeviceStatus = 'Inactive';
            -- Update the device status to 'Inactive' due to critical fault
            UPDATE Device
            SET device_Status = @NewDeviceStatus
            WHERE device_ID = @DeviceID;
        END

        -- Insert a notification for the user about the fault status change
        INSERT INTO Notification (notification_Type, notification_Content, date_and_Time_Sent, status, trigger_Condition, device_ID, user_ID)
        VALUES ('Fault Status Change', 
                'The fault status of your device ' + @DeviceName + ' has changed to ' + @NewFaultStatus + '. Device status is now ' + @NewDeviceStatus + '.',
                GETDATE(),
                'Pending',
                'Fault Status Updated',
                @DeviceID,
                @UserID);
    END
END;
GO

UPDATE Device
SET fault_Status = 'Critical'
WHERE device_Name = 'Smart Thermostat';

SELECT device_Name, device_Status, fault_Status
FROM Device
WHERE device_Name = 'Smart Thermostat'

-- to check trigger
SELECT notification_Type, notification_Content, date_and_Time_Sent, status
FROM Notification
WHERE device_ID = (SELECT device_ID FROM Device WHERE device_Name = 'Smart Thermostat');