------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------DC_DeliveryCustomer---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

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

CREATE TABLE Customer (
    customerID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(50),
    number NVARCHAR(20),
    address NVARCHAR(255)
);
GO

-- Create Delivery table
CREATE  Table Delivery (
  DeliveryID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  OrderID UNIQUEIDENTIFIER,
  DeliveryDate DATE,
  CustomerID UNIQUEIDENTIFIER, 
  Status VARCHAR(100),
  OrderDetailID UNIQUEIDENTIFIER 
);
GO



------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------DC_WarehouseOrder	----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------



-- Drop the DC_WarehouseOrder database if it exists
IF DB_ID('DC_WarehouseOrder') IS NOT NULL
BEGIN
    ALTER DATABASE DC_WarehouseOrder SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DC_WarehouseOrder;
END
GO

-- Create the DC_WarehouseOrder database
CREATE DATABASE DC_WarehouseOrder;
GO

USE DC_WarehouseOrder;
GO

-- Drop tables if they already exist
IF OBJECT_ID('dbo.Warehouse', 'U') IS NOT NULL DROP TABLE dbo.Warehouse;
IF OBJECT_ID('dbo."Order"', 'U') IS NOT NULL DROP TABLE dbo."Order";
IF OBJECT_ID('dbo.OrderDetail', 'U') IS NOT NULL DROP TABLE dbo.OrderDetail;
IF OBJECT_ID('dbo."OrderHistory"', 'U') IS NOT NULL DROP TABLE dbo.OrderHistory;
GO


CREATE TABLE Warehouse (
  WarehouseID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  WarehouseName VARCHAR(100) NOT NULL,
  Address VARCHAR(200) NOT NULL,
  IsRefrigerated  BIT NOT NULL,
  Capacity INTEGER NOT NULL,
  QuantityAvailable INTEGER NOT NULL,
  MinimumStockLevel INTEGER NOT NULL,
  MaximumStockLevel INTEGER NOT NULL
);
GO

CREATE TABLE "Order" (
  OrderID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  OrderDate DATE NOT NULL,
  CustomerID UNIQUEIDENTIFIER NOT NULL,
  Status VARCHAR(100) NOT NULL,
  ExpectedDeliveryDate DATE NOT NULL
);
GO

CREATE TABLE OrderDetail (
  OrderDetailID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  OrderID UNIQUEIDENTIFIER NOT NULL,
  ProductDescription VARCHAR(200) NOT NULL,
  Quantity INTEGER NOT NULL,
  PackageDate DATE NOT NULL,
  WarehouseID UNIQUEIDENTIFIER NOT NULL,
  Status VARCHAR(100) NOT NULL,
  Type VARCHAR(50) NOT NULL,
  Dimensions VARCHAR(100) NOT NULL,
  Refrigerated BIT NOT NULL
);
GO

CREATE TABLE OrderHistory (
  OrderHistoryID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
  OrderID UNIQUEIDENTIFIER NOT NULL,
  FromWarehouseID UNIQUEIDENTIFIER NOT NULL,
  ToWarehouseID UNIQUEIDENTIFIER NOT NULL,
  DepartureDate DATE NOT NULL,
  ArrivalDate DATE NOT NULL
);
GO

SELECT * FROM Warehouse;


