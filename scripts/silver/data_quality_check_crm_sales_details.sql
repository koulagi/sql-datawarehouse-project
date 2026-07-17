/*
===============================================================================
Script Name: Data Quality Testing - CRM Sales Details (Bronze vs. Silver)
Description: 
    This diagnostic script executes automated data profiling and quality checks 
    against transactional data in both the landing (Bronze) and core (Silver) layers.
    
Purpose:
    - Audit text anomalies (unwanted leading/trailing whitespaces in order IDs).
    - Validate date limits and structure anomalies (length, upper/lower date boundaries).
    - Track relational chronology breaks (order dates falling after shipping/due dates).
    - Monitor core commercial math invariants (Sales = Quantity × Price) and 
      flag invalid numerical indicators (nulls, zeroes, negatives).

Expected Results: 
    For a fully cleaned target layer, all Silver testing queries should return 
    empty result sets (0 rows), validating the success of pipeline transformations.
===============================================================================
*/

-- ============================================================================
-- PARTITION 1: BRONZE LAYER TESTING (Raw Data Profiling & Business Rule Audits)
-- ============================================================================

-- Check for Unwanted Spaces in Order Numbers
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for Invalid Order Days
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19900101

-- Check for Invalid Ship Days
SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19900101

-- Check for Invalid Due Days
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101 
OR sls_due_dt < 19900101

-- Check For Invalid Date Orders
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Buisness Rules Sales = Quantity * Price
-- Negative, zeroes, Nulls are Not Allowed
-- Rules
-- Rule 1: If Sales is negative, zero, or null. Derive it using Quantity and Price
-- Rule 2: If Prices is zero or null, calculate it using Sales and Quantity
---------- If Price is negative, convert it to positive value
SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price
/*CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE
	 sls_sales
END AS sls_sales,

CASE WHEN sls_price is NULL OR sls_price <= 0
	 THEN sls_sales/NULLIF(sls_quantity,0)
	 ELSE sls_price
END AS sls_price*/

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,sls_quantity, sls_price


-- Baseline Full Table Inspection (Bronze)
SELECT * FROM bronze.crm_sales_details


-- ============================================================================
-- PARTITION 2: SILVER LAYER TESTING (Post-Transformation Quality Assurance)
-- ============================================================================

-- Check for Unwanted Spaces in Standardised Order Numbers
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check For Invalid Date Orders in Cleaned Timelines
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Verify Enforcement of Business Rules on Sales, Quantities, and Prices
SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,sls_quantity, sls_price

-- Final Reference Inspection (Bronze Baseline Check)
SELECT * FROM bronze.crm_sales_details
