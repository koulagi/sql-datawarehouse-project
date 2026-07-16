/*=================================================================================
   Script Name: setup_data_warehouse.sql
   Purpose:     Initializes the DataWarehouse database environment. 
                If the database already exists, it is dropped to ensure a clean,
                idempotent setup. It additionally provisions the core Medallion
                architecture schemas: Bronze, Silver, and Gold.
   WARNING:     THIS SCRIPT WILL PERMANENTLY DROP THE EXISTING 'DataWarehouse' 
                DATABASE AND ALL OF ITS CONTAINED TABLES, SCHEMAS, AND DATA.
                PLEASE ENSURE YOU HAVE A BACKUP OR COPY OF YOUR DATA BEFORE 
               RUNNING THIS SCRIPT IN ANY ENVIRONMENT.
   Author:      koulagi
   Date:        2026-07-16
=================================================================================
*/
--CREATE DATABASE 'DATAWAREHOUSE'

USE master;

--Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;

GO

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
