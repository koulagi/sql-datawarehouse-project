
--check start_date & end_date modifications
SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')



--Repair the DDL
IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id            INT,
	prd_cat_id        NVARCHAR(50),
	prd_key           NVARCHAR(50),
	prd_nm            NVARCHAR(50),
	prd_cost          INT,
	prd_line          NVARCHAR(50),
	prd_start_dt      DATE,
	prd_end_dt        DATE,
	dwh_create_date   DATETIME2 DEFAULT GETDATE()
)
