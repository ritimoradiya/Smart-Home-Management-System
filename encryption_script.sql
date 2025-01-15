USE SmartHomeManagement
GO
-- Create a database master key for encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword123!';

-- Create a certificate for encrypting column data
CREATE CERTIFICATE DataEncryptionCert
WITH SUBJECT = 'Data Encryption Certificate';

-- Create a symmetric key for encryption
CREATE SYMMETRIC KEY DataSymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE DataEncryptionCert;

-- Encrypt the `email` column in the Person table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Person' AND COLUMN_NAME = 'email';

ALTER TABLE Person
DROP COLUMN email_encrypted;

ALTER TABLE Person
ADD email_encrypted VARBINARY(MAX);

UPDATE Person
SET email_encrypted = ENCRYPTBYKEY(KEY_GUID('DataSymmetricKey'), email);

UPDATE Person
SET email_encrypted = NULL;

CLOSE SYMMETRIC KEY DataSymmetricKey;

-- Encrypt the `password` column in the Person table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Person' AND COLUMN_NAME = 'password';

ALTER TABLE Person
DROP COLUMN password_encrypted;

ALTER TABLE Person
ADD password_encrypted VARBINARY(MAX);

UPDATE Person
SET password_encrypted = ENCRYPTBYKEY(KEY_GUID('DataSymmetricKey'), password);

CLOSE SYMMETRIC KEY DataSymmetricKey;

-- Encrypt the `payment_Status` column in the SubscriptionPlan table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SubscriptionPlan' AND COLUMN_NAME = 'payment_Status';

ALTER TABLE SubscriptionPlan
ADD payment_Status_Text VARCHAR(255);

UPDATE SubscriptionPlan
SET payment_Status_Text = CONVERT(VARCHAR(MAX), DECRYPTBYKEY(payment_Status));

UPDATE SubscriptionPlan
SET payment_Status = ENCRYPTBYKEY(KEY_GUID('DataSymmetricKey'), payment_Status);

CLOSE SYMMETRIC KEY DataSymmetricKey;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Notification' AND COLUMN_NAME = 'notification_Content';

ALTER TABLE Notification
ALTER COLUMN notification_Content VARCHAR(500);

UPDATE Notification
SET notification_Content = LEFT('The fault status of your device Smart Thermostat has changed to Critical. Device status is now Inact', 255); 



/*Output*/




-- Decrypt and view the `email` column in the Person table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT 
    person_ID, 
    CONVERT(VARCHAR, DECRYPTBYKEY(email)) AS DecryptedEmail
FROM 
    Person;

CLOSE SYMMETRIC KEY DataSymmetricKey;

-- Decrypt and view the `password` column in the Person table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT 
    person_ID, 
    CONVERT(VARCHAR, DECRYPTBYKEY(password)) AS DecryptedPassword
FROM 
    Person;

CLOSE SYMMETRIC KEY DataSymmetricKey;

-- Decrypt and view the `payment_Status` column in the SubscriptionPlan table
OPEN SYMMETRIC KEY DataSymmetricKey
DECRYPTION BY CERTIFICATE DataEncryptionCert;

SELECT 
    plan_ID, 
    CONVERT(VARCHAR, DECRYPTBYKEY(payment_Status)) AS DecryptedPaymentStatus
FROM 
    SubscriptionPlan;

CLOSE SYMMETRIC KEY DataSymmetricKey;
