/*
===============================================================================
Script Name:    quality_checks_crm_cust_info.sql
Purpose:        Performs Comprehensive Data Quality (DQ) checks and profiling 
                on both the 'bronze' staging layer and 'silver' cleansed layer.
                
                - Bronze Checks: Identify data anomalies, hidden spaces, missing 
                  primary keys, and code variations in raw source data.
                - Silver Checks: Validate that the ETL transformation pipeline 
                  successfully deduplicated records, trimmed fields, and 
                  standardized demographic attributes.

WARNING:        READ-ONLY SCRIPT. This script contains only diagnostic queries 
                and will not alter, drop, or delete data within the database.

Author:         koulagi
Date:           2026-07-17
===============================================================================
*/

USE DataWarehouse;
GO

PRINT '===============================================================================';
PRINT 'STARTING DATA QUALITY PIPELINE CHECKS';
PRINT '===============================================================================';
GO

-- ============================================================================
-- LAYER 1: BRONZE SCHEMA VALIDATIONS (RAW DATA PROFILE)
-- ============================================================================
PRINT '-------------------------------------------------------------------------------';
PRINT 'Running Quality Checks on: bronze.crm_cust_info';
PRINT '-------------------------------------------------------------------------------';
GO

---CHECK For NULLS or Duplicates in Primary Key
--Expectation : No Result

SELECT 
cst_id,
COUNT(*) as count_of_customers
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--Check unwanted spaces for firstname
--Expectation No Result
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--Check unwanted spaces for lastname
--Expectation No Result
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--Check unwanted spaces for material status
--Expectation No Result
SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)

--Check unwanted spaces for gender
--Expectation No Result
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

SELECT * FROM bronze.crm_cust_info
GO


-- ============================================================================
-- LAYER 2: SILVER SCHEMA VALIDATIONS (CLEANSED & CONFORMED VERIFICATION)
-- ============================================================================
PRINT '-------------------------------------------------------------------------------';
PRINT 'Running Quality Checks on: silver.crm_cust_info';
PRINT '-------------------------------------------------------------------------------';
GO

---CHECK For NULLS or Duplicates in Primary Key
--Expectation : No Result

SELECT 
cst_id,
COUNT(*) as count_of_customers
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--Check unwanted spaces for firstname
--Expectation No Result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

--Check unwanted spaces for lastname
--Expectation No Result
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--Check unwanted spaces for material status
--Expectation No Result
SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)

--Check unwanted spaces for gender
--Expectation No Result
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info
GO

PRINT '===============================================================================';
PRINT 'DATA QUALITY PIPELINE CHECKS COMPLETED';
PRINT '===============================================================================';
GO
