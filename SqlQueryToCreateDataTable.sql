-- ====================================================================
-- 1. Create Database
-- ====================================================================
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'customer_churn')
BEGIN
    CREATE DATABASE customer_churn;
END
GO

USE customer_churn;
GO

-- ====================================================================
-- 2. Create Tables
-- ====================================================================
IF OBJECT_ID('db_support', 'U') IS NOT NULL DROP TABLE db_support;
IF OBJECT_ID('db_subscription', 'U') IS NOT NULL DROP TABLE db_subscription;
IF OBJECT_ID('db_customer', 'U') IS NOT NULL DROP TABLE db_customer;

CREATE TABLE db_customer (
    customerid VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50), 
    state VARCHAR(50),
    gender VARCHAR(20),
    dob VARCHAR(50) NOT NULL,
    interests VARCHAR(200),
    pincode VARCHAR(15)
);

CREATE TABLE db_subscription (
    customerid VARCHAR(20) PRIMARY KEY FOREIGN KEY REFERENCES db_customer(customerid),
    subscription_start_date VARCHAR(50) NOT NULL,
    subscription_type VARCHAR(50) NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    renewal_date VARCHAR(50) NOT NULL,
    cancellation_date VARCHAR(50), 
    cancellation_reason VARCHAR(100), 
    monthly_charges DECIMAL(10,2) NOT NULL,
    cltv DECIMAL(10,2) NOT NULL,
    churn_score INT NOT NULL
);

CREATE TABLE db_support (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY, 
    customerid VARCHAR(20) FOREIGN KEY REFERENCES db_customer(customerid),
    complaint_date VARCHAR(50) NOT NULL,
    escalations VARCHAR(5) NOT NULL,
    csat_score DECIMAL(5,2)
);
GO

-- ====================================================================
-- 3. Populate Data (500 Customers)
-- ====================================================================
SET NOCOUNT ON;
DECLARE @i INT = 1;
DECLARE @customerid VARCHAR(20), @name VARCHAR(100), @country VARCHAR(50), @state VARCHAR(50), 
        @hidden_state VARCHAR(50), 
        @gender VARCHAR(20), @dob DATETIME, @interests VARCHAR(200), @pincode VARCHAR(15);

DECLARE @r_fname INT, @r_lname INT, @r_country INT, @r_state_null INT, @r_state_in INT, 
        @r_state_np INT, @r_state_oth INT, @r_gender INT, @r_interest INT;

