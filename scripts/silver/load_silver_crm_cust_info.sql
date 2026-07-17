/*
===============================================================================
Script Name:    load_silver_crm_cust_info.sql
Purpose:        Cleanses, normalizes, and deduplicates raw customer profile 
                data from the bronze layer and loads it into the silver layer.

WARNING:        THIS SCRIPT CONTAINS 'TRUNCATE TABLE' STATEMENTS. Running this 
                will PERMANENTLY ERASE all existing data within the target 
                'silver.crm_cust_info' table before reloading. 
                PLEASE ENSURE PROPER BACKUPS ARE IN PLACE BEFORE EXECUTION.

Author:         koulagi
Date:           2026-07-17
===============================================================================
*/
TRUNCATE TABLE silver.crm_cust_info;

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
	--Remove Unwanted Spaces
	--Removes unwanted spaces to ensure data consistency, and uniformity across all records
	
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	--Data Normalization & Standardization
	--Maps code value to meaningful, user-friendly descriptions
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
		--Remove Duplicates
		--Ensure only one record per entity by identifying and retaining the most relevant row.
		SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info 
		WHERE cst_id IS NOT NULL
	)t
--Data Filtering
--Select the most recent record per customer
WHERE flag_last = 1
