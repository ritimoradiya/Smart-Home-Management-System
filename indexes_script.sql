USE SmartHomeManagement
GO
-- Index for the Person table
CREATE NONCLUSTERED INDEX IDX_Person_Email
ON Person (email);

-- Index for the Device table
CREATE NONCLUSTERED INDEX IDX_Device_Status
ON Device (device_Status);

-- Index for the SubscriptionPlan table
CREATE NONCLUSTERED INDEX IDX_SubscriptionPlan_PaymentStatusText
ON SubscriptionPlan(payment_Status_Text);

-- Index for the Maintenance table
CREATE NONCLUSTERED INDEX IDX_Maintenance_FaultType
ON Maintenance (fault_Type);

-- Index for the Notification table
CREATE NONCLUSTERED INDEX IDX_Notification_Status
ON Notification (status);

-- Index for the EnergyUsage table
CREATE NONCLUSTERED INDEX IDX_EnergyUsage_StartTime_EndTime
ON EnergyUsage (start_Time, end_Time);


-- View all indexes created on tables
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName
FROM 
    sys.indexes i
JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE 
    i.is_primary_key = 0 AND i.is_unique = 0
ORDER BY 
    TableName, IndexName;
