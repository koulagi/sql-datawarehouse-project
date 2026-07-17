/*
===============================================================================
DDL Script: Silver Layer Table Creation
===============================================================================
Description:
    This script initializes the Silver Layer tables for both CRM and ERP 
    source systems within the Data Warehouse. 
    
    The Silver Layer acts as the cleansed, standardized, and conformed 
    reconciliation area before data is modeled into the Gold Layer.

Execution Pattern:
    - Master Deployment Wrappers (Conditional Drop & Recreate)
    - Consolidated Error/Status Logging (PRINT Statements)
    - Normalized Column Alignment & Standardized Datatypes
===============================================================================
*/

USE DataWarehouse;
GO

PRINT '===============================================================================';
PRINT 'Initializing Silver Layer Table Deployment';
PRINT '===============================================================================';
GO


-- ============================================================================
-- SECTION 1: CRM SOURCE TABLES
-- ============================================================================
PRINT '-------------------------------------------------------------------------------';
PRINT 'Deploying Section 1: CRM Source Tables';
PRINT '-------------------------------------------------------------------------------';
GO

-- Table: silver.crm_cust_info
-- Purpose: Stores raw customer profile data extracted from the CRM system.
PRINT '-> Dropping table silver.crm_cust_info if exists...';
IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL 
    DROP TABLE silver.crm_cust_info;
GO

PRINT '-> Creating table silver.crm_cust_info...';
CREATE TABLE silver.crm_cust_info (
    cst_id               INT,
    cst_key              NVARCHAR(50),
    cst_firstname        NVARCHAR(50),
    cst_lastname         NVARCHAR(50),
    cst_material_status  NVARCHAR(50),
    cst_gndr             NVARCHAR(50),
    cst_create_date      DATE,
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.crm_prd_info
-- Purpose: Stores raw product catalog listings and operational dates from the CRM.
PRINT '-> Dropping table silver.crm_prd_info if exists...';
IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL 
    DROP TABLE silver.crm_prd_info;
GO

PRINT '-> Creating table silver.crm_prd_info...';
CREATE TABLE silver.crm_prd_info (
    prd_id               INT,
    prd_key              NVARCHAR(50),
    prd_nm               NVARCHAR(50),
    prd_cost             INT,
    prd_line             NVARCHAR(10),
    prd_start_dt         DATETIME,
    prd_end_dt           DATETIME,
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.crm_sales_details
-- Purpose: Stores transaction-level sales details, quantities, and pricing from the CRM.
PRINT '-> Dropping table silver.crm_sales_details if exists...';
IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL 
    DROP TABLE silver.crm_sales_details;
GO

PRINT '-> Creating table silver.crm_sales_details...';
CREATE TABLE silver.crm_sales_details (
    sls_ord_num          NVARCHAR(50),
    sls_prd_key          NVARCHAR(50),
    sls_cust_id          INT,
    sls_order_dt         INT,
    sls_ship_dt          INT,
    sls_due_dt           INT,
    sls_sales            INT,
    sls_quantity         INT,
    sls_price            INT,
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO


-- ============================================================================
-- SECTION 2: ERP SOURCE TABLES
-- ============================================================================
PRINT '-------------------------------------------------------------------------------';
PRINT 'Deploying Section 2: ERP Source Tables';
PRINT '-------------------------------------------------------------------------------';
GO

-- Table: silver.erp_loc_a0101
-- Purpose: Stores regional and country localization maps extracted from the ERP system.
PRINT '-> Dropping table silver.erp_loc_a0101 if exists...';
IF OBJECT_ID ('silver.erp_loc_a0101', 'U') IS NOT NULL 
    DROP TABLE silver.erp_loc_a0101;
GO

PRINT '-> Creating table silver.erp_loc_a0101...';
CREATE TABLE silver.erp_loc_a0101 (
    cid                  NVARCHAR(50),
    cntry                NVARCHAR(50),
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.erp_cust_az12
-- Purpose: Stores supplemental customer demographic details (birthdate, gender) from the ERP.
PRINT '-> Dropping table silver.erp_cust_az12 if exists...';
IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL 
    DROP TABLE silver.erp_cust_az12;
GO

PRINT '-> Creating table silver.erp_cust_az12...';
CREATE TABLE silver.erp_cust_az12 (
    cid                  NVARCHAR(50),
    bdate                DATE,
    gen                  NVARCHAR(50),
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.erp_px_cat_giv2
-- Purpose: Stores raw ERP product category, subcategory structures, and maintenance flags.
PRINT '-> Dropping table silver.erp_px_cat_giv2 if exists...';
IF OBJECT_ID ('silver.erp_px_cat_giv2', 'U') IS NOT NULL 
    DROP TABLE silver.erp_px_cat_giv2;
GO

PRINT '-> Creating table silver.erp_px_cat_giv2...';
CREATE TABLE silver.erp_px_cat_giv2 (
    id                   NVARCHAR(50),
    cat                  NVARCHAR(50),
    subcat               NVARCHAR(50),
    maintainence         NVARCHAR(50),
    dwh_create_date      DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '===============================================================================';
PRINT 'Silver Layer Table Deployment Completed Successfully!';
PRINT '===============================================================================';
GO
