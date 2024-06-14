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

IF OBJECT_ID('dbo.Delivery', 'U') IS NOT NULL DROP TABLE dbo.Delivery;
GO
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL DROP TABLE dbo.Customer;
GO
IF TYPE_ID('OrderDetailsType') IS NOT NULL DROP TYPE OrderDetailsType;
GO
CREATE TABLE Customer (
    customerID INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(50),
    number NVARCHAR(20),
    address NVARCHAR(255)
);
GO

-- Create Delivery table
CREATE  Table Delivery (
  DeliveryID INT IDENTITY(1,1) PRIMARY KEY,
  OrderID INT,
  DeliveryDate DATE,
  CustomerID INT, 
  Status VARCHAR(100),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
);
GO

CREATE TYPE OrderDetailsType AS TABLE (
    ProductDescription VARCHAR(200),
    Quantity INT,
    PackageDate DATE,
    WarehouseID INT,
	Status VARCHAR(50),
    Type VARCHAR(50),
    Dimensions VARCHAR(100),
    Refrigerated BIT
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
IF OBJECT_ID('dbo.OrderDetail', 'U') IS NOT NULL DROP TABLE dbo.OrderDetail;
IF OBJECT_ID('dbo."OrderHistory"', 'U') IS NOT NULL DROP TABLE dbo.OrderHistory;
IF OBJECT_ID('dbo.Warehouse', 'U') IS NOT NULL DROP TABLE dbo.Warehouse;
IF OBJECT_ID('dbo."Order"', 'U') IS NOT NULL DROP TABLE dbo."Order";
IF TYPE_ID('OrderDetailsType') IS NOT NULL DROP TYPE OrderDetailsType;
GO

CREATE TABLE Warehouse (
  WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
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
  OrderID INT IDENTITY(1,1) PRIMARY KEY,
  OrderDate DATE NOT NULL,
  CustomerID INT NOT NULL,
  Status VARCHAR(100) NOT NULL,
  ExpectedDeliveryDate DATE NOT NULL
);
GO

CREATE TABLE OrderDetail (
  OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
  OrderID INT NOT NULL,
  ProductDescription VARCHAR(200) NOT NULL,
  Quantity INTEGER NOT NULL,
  PackageDate DATE NOT NULL,
  WarehouseID INT NOT NULL,
  Status VARCHAR(50) NOT NULL,
  Type VARCHAR(50) NOT NULL,
  Dimensions VARCHAR(100) NOT NULL,
  Refrigerated BIT NOT NULL
  FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
  FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID)
);
GO

CREATE TABLE OrderHistory (
  OrderHistoryID INT IDENTITY(1,1) PRIMARY KEY,
  OrderID INT NOT NULL,
  FromWarehouseID INT NOT NULL,
  ToWarehouseID INT NOT NULL,
  DepartureDate DATE NOT NULL,
  ArrivalDate DATE NOT NULL
  FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
  FOREIGN KEY (FromWarehouseID) REFERENCES Warehouse(WarehouseID),
  FOREIGN KEY (ToWarehouseID) REFERENCES Warehouse(WarehouseID)
);
GO
--TYPES
CREATE TYPE OrderDetailsType AS TABLE (
    ProductDescription VARCHAR(200),
    Quantity INT,
    PackageDate DATE,
    WarehouseID INT,
	Status VARCHAR(50),
    Type VARCHAR(50),
    Dimensions VARCHAR(100),
    Refrigerated BIT
);
GO

SELECT * FROM Warehouse;



-- Identify the foreign key constraints
SELECT 
    fk.name AS ForeignKey,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN 
    sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN 
    sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN 
    sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE 
    tr.name = '[dbo].[Order]';

-- Drop the foreign key constraints
ALTER TABLE OrderDetail
DROP CONSTRAINT FK__OrderDeta__Wareh__5165187F;

-- Drop the table
DROP TABLE dbo.Customer;


ALTER TABLE [dbo].[Order]
DROP CONSTRAINT FK__Order__ExpectedD__47DBAE45;