WHILE @i <= 500
BEGIN
    SET @r_fname = ABS(CHECKSUM(NEWID())) % 20 + 1;
    SET @r_lname = ABS(CHECKSUM(NEWID())) % 20 + 1;
    SET @r_country = ABS(CHECKSUM(NEWID())) % 10;
    SET @r_state_null = ABS(CHECKSUM(NEWID())) % 100;
    SET @r_state_in = ABS(CHECKSUM(NEWID())) % 15 + 1;
    SET @r_state_np = ABS(CHECKSUM(NEWID())) % 8 + 1;
    SET @r_state_oth = ABS(CHECKSUM(NEWID())) % 6 + 1;
    SET @r_gender = ABS(CHECKSUM(NEWID())) % 4 + 1;
    SET @r_interest = ABS(CHECKSUM(NEWID())) % 4 + 1;

    SET @customerid = RIGHT('0000' + CAST(@i AS VARCHAR), 4) + '-' + 
                      CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
                      CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
                      CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65);

    SET @name = CHOOSE(@r_fname, 'Ruhul', 'Amit', 'Priya', 'Sarah', 'John', 'Anjali', 'Rahul', 'Vikram', 'Neha', 'Sanjay', 'Pooja', 'Ravi', 'Kiran', 'Aisha', 'Rohan', 'Sneha', 'Arjun', 'Sunita', 'Gaurav', 'Kavita') + ' ' + 
                CHOOSE(@r_lname, 'Yadav', 'Sharma', 'Smith', 'Thapa', 'Singh', 'Patel', 'Kumar', 'Gupta', 'Joshi', 'Lama', 'Maharjan', 'Chaudhary', 'Shrestha', 'Karki', 'Adhikari', 'Gurung', 'Rai', 'Tamang', 'Magar', 'Shah');

    SET @country = CASE WHEN @r_country < 4 THEN 'India' 
                        WHEN @r_country < 8 THEN 'Nepal' 
                        ELSE NULL END;

    IF @r_state_null < 30
    BEGIN
        SET @state = NULL; 
        IF @country = 'India' OR @country IS NULL SET @hidden_state = CHOOSE(@r_state_in, 'Gujarat', 'Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu', 'West Bengal', 'Rajasthan', 'Punjab', 'Uttar Pradesh', 'Kerala', 'Assam', 'Bihar', 'Odisha', 'Madhya Pradesh', 'Telangana');
        ELSE SET @hidden_state = CHOOSE(@r_state_np, 'Kathmandu', 'Bagmati', 'Gandaki', 'Lumbini', 'Madhesh', 'Koshi', 'Karnali', 'Sudurpashchim');
    END
    ELSE IF @country = 'India'
    BEGIN
        SET @state = CHOOSE(@r_state_in, 'Gujarat', 'Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu', 'West Bengal', 'Rajasthan', 'Punjab', 'Uttar Pradesh', 'Kerala', 'Assam', 'Bihar', 'Odisha', 'Madhya Pradesh', 'Telangana');
        SET @hidden_state = @state;
    END
    ELSE IF @country = 'Nepal'
    BEGIN
        SET @state = CHOOSE(@r_state_np, 'Kathmandu', 'Bagmati', 'Gandaki', 'Lumbini', 'Madhesh', 'Koshi', 'Karnali', 'Sudurpashchim');
        SET @hidden_state = @state;
    END
    ELSE 
    BEGIN
        SET @state = CHOOSE(@r_state_oth, 'Karnataka', 'Gandaki', 'Delhi', 'Koshi', 'Assam', 'Bagmati');
        SET @hidden_state = @state;
    END

    SET @pincode = CASE 
        WHEN @hidden_state = 'Delhi' THEN '110' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Punjab' THEN '144' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Uttar Pradesh' THEN '226' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Rajasthan' THEN '302' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Gujarat' THEN '395' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Maharashtra' THEN '400' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Madhya Pradesh' THEN '462' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Telangana' THEN '500' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Karnataka' THEN '560' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Tamil Nadu' THEN '600' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Kerala' THEN '695' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'West Bengal' THEN '700' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Odisha' THEN '751' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Assam' THEN '781' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        WHEN @hidden_state = 'Bihar' THEN '800' + RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR), 3)
        
        WHEN @hidden_state = 'Kathmandu' THEN '446' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Bagmati' THEN '447' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Madhesh' THEN '443' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Gandaki' THEN '337' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Lumbini' THEN '329' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Koshi' THEN '567' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Karnali' THEN '212' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        WHEN @hidden_state = 'Sudurpashchim' THEN '109' + RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR), 2)
        
        ELSE CAST(ABS(CHECKSUM(NEWID())) % 899999 + 100000 AS VARCHAR(6))
    END;

    SET @gender = CHOOSE(@r_gender, 'Male', 'Female', 'Men', 'Women');
    SET @dob = DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 12775), '2005-12-31');
    SET @interests = CHOOSE(@r_interest, 'Movies, Sports', 'Web Series', 'Documentaries, Live TV', 'Sports');

    INSERT INTO db_customer (customerid, name, country, state, gender, dob, interests, pincode)
    VALUES (@customerid, @name, @country, @state, @gender, @dob, @interests, @pincode);

    SET @i = @i + 1;
END
GO

-- ====================================================================
-- 4. Populate Subscriptions
-- ====================================================================
INSERT INTO db_subscription 
(customerid, subscription_start_date, subscription_type, plan_type, contract_type, renewal_date, cancellation_date, cancellation_reason, monthly_charges, cltv, churn_score)
SELECT 
    customerid,
    DATEADD(DAY, -(ABS(CHECKSUM(customerid + 'date1')) % 1095), GETDATE()) AS subscription_start_date,
    CHOOSE(ABS(CHECKSUM(customerid + 'sub')) % 3 + 1, 'Refferal', 'Paid', 'Organic') AS subscription_type,
    CHOOSE(ABS(CHECKSUM(customerid + 'plan')) % 3 + 1, 'standard', 'premium', 'basic') AS plan_type,
    CHOOSE(ABS(CHECKSUM(customerid + 'cont')) % 2 + 1, 'Monthly', 'Annually') AS contract_type,
    DATEADD(DAY, ABS(CHECKSUM(customerid + 'date2')) % 365, GETDATE()) AS renewal_date,
    CASE WHEN ABS(CHECKSUM(customerid + 'churn')) % 100 < 30 
         THEN DATEADD(DAY, -(ABS(CHECKSUM(customerid + 'date3')) % 100 + 1), GETDATE()) 
         ELSE NULL END AS cancellation_date,
    NULL AS cancellation_reason,
    CAST((ABS(CHECKSUM(customerid + 'charge')) % 20 + 9.99) AS DECIMAL(10,2)) AS monthly_charges,
    CAST((ABS(CHECKSUM(customerid + 'cltv')) % 1500 + 100.00) AS DECIMAL(10,2)) AS cltv,
    ABS(CHECKSUM(customerid + 'score')) % 100 + 1 AS churn_score
