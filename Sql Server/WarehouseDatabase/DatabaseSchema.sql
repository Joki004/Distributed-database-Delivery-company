
--DATABASE: DC_Warehouse

IF DB_ID('DC_Warehouse') IS NOT NULL
BEGIN
    DROP DATABASE DC_Warehouse;
	CREATE DATABASE DC_Warehouse;
END
GO

USE DC_Warehouse;
GO

IF OBJECT_ID('dbo.Warehouse', 'U') IS NOT NULL DROP TABLE dbo.Warehouse;
IF OBJECT_ID('dbo.Package', 'U') IS NOT NULL DROP TABLE dbo.Package;
IF OBJECT_ID('dbo.PackageDetails', 'U') IS NOT NULL DROP TABLE dbo.PackageDetails;
IF OBJECT_ID('dbo.PackageHistory', 'U') IS NOT NULL DROP TABLE dbo.PackageHistory;
IF OBJECT_ID('dbo.Delivery', 'U') IS NOT NULL DROP TABLE dbo.Delivery;
IF OBJECT_ID('dbo.Vehicle', 'U') IS NOT NULL DROP TABLE dbo.Vehicle;
IF OBJECT_ID('dbo.VehicleInventory', 'U') IS NOT NULL DROP TABLE dbo.VehicleInventory;
GO

CREATE TABLE Warehouse (
	warehouse_id INT IDENTITY(1,1) PRIMARY KEY,
	warehouse_name VARCHAR(100) NOT NULL,
	address VARCHAR(200) NOT NULL,
);
GO

CREATE TABLE Package (
	package_id INT IDENTITY(1,1) PRIMARY KEY,
	warehouse_id INT,
	vehicle_id INT,
	customer_id INT NOT NULL,
	step_number INT NOT NULL,
	status VARCHAR(100) NOT NULL,
	ExpectedDeliveryDate DATE NOT NULL,
);
GO

CREATE TABLE PackageDetails (
	package_details_id INT IDENTITY(1,1) PRIMARY KEY,
	package_id INT NOT NULL,
	type VARCHAR(50) NOT NULL,
	size VARCHAR(50) NOT NULL,
	weight DECIMAL(10, 2) NOT NULL
);
GO

CREATE TABLE PackageHistory (
	package_history_id INT IDENTITY(1,1) PRIMARY KEY,
	package_id INT NOT NULL,
	action VARCHAR(250) NOT NULL,
	action_date DATETIME NOT NULL,
);
GO

CREATE Table Delivery (
	delivery_id INT IDENTITY(1,1) PRIMARY KEY,
	package_id INT,
	customer_id DATE,
);
GO

CREATE Table Vehicle (
	vehicle_id INT IDENTITY(1,1) PRIMARY KEY,
	employee_id INT NOT NULL,
);
GO

CREATE Table VehicleInventory (
	vehicle_inventory_id INT IDENTITY(1,1) PRIMARY KEY,
	vehicle_id INT NOT NULL,
	package_id INT NOT NULL,
);
GO
