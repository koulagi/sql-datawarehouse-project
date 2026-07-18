-- ===================================================================================
-- Purpose: Cleanse and transform 'bronze.erp_cust_az12' data and load it into the 
--          Silver layer ('silver.erp_cust_az12'). This process standardizes customer 
--          IDs by removing prefixes, handles out-of-range birth dates, and normalizes 
--          gender values.
-- ===================================================================================

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12(
	cid,
	bdate,
	gen
)
SELECT
	--Remove 'NAS' Prefix if present
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	--Set Future BirthDates to NULL
	CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
	END AS bdate,
	--Normalize gender values and handle unknown cases
	CASE WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM bronze.erp_cust_az12
