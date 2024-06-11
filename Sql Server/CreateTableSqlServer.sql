-- Drop the Headquarters database if it exists
IF DB_ID('DC_DeliveryCustomer') IS NOT NULL
BEGIN
    ALTER DATABASE DC_DeliveryCustomer SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DC_DeliveryCustomer;
END
GO

-- Create the Headquarters database
CREATE DATABASE DC_DeliveryCustomer;
GO

USE DC_DeliveryCustomer;
GO

-- Drop tables if they already exist
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Delivery', 'U') IS NOT NULL DROP TABLE dbo.Delivery;
GO

-- Create Customers table
CREATE TABLE Customers (
    customerID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(50),
    number NVARCHAR(20),
    address NVARCHAR(255)
);
GO

-- Create Delivery table
CREATE Table Delivery (
  DeliveryID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  OrderID INT,
  DeliveryDate DATE,
  CustomerID INT,
  Status VARCHAR(100),
  OrderDetailID int
);
GO

