-- =================================================================================
-- Script Name: load_bronze_layer.sql
-- Purpose:     Creates or updates a stored procedure that orchestrates the entire
--              data pipeline ingestion for the DataWarehouse 'bronze' schema.
--              It completely refreshes and bulk inserts all CRM and ERP source CSV files.
--
-- WARNING:     RUNNING THIS STORED PROCEDURE WILL TRUNCATE (DELETE ALL RECORDS FROM)
--              ALL BRONZE DATA TABLES before performing the bulk insertions. 
--              Ensure you have a backup of the destination tables if you need to 
--              retain old data history.
--
-- Author:      [Your Name / GitHub Username]
-- Date:        2026-07-16
-- =================================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- SET NOCOUNT ON prevents the sending of DONE_IN_PROC messages to the client for each statement.
    SET NOCOUNT ON;

    -- Note: SQL Server BULK INSERT statement requires literal string paths. 
    -- If deploying dynamically, consider replacing these placeholders via your 
    -- deployment/CI-CD pipeline tool (e.g., Python, PowerShell, or GitHub Actions).

    -- =============================================================================
    -- Section 1: Ingesting CRM Source Files
    -- =============================================================================

    -- Table: bronze.crm_cust_info
    PRINT '>> Truncating and loading: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;
	BULK INSERT bronze.crm_cust_info
	FROM '{{DATASET_PATH_CRM}}\cust_info.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    -- Table: bronze.crm_prd_info
    PRINT '>> Truncating and loading: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;
	BULK INSERT bronze.crm_prd_info
	FROM '{{DATASET_PATH_CRM}}\prd_info.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    -- Table: bronze.crm_sales_details
    PRINT '>> Truncating and loading: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	BULK INSERT bronze.crm_sales_details
	FROM '{{DATASET_PATH_CRM}}\sales_details.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    -- =============================================================================
    -- Section 2: Ingesting ERP Source Files
    -- =============================================================================

    -- Table: bronze.erp_cust_az12
    PRINT '>> Truncating and loading: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;
	BULK INSERT bronze.erp_cust_az12
	FROM '{{DATASET_PATH_ERP}}\CUST_AZ12.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    -- Table: bronze.erp_loc_a0101
    PRINT '>> Truncating and loading: bronze.erp_loc_a0101';
	TRUNCATE TABLE bronze.erp_loc_a0101;
	BULK INSERT bronze.erp_loc_a0101
	FROM '{{DATASET_PATH_ERP}}\LOC_A101.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    -- Table: bronze.erp_px_cat_giv2
    PRINT '>> Truncating and loading: bronze.erp_px_cat_giv2';
	TRUNCATE TABLE bronze.erp_px_cat_giv2;
	BULK INSERT bronze.erp_px_cat_giv2
	FROM '{{DATASET_PATH_ERP}}\PX_CAT_G1V2.csv' -- Placeholder for hidden local path
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

    PRINT 'Bronze layer ingestion successfully completed.';
END
GO

-- =================================================================================
-- Execution Example
-- =================================================================================
-- Uncomment the line below to immediately run the ingestion routine:
-- EXEC bronze.load_bronze;
-- =================================================================================
