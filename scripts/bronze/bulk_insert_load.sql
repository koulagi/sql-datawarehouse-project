-- =================================================================================
-- Script Name: bulk_insert_load.sql
-- Purpose:     Creates or updates a stored procedure that orchestrates the entire
--              data pipeline ingestion for the DataWarehouse 'bronze' schema.
--              It completely refreshes and bulk inserts all CRM and ERP source CSV files.
--              Additionally, a TRY...CATCH block is implemented to gracefully handle 
--              runtime errors, and time tracking metrics are utilized to 
--              calculate and capture the precise execution duration of each table load.
--
-- WARNING:     RUNNING THIS STORED PROCEDURE WILL TRUNCATE (DELETE ALL RECORDS FROM)
--              ALL BRONZE DATA TABLES before performing the bulk insertions. 
--              Ensure you have a backup of the destination tables if you need to 
--              retain old data history.
--
-- Author:      koulagi
-- Date:        2026-07-16
-- =================================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @load_start_time DATETIME, @load_end_time DATETIME;
	BEGIN TRY
		PRINT '==================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==================================================';

		PRINT '--------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------------';

		SET @start_time = GETDATE();
		SET @load_start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		PRINT '--------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.erp_loc_a0101';
		TRUNCATE TABLE bronze.erp_loc_a0101;

		BULK INSERT bronze.erp_loc_a0101
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating and Loading: bronze.erp_px_cat_giv2';
		TRUNCATE TABLE bronze.erp_px_cat_giv2;

		BULK INSERT bronze.erp_px_cat_giv2
		FROM 'C:\Users\supri\Desktop\STUDY\Data Analytics\SQL\sql-data-analytics-project\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='

		PRINT '==================================================';
		PRINT 'Bronze Layer Loading Completed Successfully';
		PRINT '==================================================';
		SET @load_end_time = GETDATE();
		PRINT '>>Complete Tables Load Duration: ' + CAST(DATEDIFF(second, @load_start_time,@load_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================='
	END TRY
	BEGIN CATCH
		PRINT '========================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================='
	END CATCH
END
-- =================================================================================
-- Execution Example
-- =================================================================================
-- Uncomment the line below to immediately run the ingestion routine:
-- EXEC bronze.load_bronze;
-- =================================================================================
