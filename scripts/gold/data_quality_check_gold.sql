-- ===================================================================================
-- Purpose: Quality Assurance (QA) and Data Validation Script for the Gold Layer.
--          This script executes data quality checks to verify the integrity of the 
--          Star Schema. It ensures correct cross-system consolidation of genders, 
--          checks data availability across dimensions, and validates referential 
--          integrity between the Fact table and Dimension tables.
-- ===================================================================================

/*
===============================================================================
1. Gender Consolidation QA
Verify cross-system source mappings (CRM vs. ERP) and cross-check the final 
output inside the gold dimension table.
===============================================================================
*/

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the master for gender Info
		 ELSE COALESCE(ca.gen,'n/a')
	END new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a0101 AS la
ON ci.cst_key = la.cid
ORDER BY 1,2 

SELECT DISTINCT gender FROM gold.dim_customers


/*
===============================================================================
2. Dimension and Fact Base Checks
Inspect available records and columns inside the dimension and fact views.
===============================================================================
*/

SELECT * FROM gold.dim_products

SELECT * FROM gold.fact_sales


/*
===============================================================================
3. Referential Integrity (Orphan Record Identification)
Validate that all sales records successfully map to a corresponding customer 
and product surrogate key. Any rows returned here represent a broken relationship.
===============================================================================
*/

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL
