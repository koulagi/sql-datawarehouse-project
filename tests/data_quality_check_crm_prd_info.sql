/*
===============================================================================
Script Name: Data Quality Testing - CRM Product Information (Bronze vs. Silver)
Description: 
    This diagnostic script runs automated data profiling and quality assurance 
    checks against both the landing layer (Bronze) and the transformed layer (Silver).
    
Purpose:
    - Validate entity integrity (Nulls/Duplicates on PK).
    - Detect text anomalies (Unwanted leading/trailing whitespaces).
    - Enforce business rules (No negative costs, valid fallback values).
    - Audit domain data consistency (Standardized lookup categories).
    - Monitor historical data integrity (Valid timeline sequence).

Expected Results: 
    All queries should return empty result sets (0 rows), except for the 
    Data Standardization (DISTINCT) queries, which serve as visual audit logs.
===============================================================================
*/

-- ============================================================================
-- PARTITION 1: BRONZE LAYER TESTING (Raw Data Profiling)
-- ============================================================================

--- Test Case 1.1: Primary Key Integrity
--- Purpose: Verify 'prd_id' acts as a reliable unique identifier with no nulls.
SELECT 
    prd_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


--- Test Case 1.2: String Truncation & Whitespace Audit
--- Purpose: Identify fields requiring string manipulation (TRIM) functions.
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


--- Test Case 1.3: Financial Business Rule Violations
--- Purpose: Catch out-of-bound financial inputs and unhandled NULL values.
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0


--- Test Case 2.2: Cleaned Text Verification
--- Purpose: Prove that the Silver transformation layer successfully stripped unwanted whitespaces.
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--- Test Case 2.3: Data Type and Defaulting Enforcement
--- Purpose: Validate that NULL costs were handled (converted to 0) and negatives eliminated.
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0


--- Test Case 2.4: Categorical Mapping Validation
--- Purpose: Verify that raw abbreviated strings (M, R, T, S) successfully mapped to master values.
SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info;


--- Test Case 2.5: Historical Timeline Integrity
--- Purpose: Ensure the LEAD() window function generated mathematically flawless 'prd_end_dt' timelines.
SELECT 
    prd_id,
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