FROM db_customer;

UPDATE db_subscription
SET cancellation_reason = CHOOSE(ABS(CHECKSUM(customerid + 'reason')) % 3 + 1, 'Switched to competitor', 'Too expensive', 'Content fatigue')
WHERE cancellation_date IS NOT NULL;
GO

-- ====================================================================
-- 5. Populate Support Tickets (Corrected Date Casting)
-- ====================================================================
-- Block 1: Tickets for Cancelled Users
INSERT INTO db_support (customerid, complaint_date, escalations, csat_score)
SELECT 
    sub.customerid,
    -- Explicitly cast the VARCHAR cancellation_date to DATETIME so DATEADD works
    DATEADD(DAY, -(ABS(CHECKSUM(sub.customerid + 'c_date')) % 60 + 1), CAST(sub.cancellation_date AS DATETIME)) AS complaint_date,
    CASE WHEN ABS(CHECKSUM(sub.customerid + 'c_esc')) % 100 < 80 THEN 'Y' ELSE 'N' END AS escalations,
    ABS(CHECKSUM(sub.customerid + 'c_csat')) % 3 + 1 AS csat_score
FROM db_subscription sub
WHERE sub.cancellation_date IS NOT NULL;

-- Block 2: Tickets for Active Users (Uses GETDATE, no cast needed)
INSERT INTO db_support (customerid, complaint_date, escalations, csat_score)
SELECT 
    sub.customerid,
    DATEADD(DAY, -(ABS(CHECKSUM(sub.customerid + 'a_date')) % 300), GETDATE()) AS complaint_date,
    CASE WHEN ABS(CHECKSUM(sub.customerid + 'a_esc')) % 100 < 5 THEN 'Y' ELSE 'N' END AS escalations,
    ABS(CHECKSUM(sub.customerid + 'a_csat')) % 3 + 3 AS csat_score
FROM db_subscription sub
WHERE sub.cancellation_date IS NULL
  AND ABS(CHECKSUM(sub.customerid + 'a_ticket')) % 100 < 40;

-- Block 3: Duplicate Tickets for Cancelled Users
INSERT INTO db_support (customerid, complaint_date, escalations, csat_score)
SELECT 
    sub.customerid,
    DATEADD(DAY, -(ABS(CHECKSUM(sub.customerid + 'dup_date')) % 10 + 1), CAST(sub.cancellation_date AS DATETIME)) AS complaint_date,
    'Y' AS escalations,
    1 AS csat_score
FROM db_subscription sub
WHERE sub.cancellation_date IS NOT NULL
  AND ABS(CHECKSUM(sub.customerid + 'dup_ticket')) % 100 < 50;
GO

-- ====================================================================
-- 6a. Adjust Churn Score for Cancelled + Escalated Users
-- ====================================================================
-- Assigns a churn_score between 71 and 100
UPDATE db_subscription
SET churn_score = 71 + (ABS(CHECKSUM(NEWID())) % 30)
WHERE cancellation_date IS NOT NULL
  AND customerid IN (
      SELECT customerid FROM db_support WHERE escalations = 'Y'
  );
GO

-- ====================================================================
-- 6b. Adjust Churn Score for "At Risk" Users (Escalated but Active)
-- ====================================================================
-- Assigns a churn_score between 51 and 69
UPDATE db_subscription
SET churn_score = 51 + (ABS(CHECKSUM(NEWID())) % 19)
WHERE cancellation_date IS NULL
  AND customerid IN (
      SELECT customerid FROM db_support WHERE escalations = 'Y'
  );
GO

-- ====================================================================
-- 7. Adjust Churn Score for Happy/Un-escalated Users
-- ====================================================================
-- Sets churn_score to a low random value (1-30) 
UPDATE db_subscription
SET churn_score = ABS(CHECKSUM(NEWID())) % 30 + 1 
WHERE customerid NOT IN (
    SELECT customerid FROM db_support WHERE escalations = 'Y'
);
GO