/*
=================================================================================
-- Script Name: create_bronze_tables.sql
-- Purpose:     Initializes the 'bronze' schema tables within the DataWarehouse.
--              This script is responsible for setting up the raw ingestion layer
--              for CRM and ERP source data.
--
-- WARNING:     THIS SCRIPT CONTAINS 'DROP TABLE' STATEMENTS. Running this will 
--              PERMANENTLY DELETE any existing tables and data within the 
--              'bronze' schema for the specified objects. 
--              PLEASE BACK UP YOUR DATA BEFORE EXECUTING THIS SCRIPT.
--
-- Author:      koulagi
-- Date:        2026-07-16
=================================================================================
*/

-- Switch context to the target data warehouse database
USE DataWarehouse;
GO

-- =================================================================================
-- Section 1: CRM Source Tables
-- =================================================================================

-- Table: bronze.crm_cust_info
-- Purpose: Stores raw customer profile data extracted from the CRM system.
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info(
	 cst_id INT
	,cst_key NVARCHAR(50)
	,cst_firstname NVARCHAR(50)
	,cst_lastname NVARCHAR(50)
	,cst_material_status NVARCHAR(50)
	,cst_gndr NVARCHAR(50)
	,cst_create_date DATE
);
GO

-- Table: bronze.crm_prd_info
-- Purpose: Stores raw product catalog listings and operational dates from the CRM.
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info(
	prd_id INT
	,prd_key NVARCHAR(50)
	,prd_nm	NVARCHAR(50)
	,prd_cost INT
	,prd_line NVARCHAR(10)
	,prd_start_dt DATETIME
	,prd_end_dt DATETIME
);
GO

-- Table: bronze.crm_sales_details
-- Purpose: Stores transaction-level sales details, quantities, and pricing from the CRM.
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details(
	sls_ord_num	NVARCHAR(50)
	,sls_prd_key NVARCHAR(50)
	,sls_cust_id INT
	,sls_order_dt INT
	,sls_ship_dt INT
	,sls_due_dt INT
	,sls_sales INT
	,sls_quantity INT
	,sls_price INT
);
GO


-- =================================================================================
-- Section 2: ERP Source Tables
-- =================================================================================

-- Table: bronze.erp_loc_a0101
-- Purpose: Stores regional and country localization maps extracted from the ERP system.
IF OBJECT_ID ('bronze.erp_loc_a0101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a0101;
GO

CREATE TABLE bronze.erp_loc_a0101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO

-- Table: bronze.erp_cust_az12
-- Purpose: Stores supplemental customer demographic details (birthdate, gender) from the ERP.
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO

-- Table: bronze.erp_px_cat_giv2
-- Purpose: Stores raw ERP product category, subcategory structures, and maintenance flags.
IF OBJECT_ID ('bronze.erp_px_cat_giv2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_giv2;
GO

CREATE TABLE bronze.erp_px_cat_giv2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintainence NVARCHAR(50)
);
GO

/* 
=================================================================================
-- End of Script
=================================================================================
*/
