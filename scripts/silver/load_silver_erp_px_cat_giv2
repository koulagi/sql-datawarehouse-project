-- ===================================================================================
-- Purpose: Cleanse and transform 'bronze.erp_px_cat_giv2' data and load it into the 
--          Silver layer ('silver.erp_px_cat_giv2'). This process acts as a staging 
--          load for product category metadata, preparing the id, category, subcategory, 
--          and maintenance fields for downstream reporting.
-- ===================================================================================

TRUNCATE TABLE silver.erp_px_cat_giv2;

INSERT INTO silver.erp_px_cat_giv2(
	id,cat,subcat,maintainence)

SELECT
	id,
	cat,
	subcat,
	maintainence
FROM bronze.erp_px_cat_giv2
