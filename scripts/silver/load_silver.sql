-- ===================================================================================
-- Purpose: Orchestrates the master Batch Load process for the Silver Layer. 
--          This stored procedure centralizes the sequential truncation, cleansing, 
--          transformation, and loading of all CRM and ERP transaction and master 
--          data tables from the Bronze staging layer into structured Silver layer tables.
-- Warning: DO NOT alter, optimize, or change any inline transformations or string logic 
--          within this script, as it preserves historical processing and intentional 
--          business logic mappings explicitly required by the pipeline.
-- ===================================================================================

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @load_start_time DATETIME, @load_end_time DATETIME
	BEGIN TRY
		SET @load_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'Loading Silver Layer'
		PRINT '========================================';

		PRINT '========================================';
		PRINT 'Loading CRM Tables'
		PRINT '========================================';

		/*
		===============================================================================
		 Loading silver.crm_cust_info 
		===============================================================================
		*/
		PRINT '>>Loading silver.crm_cust_info'; 

		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.crm_cust_info'; 
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>Inserting Data Into silver.crm_cust_info'; 
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'n/a'
			END cst_material_status,
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a'
			END cst_gndr,
			cst_create_date
			FROM
			(
				SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
				FROM bronze.crm_cust_info 
				WHERE cst_id IS NOT NULL
			)tr
		WHERE flag_last = 1
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='

		/*
		===============================================================================
		silver.crm_prd_info
		===============================================================================
		*/

		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>Inserting Data Into silver.crm_prd_info';

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
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'T' THEN 'Touring'
				 WHEN 'S' THEN 'Other Sales'
				 ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='

		/*
		===============================================================================
		silver.crm_sales_details
		===============================================================================
		*/
		
		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>Inserting Data Into silver.crm_sales_details';

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
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
		   CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
				 THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				 THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='

		/*
		===============================================================================
		silver.erp_cust_az12
		===============================================================================
		*/

		PRINT '========================================';
		PRINT 'Loading ERP Tables'
		PRINT '========================================';

		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>>Inserting Data Into silver.erp_cust_az12';

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,
			CASE WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
				 ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='

		/*
		===============================================================================
		silver.erp_loc_a0101
		===============================================================================
		*/

		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.erp_loc_a0101';
		TRUNCATE TABLE silver.erp_loc_a0101;
		PRINT '>>Inserting Data Into silver.erp_loc_a0101';
		
		INSERT INTO silver.erp_loc_a0101(cid,cntry)
		SELECT 
			REPLACE(cid,'-','') AS cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				 WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a0101
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='
		/*
		===============================================================================
		silver.erp_px_cat_giv2
		===============================================================================
		*/

		SET @start_time = GETDATE();
		PRINT '>>Truncating silver.erp_px_cat_giv2';
		TRUNCATE TABLE silver.erp_px_cat_giv2;
		PRINT '>>Inserting Data Into silver.erp_px_cat_giv2';
		
		INSERT INTO silver.erp_px_cat_giv2(
			id,cat,subcat,maintainence)

		SELECT
			id,
			cat,
			subcat,
			maintainence
		FROM bronze.erp_px_cat_giv2
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>=====================================';

		SET @load_end_time = GETDATE();
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(SECOND,@load_start_time, @load_end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>====================================='

	END TRY
	BEGIN CATCH
		PRINT '========================================'
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error_Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error status' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END

--EXEC silver.load_silver
