-- =====================================================
-- INVENTORY ANALYSIS PROJECT (SQL SERVER)
-- Author: Mehtab
-- Description: End-to-end SQL pipeline with test and production environments
-- =====================================================

-- =====================================================
-- 1. CREATE TEST ENVIRONMENT
-- =====================================================
CREATE DATABASE test_env;
GO

USE test_env;
GO

-- =====================================================
-- 2. VIEW RAW DATA
-- =====================================================
SELECT * FROM [dbo].[Products];

SELECT * FROM [dbo].[Test+Environment+Inventory+Dataset];

-- Check unique demand values
SELECT DISTINCT Demand 
FROM [dbo].[Test+Environment+Inventory+Dataset];

-- =====================================================
-- 3. DATA TRANSFORMATION (JOIN PRODUCTS + INVENTORY)
-- =====================================================
SELECT 
    a.Order_Date_DD_MM_YYYY,
    a.Product_ID,
    a.Availability,
    a.Demand,
    b.Product_Name,
    b.Unit_Price
FROM [dbo].[Test+Environment+Inventory+Dataset] AS a
LEFT JOIN [dbo].[Products] AS b
    ON a.Product_ID = b.Product_ID;

-- =====================================================
-- 4. CREATE ANALYTICAL TABLE (TEST ENV)
-- =====================================================
SELECT * 
INTO New_Table
FROM (
    SELECT 
        a.Order_Date_DD_MM_YYYY,
        a.Product_ID,
        a.Availability,
        a.Demand,
        b.Product_Name,
        b.Unit_Price
    FROM [dbo].[Test+Environment+Inventory+Dataset] AS a
    LEFT JOIN [dbo].[Products] AS b
        ON a.Product_ID = b.Product_ID
) AS x;

-- Verify table
SELECT * FROM New_Table;

-- =====================================================
-- 5. CREATE PRODUCTION ENVIRONMENT
-- =====================================================
CREATE DATABASE PROD;
GO

USE PROD;
GO

-- =====================================================
-- 6. DATA VALIDATION (PRODUCTION)
-- =====================================================

-- Check invalid Product IDs
SELECT DISTINCT Product_ID 
FROM [dbo].[Prod+Env+Inventory+Dataset];

-- Check NULL or empty dates
SELECT DISTINCT Order_Date_DD_MM_YYYY
FROM [dbo].[Prod+Env+Inventory+Dataset]
WHERE Order_Date_DD_MM_YYYY IS NULL 
   OR Order_Date_DD_MM_YYYY = '';

-- =====================================================
-- 7. DATA CLEANING (PRODUCTION)
-- =====================================================

-- Fix incorrect Product IDs
UPDATE [dbo].[Prod+Env+Inventory+Dataset]
SET Product_ID = 7
WHERE Product_ID = 21;

UPDATE [dbo].[Prod+Env+Inventory+Dataset]
SET Product_ID = 11
WHERE Product_ID = 22;

-- =====================================================
-- 8. CREATE FINAL ANALYTICAL TABLE (PRODUCTION)
-- =====================================================
SELECT * 
INTO New_Table
FROM (
    SELECT 
        a.Order_Date_DD_MM_YYYY,
        a.Product_ID,
        a.Availability,
        a.Demand,
        b.Product_Name,
        b.Unit_Price
    FROM [dbo].[Prod+Env+Inventory+Dataset] AS a
    LEFT JOIN [dbo].[Products] AS b
        ON a.Product_ID = b.Product_ID
) AS x;

-- Verify final dataset
SELECT * FROM New_Table;

-- =====================================================
-- 9. DERIVED METRICS (BUSINESS INSIGHTS)
-- =====================================================
SELECT *,
    (Availability - Demand) AS Supply_Shortage,
    (Demand * Unit_Price) AS Revenue,
    ((Availability - Demand) * Unit_Price) AS Profit_Loss
FROM New_Table;

-- =====================================================
-- END OF PROJECT
-- =====================================================