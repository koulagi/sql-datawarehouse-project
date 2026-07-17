/*
===============================================================================
Script Name: Load Silver CRM Product Information
Description: 
    Cleanses, transforms, and loads raw product data from the bronze landing 
    layer ('bronze.crm_prd_info') into the structured silver layer table.
    
Purpose:
    - Truncates the target silver table to perform a fresh, full load.
    - Standardizes product categories by formatting business keys.
    - Extracts distinct product keys by stripping out metadata prefixes.
    - Implements fallback defaults (0) for missing/null cost values.
    - Maps single-character product lines ('M', 'R', 'T', 'S') to descriptive, 
      human-readable master names.
    - Calculates historical validity date ranges ('prd_end_dt') using a windowed 
      LEAD function minus 1 day to establish an active timeline pattern.

Warnings & Critical Considerations:
    1. DESTRUCTIVE OPERATION: The script begins with a 'TRUNCATE TABLE' statement. 
       This permanently wipes all existing rows in 'silver.crm_prd_info' before 
       the data is re-inserted. Ensure no active analytical queries depend on 
       this table mid-execution.
    2. WINDOW FUNCTION DEPENDENCY: The 'LEAD()' function relies heavily on accurate 
       historical sequences. If 'prd_start_dt' is missing or duplicated within 
       the same 'prd_key' partition, the calculated 'prd_end_dt' timelines will distort.
===============================================================================
*/

-- 1. Empty the target silver layer table (Destructive Operation)
TRUNCATE TABLE silver.crm_prd_info;

-- 2. Transform and re-populate from the bronze landing layer
INSERT INTO silver.crm_prd_info (
    prd_id
    ,prd_cat_id
    ,prd_key
    ,prd_nm
    ,prd_cost
    ,prd_line
    ,prd_start_dt
    ,prd_end_dt
)
SELECT
    prd_id,
    -- Extract category ID from the first 5 characters and standardize hyphens into underscores
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
    -- Extract the true product key by dropping the category prefix (starts at character 7)
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    -- Handle missing costs by defaulting to 0
    ISNULL(prd_cost, 0) AS prd_cost,
    -- Map abbreviated product lines to descriptive operational names
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'T' THEN 'Touring'
         WHEN 'S' THEN 'Other Sales'
         ELSE 'n/a'
    END AS prd_line,
    -- Cast timestamp data fields into standard DATE format
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    -- Generate the historical end-date by evaluating the next chronological record's start-date minus 1 day
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;

/*
===============================================================================
-- DEVELOPER LINEAGE NOTE (Commented Legacy Filter Templates):
-- The following constraints were excluded during development but kept for pipeline auditing.

-- Filter out orphaned categories:
-- WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_') NOT IN (SELECT DISTINCT id from bronze.erp_px_cat_giv2)

-- Filter out keys missing from core sales pipelines:
-- WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM bronze.crm_sales_details WHERE sls_prd_key LIKE 'FK%')
===============================================================================
*/
