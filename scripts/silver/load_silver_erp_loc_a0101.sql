-- ===================================================================================
-- Purpose: Cleanse and transform 'bronze.erp_loc_a0101' data and load it into the 
--          Silver layer ('silver.erp_loc_a0101'). This process normalizes customer 
--          IDs by removing hyphens and standardizes country codes into their full 
--          country names while handling missing or empty values.
-- ===================================================================================

TRUNCATE TABLE silver.erp_loc_a0101;
INSERT INTO silver.erp_loc_a0101(cid,cntry)
SELECT 
	REPLACE(cid,'-','') AS cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		 WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a0101
