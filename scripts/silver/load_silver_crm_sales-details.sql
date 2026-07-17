/*
===============================================================================
Script Name: Load Silver CRM Sales Details Information
Description: 
    Cleanses, transforms, and loads raw transactional data from the bronze 
    landing layer ('bronze.crm_sales_details') into the structured silver layer.
    
Purpose:
    - Truncates the target silver table to perform a clean, full refresh.
    - Sanitizes integer-based dates (YYYYMMDD) and handles invalid lengths or values.
    - Automatically repairs mathematical mismatches between sales, quantities, and prices.
    - Drives backward-calculated unit prices where data is missing, using safe-division logic.

Warnings & Critical Considerations:
    1. DESTRUCTIVE OPERATION: Truncates 'silver.crm_sales_details' before insertion.
    2. FIXED COLUMN MISMATCH: Your original script used 'sls_ship_dt' twice in the 
       SELECT block aliases. The second one was changed to 'sls_ship_dt' to match the INSERT list.
    3. FIXED DATE RULE BUG: The rule evaluating 'sls_due_dt' accidentally checked 
       'sls_ship_dt <= 0'. This was corrected to check 'sls_due_dt <= 0' to avoid broken timelines.
===============================================================================
*/

-- ============================================================================
-- STEP 1: Empty Target Silver Layer Table (Destructive Refresh)
-- ============================================================================
TRUNCATE TABLE silver.crm_sales_details;


-- ============================================================================
-- STEP 2: Transform Data and Populate Target Table
-- ============================================================================
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    -- Pass-through core operational keys and attributes
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Transformation 1: Sanitize and standardise Order Date (YYYYMMDD -> DATE)
    CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    -- Transformation 2: Sanitize and standardise Ship Date (YYYYMMDD -> DATE)
    -- FIX: Changed original alias from 'sls_due_dt' to 'sls_ship_dt' to match destination order.
    CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    -- Transformation 3: Sanitize and standardise Due Date (YYYYMMDD -> DATE)
    -- FIX: Evaluates 'sls_due_dt' thresholds instead of incorrectly evaluating 'sls_ship_dt'.
    CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    -- Transformation 4: Enforce Sales Integrity
    -- Recalculates gross sales totals if values are negative, missing, or mathematically wrong.
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END AS sls_sales,

    -- Pass-through inventory metrics
    sls_quantity,

    -- Transformation 5: Enforce Unit Price Integrity
    -- Derives pricing backward from sales if missing/invalid, safely isolated against divide-by-zero crashes.
    CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details;
